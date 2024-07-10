import 'dart:typed_data';
import 'package:digicoinlib/src/common/checks.dart';
import 'package:digicoinlib/src/common/hex.dart';
import 'package:digicoinlib/src/common/serial.dart';
import 'package:digicoinlib/src/crypto/ec_private_key.dart';
import 'package:digicoinlib/src/crypto/hash.dart';
import 'package:digicoinlib/src/tx/inputs/taproot_key_input.dart';
import 'inputs/input.dart';
import 'inputs/input_signature.dart';
import 'inputs/legacy_input.dart';
import 'inputs/legacy_witness_input.dart';
import 'inputs/p2pkh_input.dart';
import 'inputs/p2sh_multisig_input.dart';
import 'inputs/p2wpkh_input.dart';
import 'inputs/raw_input.dart';
import 'inputs/witness_input.dart';
import 'sighash/sighash_type.dart';
import 'output.dart';

class TransactionTooLarge implements Exception {}
class InvalidTransaction implements Exception {}
class CannotSignInput implements Exception {
  final String message;
  CannotSignInput(this.message);
  @override
  String toString() => "CannotSignInput: $message";
}

/// Allows construction and signing of DigiByte transactions including those
/// with witness data.
class Transaction with Writable {

  static const currentVersion = 3;
  static const maxSize = 1000000;

  static const minInputSize = 41;
  static const minOutputSize = 9;
  static const minOtherSize = 10;

  static const maxInputs
    = (maxSize - minOtherSize - minOutputSize) ~/ minInputSize;
  static const maxOutputs
    = (maxSize - minOtherSize - minInputSize) ~/ minOutputSize;

  final int version;
  final List<Input> inputs;
  final List<Output> outputs;
  final int locktime;

  /// Constructs a transaction with the given [inputs] and [outputs].
  /// [TransactionTooLarge] will be thrown if the resulting transction exceeds
  /// [maxSize] (1MB).
  Transaction({
    this.version = currentVersion,
    required Iterable<Input> inputs,
    required Iterable<Output> outputs,
    this.locktime = 0,
  })
  : inputs = List.unmodifiable(inputs),
  outputs = List.unmodifiable(outputs)
  {
    checkInt32(version);
    checkUint32(locktime);
    if (size > maxSize) throw TransactionTooLarge();
  }

  static int _readAndCheckVarInt(BytesReader reader, int max) {
    final n = reader.readVarInt();
    if (n > BigInt.from(max)) throw TransactionTooLarge();
    return n.toInt();
  }

  static Transaction? _tryRead(BytesReader reader, bool witness) {

    final version = reader.readInt32();

    if (witness) {
      // Check for witness data
      final marker = reader.readUInt8();
      final flag = reader.readUInt8();
      if (marker != 0 || flag != 1) return null;
    }

    final rawInputs = List.generate(
      _readAndCheckVarInt(reader, maxInputs),
      (i) => RawInput.fromReader(reader),
    );

    final outputs = List.generate(
      _readAndCheckVarInt(reader, maxOutputs),
      (i) => Output.fromReader(reader),
    );

    // Match the raw inputs with witness data if this is a witness transaction
    final inputs = rawInputs.map(
      (raw) => Input.match(raw, witness ? reader.readVector() : []),
    // Create list now to ensure we read the witness data before the locktime
    ).toList();

    final locktime = reader.readUInt32();

    return Transaction(
      version: version,
      inputs: inputs,
      outputs: outputs,
      locktime: locktime,
    );

  }

  /// Reads a transaction from a [BytesReader], which may throw
  /// [TransactionTooLarge] or [InvalidTransaction] if the data doesn't
  /// represent a complete transaction within [maxSize] (1MB).
  /// If [expectWitness] is true, the transaction is assumed to be a witness
  /// transaction. If it is false, the transction is assumed to be a legacy
  /// non-witness transaction.
  /// If [expectWitness] is omitted or null, then this method will determine the
  /// correct transaction type from the data, starting with a witness type.
  factory Transaction.fromReader(BytesReader reader, { bool? expectWitness }) {

    bool tooLarge = false;
    final start = reader.offset;

    Transaction? tryReadAndSetTooLarge(bool witness) {
      try {
        return _tryRead(reader, witness);
      } on TransactionTooLarge {
        tooLarge = true;
      } on Exception catch(_) {}
      return null;
    }

    if (expectWitness != false) { // Includes null condition
      final witnessTx = tryReadAndSetTooLarge(true);
      if (witnessTx != null) return witnessTx;
    }

    // Reset offset of reader
    reader.offset = start;

    if (expectWitness != true) { // Includes null condition
      final legacyTx = tryReadAndSetTooLarge(false);
      if (legacyTx != null) return legacyTx;
    }

    throw tooLarge ? TransactionTooLarge() : InvalidTransaction();

  }

  /// Constructs a transaction from serialised bytes. See [fromReader()].
  factory Transaction.fromBytes(Uint8List bytes, { bool? expectWitness })
    => Transaction.fromReader(BytesReader(bytes), expectWitness: expectWitness);

  /// Constructs a transaction from the serialised data encoded as hex. See
  /// [fromReader()].
  factory Transaction.fromHex(String hex, { bool? expectWitness })
    => Transaction.fromBytes(hexToBytes(hex), expectWitness: expectWitness);

  @override
  void write(Writer writer) {

    writer.writeInt32(version);

    if (isWitness) {
      writer.writeUInt8(0); // Marker
      writer.writeUInt8(1); // Flag
    }

    writer.writeVarInt(BigInt.from(inputs.length));
    for (final input in inputs) {
      input.write(writer);
    }

    writer.writeVarInt(BigInt.from(outputs.length));
    for (final output in outputs) {
      output.write(writer);
    }

    if (isWitness) {
      for (final input in inputs) {
        writer.writeVector(input is WitnessInput ? input.witness : []);
      }
    }

    writer.writeUInt32(locktime);

  }

  /// Sign the input at [inputN] with the [key] and [hashType] and return a new
  /// [Transaction] with the signed input. The input must be a signable
  /// [P2PKHInput], [P2WPKHInput], [P2SHMultisigInput] or [TaprootKeyInput].
  /// Otherwise [CannotSignInput] will be thrown. Other inputs may be signed
  /// seperately and inserted back into the transaction via [replaceInput].
  /// [value] is only required for P2WPKH.
  /// [prevOuts] is only required for Taproot inputs.
  Transaction sign({
    required int inputN,
    required ECPrivateKey key,
    SigHashType hashType = const SigHashType.all(),
    BigInt? value,
    List<Output>? prevOuts,
  }) {

    if (inputN >= inputs.length) {
      throw ArgumentError.value(inputN, "inputN", "outside range of inputs");
    }

    if (!hashType.none && outputs.isEmpty) {
      throw CannotSignInput("Cannot sign input without any outputs");
    }

    final input = inputs[inputN];

    // Sign input
    late Input signedIn;

    if (input is LegacyInput) {
      signedIn = input.sign(
        tx: this,
        inputN: inputN,
        key: key,
        hashType: hashType,
      );
    } else if (input is LegacyWitnessInput) {

      if (value == null) {
        throw CannotSignInput("Prevout values are required for witness inputs");
      }

      signedIn = input.sign(
        tx: this,
        inputN: inputN,
        key: key,
        value: value,
        hashType: hashType,
      );

    } else if (input is TaprootKeyInput) {

      if (prevOuts == null) {
        throw CannotSignInput(
          "Previous outputs are required when signing a taproot input",
        );
      }

      if (prevOuts.length != inputs.length) {
        throw CannotSignInput(
          "The number of previous outputs must match the number of inputs",
        );
      }

      signedIn = input.sign(
        tx: this,
        inputN: inputN,
        key: key,
        prevOuts: prevOuts,
        hashType: hashType,
      );

    } else {
      throw CannotSignInput("${input.runtimeType} not a signable input");
    }

    // Replace input in input list
    final newInputs = inputs.asMap().map(
      (index, input) => MapEntry(
        index, index == inputN ? signedIn : input,
      ),
    ).values;

    return Transaction(
      version: version,
      inputs: newInputs,
      outputs: outputs,
      locktime: locktime,
    );

  }


  /// Replaces the input at [n] with the new [input] and invalidates other
  /// input signatures that have standard sighash types accordingly. This is
  /// useful for signing or otherwise updating inputs that cannot be signed with
  /// the [sign] method.
  Transaction replaceInput(Input input, int n) {

    final oldInput = inputs[n];

    if (input == oldInput) return this;

    final newPrevOut = input.prevOut != oldInput.prevOut;
    final newSequence = input.sequence != oldInput.sequence;

    final filtered = inputs.map(
      (input) => input.filterSignatures(
        (insig)
          // Allow ANYONECANPAY
          => insig.hashType.anyOneCanPay
          // Allow signature if previous output hasn't changed and the sequence
          // has not changed for taproot inputs or when using SIGHASH_ALL.
          || !(
            newPrevOut || (
              newSequence
              && (insig.hashType.all || insig is SchnorrInputSignature)
            )
          ),
      ),
    ).toList();

    return Transaction(
      version: version,
      inputs: [...filtered.take(n), input, ...filtered.sublist(n+1)],
      outputs: outputs,
      locktime: locktime,
    );

  }

  /// Returns a new [Transaction] with the [input] added to the end of the input
  /// list.
  Transaction addInput(Input input) => Transaction(
    version: version,
    inputs: [
      // Only keep ANYONECANPAY signatures when adding a new input
      ...inputs.map(
        (input) => input.filterSignatures(
          (insig) => insig.hashType.anyOneCanPay,
        ),
      ),
      input,
    ],
    outputs: outputs,
    locktime: locktime,
  );

  /// Returns a new [Transaction] with the [output] added to the end of the
  /// output list.
  Transaction addOutput(Output output) {

    final modifiedInputs = inputs.asMap().map(
      (i, input) => MapEntry(
        i, input.filterSignatures(
          (insig)
          // Allow signatures that sign no outpus
          => insig.hashType.none
          // Allow signatures that sign a single output which isn't the one
          // being added
          || (insig.hashType.single && i != outputs.length),
        ),
      ),
    ).values;

    return Transaction(
      version: version,
      inputs: modifiedInputs,
      outputs: [...outputs, output],
      locktime: locktime,
    );

  }

  Transaction? _legacyCache;
  /// Returns a non-witness variant of this transaction. Any witness inputs are
  /// replaced with their raw equivalents without witness data. If the
  /// transaction is already non-witness, then it shall be returned as-is.
  Transaction get legacy => isWitness
    ? _legacyCache ??= Transaction(
      version: version,
      inputs: inputs.map(
        // Raw inputs remove all witness data and are serialized as legacy
        // inputs. Don't waste creating a new object for non-witness inputs.
        (input) => input is WitnessInput
          ? RawInput(
            prevOut: input.prevOut,
            scriptSig: input.scriptSig,
            sequence: input.sequence,
          )
          : input,
      ),
      outputs: outputs,
      locktime: locktime,
    )
    : this;

  Uint8List? _hashCache;
  /// The serialized tx data hashed with sha256d
  Uint8List get hash => _hashCache ??= sha256DoubleHash(toBytes());

  Uint8List? _legacyHashCache;
  /// The serialized tx data without witness data hashed with sha256d
  Uint8List get legacyHash => _legacyHashCache ??= legacy.hash;

  /// Get the reversed hash as hex which is usual for DigiByte transactions
  /// This provides the witness txid. See [legacyHash] for the legacy type of
  /// hash.
  String get hashHex => bytesToHex(Uint8List.fromList(hash.reversed.toList()));

  /// Gets the legacy reversed hash as hex without witness data.
  String get txid
    => bytesToHex(Uint8List.fromList(legacyHash.reversed.toList()));

  /// If the transaction has any witness inputs.
  bool get isWitness => inputs.any((input) => input is WitnessInput);

  bool get isCoinBase
    => inputs.length == 1
    && inputs.first.prevOut.coinbase
    && outputs.isNotEmpty;

  bool get isCoinStake
    => inputs.isNotEmpty
    && !inputs.first.prevOut.coinbase
    && outputs.length >= 2
    && outputs.first.value == BigInt.zero
    && outputs.first.scriptPubKey.isEmpty;

  /// Returns true when all of the inputs are fully signed with at least one
  /// input and one output. There is no guarentee that the transaction is valid
  /// on the blockchain.
  bool get complete
    => inputs.isNotEmpty && outputs.isNotEmpty
    && inputs.every((input) => input.complete);

}

import 'dart:typed_data';
import 'package:digicoinlib/src/common/serial.dart';
import 'package:digicoinlib/src/crypto/hash.dart';
import 'package:digicoinlib/src/scripts/operations.dart';
import 'package:digicoinlib/src/scripts/script.dart';
import 'package:digicoinlib/src/tx/inputs/raw_input.dart';
import 'package:digicoinlib/src/tx/sighash/sighash_type.dart';
import 'package:digicoinlib/src/tx/output.dart';
import 'package:digicoinlib/src/tx/transaction.dart';
import 'signature_hasher.dart';

/// Produces signature hashes for legacy non-witness inputs.
final class LegacySignatureHasher implements SignatureHasher {

  static final ScriptOp _codeseperator = ScriptOpCode.fromName("CODESEPARATOR");
  static final _hashOne = Uint8List(32)..last = 1;

  final Transaction tx;
  final int inputN;
  final Script scriptCode;
  final SigHashType hashType;

  /// Produces the hash of an input signature for a non-witness input at
  /// [inputN]. The [scriptCode] of the redeem script is necessary. [hashType]
  /// controls what data is included in the signature.
  LegacySignatureHasher({
    required this.tx,
    required this.inputN,
    required this.scriptCode,
    required this.hashType,
  }) {
    SignatureHasher.checkInputN(tx, inputN);
    SignatureHasher.checkSchnorrDisallowed(hashType);
  }

  @override
  Uint8List get hash {

    // Remove OP_CODESEPERATOR from the script code
    final correctedScriptSig = Script(
      scriptCode.ops.where((op) => !op.match(_codeseperator)),
    ).compiled;

    // If there is no matching output for SIGHASH_SINGLE, then return all null
    // bytes apart from the last byte that should be 1
    if (hashType.single && inputN >= tx.outputs.length) return _hashOne;

    // Create modified transaction for obtaining a signature hash

    final modifiedInputs = (
      hashType.anyOneCanPay ? [tx.inputs[inputN]] : tx.inputs
    ).asMap().map(
      (index, input) {
        final isThisInput = hashType.anyOneCanPay || index == inputN;
        return MapEntry(
          index,
          RawInput(
            prevOut: input.prevOut,
            // Use the corrected previous output script for the input being signed
            // and blank scripts for all the others
            scriptSig: isThisInput ? correctedScriptSig : Uint8List(0),
            // Make sequence 0 for other inputs unless using SIGHASH_ALL
            sequence: isThisInput || hashType.all ? input.sequence : 0,
          ),
        );
      }
    ).values;

    final modifiedOutputs = hashType.all ? tx.outputs : (
      hashType.none ? <Output>[] : [
        // Single output
        // Include blank outputs upto output index
        ...Iterable.generate(inputN, (i) => Output.blank()),
        tx.outputs[inputN],
      ]
    );

    final modifiedTx = Transaction(
      version: tx.version,
      inputs: modifiedInputs,
      outputs: modifiedOutputs,
      locktime: tx.locktime,
    );

    // Add sighash type onto the end
    final bytes = Uint8List(modifiedTx.size + 4);
    final writer = BytesWriter(bytes);
    modifiedTx.write(writer);
    writer.writeUInt32(hashType.value);

    // Use sha256d for signature hash
    return sha256DoubleHash(bytes);

  }

}

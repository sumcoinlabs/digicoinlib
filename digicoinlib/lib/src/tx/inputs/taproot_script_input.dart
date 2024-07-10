import 'dart:typed_data';
import 'package:digicoinlib/src/common/serial.dart';
import 'package:digicoinlib/src/crypto/ec_private_key.dart';
import 'package:digicoinlib/src/scripts/operations.dart';
import 'package:digicoinlib/src/scripts/script.dart';
import 'package:digicoinlib/src/taproot.dart';
import 'package:digicoinlib/src/tx/inputs/taproot_input.dart';
import 'package:digicoinlib/src/tx/outpoint.dart';
import 'package:digicoinlib/src/tx/output.dart';
import 'package:digicoinlib/src/tx/sighash/sighash_type.dart';
import 'package:digicoinlib/src/tx/transaction.dart';
import 'input.dart';
import 'input_signature.dart';
import 'raw_input.dart';

/// A [TaprootInput] which spends using the script-path for 0xc0 version
/// Tapscripts. There is no signing logic and sign() is not implemented.
/// Subclasses should handle signing. [createScriptSignature] can be used to
/// create signatures as necessary. Insertion of signatures and other data can
/// be done manually via [updateStack]. These signatures must be handled by the
/// consumer and will not be filtered upon a transaction update.
class TaprootScriptInput extends TaprootInput {

  /// The tapscript embedded in the witness data, not to be confused with the
  /// empty [script].
  final Script tapscript;

  TaprootScriptInput({
    required super.prevOut,
    required Uint8List controlBlock,
    required this.tapscript,
    List<Uint8List>? stack,
    super.sequence = Input.sequenceFinal,
  }) : super(
    witness: [if (stack != null) ...stack, tapscript.compiled, controlBlock],
  );

  TaprootScriptInput.fromTaprootLeaf({
    required OutPoint prevOut,
    required Taproot taproot,
    required TapLeaf leaf,
    List<Uint8List>? stack,
    int sequence = Input.sequenceFinal,
  }) : this(
    prevOut: prevOut,
    controlBlock: taproot.controlBlockForLeaf(leaf),
    tapscript: leaf.script,
    stack: stack,
    sequence: sequence,
  );

  /// Checks if the [raw] input and [witness] data match the expected format for
  /// a [TaprootScriptInput] with the control block and script. If it matches
  /// this returns a [TaprootScriptInput] for the input or else it returns null.
  /// The script must be valid with minimal push data. The control block must be
  /// the correct size and contain the correct 0xc0 tapscript version but the
  /// internal key and parity bit is not validated.
  static TaprootScriptInput? match(RawInput raw, List<Uint8List> witness) {

    if (raw.scriptSig.isNotEmpty) return null;
    if (witness.length < 2) return null;

    final controlBlock = witness.last;
    final lengthAfterKey = controlBlock.length - 33;

    if (
      controlBlock.length < 33
      || lengthAfterKey % 32 != 0
      || lengthAfterKey / 32 > 128
      || controlBlock[0] & 0xfe != TapLeaf.tapscriptVersion
    ) {
      return null;
    }

    try {

      return TaprootScriptInput(
        prevOut: raw.prevOut,
        controlBlock: controlBlock,
        tapscript: Script.decompile(witness[witness.length-2]),
        stack: witness.sublist(0, witness.length-2),
        sequence: raw.sequence,
      );

    } on OutOfData {
      return null;
    } on PushDataNotMinimal {
      return null;
    }

  }

  /// Replaces the stack to update the data required to spend the input
  TaprootScriptInput updateStack(List<Uint8List> newStack)
    => TaprootScriptInput(
      prevOut: prevOut,
      controlBlock: controlBlock,
      tapscript: tapscript,
      stack: newStack,
      sequence: sequence,
    );

  /// Creates a [SchnorrInputSignature] to be used for the input's script data.
  /// Provides the leaf hash to an underlying call to [createInputSignature].
  SchnorrInputSignature createScriptSignature({
    required Transaction tx,
    required int inputN,
    required ECPrivateKey key,
    required List<Output> prevOuts,
    SigHashType hashType = const SigHashType.all(),
    int codeSeperatorPos = 0xFFFFFFFF,
  }) => createInputSignature(
    tx: tx,
    inputN: inputN,
    key: key,
    prevOuts: prevOuts,
    hashType: hashType,
    leafHash: TapLeaf(tapscript).hash,
    codeSeperatorPos: codeSeperatorPos,
  );

  Uint8List get controlBlock => witness.last;

}

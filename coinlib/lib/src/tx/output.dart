import 'package:coinlib/src/address.dart';
import 'package:coinlib/src/common/serial.dart';
import 'package:coinlib/src/scripts/program.dart';

/// A transaction output that carries a [value] and [program] specifying how the
/// value can be spent.
class Output with Writable {

  /// Max 64-bit integer
  static BigInt maxValue = (BigInt.from(1) << 64) - BigInt.one;

  final BigInt value;
  final Program program;

  Output(this.value, this.program) {
    if (value.isNegative || value > maxValue) {
      throw ArgumentError.value(
        value, "value", "must be between 0 and $maxValue",
      );
    }
  }
  Output.fromAddress(BigInt value, Address address)
    : this(value, address.program);

  factory Output.fromReader(BytesReader reader) => Output(
    reader.readUInt64(),
    Program.decompile(reader.readVarSlice()),
  );

  @override
  void write(Writer writer) {
    writer.writeUInt64(value);
    writer.writeVarSlice(program.script.compiled);
  }

}
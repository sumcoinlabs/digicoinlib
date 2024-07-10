import 'package:digicoinlib/src/secp256k1/secp256k1.dart';

export 'package:digicoinlib/src/common/bytes.dart';
export 'package:digicoinlib/src/common/hex.dart';
export 'package:digicoinlib/src/common/serial.dart';

export 'package:digicoinlib/src/crypto/ec_private_key.dart';
export 'package:digicoinlib/src/crypto/ec_public_key.dart';
export 'package:digicoinlib/src/crypto/ecdsa_signature.dart';
export 'package:digicoinlib/src/crypto/ecdsa_recoverable_signature.dart';
export 'package:digicoinlib/src/crypto/hash.dart';
export 'package:digicoinlib/src/crypto/hd_key.dart';
export 'package:digicoinlib/src/crypto/message_signature.dart';
export 'package:digicoinlib/src/crypto/nums_public_key.dart';
export 'package:digicoinlib/src/crypto/random.dart';
export 'package:digicoinlib/src/crypto/schnorr_signature.dart';

export 'package:digicoinlib/src/encode/base58.dart';
export 'package:digicoinlib/src/encode/bech32.dart';
export 'package:digicoinlib/src/encode/wif.dart';

export 'package:digicoinlib/src/scripts/codes.dart';
export 'package:digicoinlib/src/scripts/operations.dart';
export 'package:digicoinlib/src/scripts/program.dart';
export 'package:digicoinlib/src/scripts/script.dart';

export 'package:digicoinlib/src/scripts/programs/multisig.dart';
export 'package:digicoinlib/src/scripts/programs/p2pkh.dart';
export 'package:digicoinlib/src/scripts/programs/p2sh.dart';
export 'package:digicoinlib/src/scripts/programs/p2tr.dart';
export 'package:digicoinlib/src/scripts/programs/p2witness.dart';
export 'package:digicoinlib/src/scripts/programs/p2wpkh.dart';
export 'package:digicoinlib/src/scripts/programs/p2wsh.dart';

export 'package:digicoinlib/src/tx/coin_selection.dart';
export 'package:digicoinlib/src/tx/transaction.dart';
export 'package:digicoinlib/src/tx/outpoint.dart';
export 'package:digicoinlib/src/tx/output.dart';

export 'package:digicoinlib/src/tx/inputs/input.dart';
export 'package:digicoinlib/src/tx/inputs/input_signature.dart';
export 'package:digicoinlib/src/tx/inputs/legacy_input.dart';
export 'package:digicoinlib/src/tx/inputs/legacy_witness_input.dart';
export 'package:digicoinlib/src/tx/inputs/p2pkh_input.dart';
export 'package:digicoinlib/src/tx/inputs/p2sh_multisig_input.dart';
export 'package:digicoinlib/src/tx/inputs/p2wpkh_input.dart';
export 'package:digicoinlib/src/tx/inputs/pkh_input.dart';
export 'package:digicoinlib/src/tx/inputs/raw_input.dart';
export 'package:digicoinlib/src/tx/inputs/taproot_input.dart';
export 'package:digicoinlib/src/tx/inputs/taproot_key_input.dart';
export 'package:digicoinlib/src/tx/inputs/taproot_script_input.dart';
export 'package:digicoinlib/src/tx/inputs/witness_input.dart';

export 'package:digicoinlib/src/tx/sighash/legacy_signature_hasher.dart';
export 'package:digicoinlib/src/tx/sighash/sighash_type.dart';
export 'package:digicoinlib/src/tx/sighash/taproot_signature_hasher.dart';
export 'package:digicoinlib/src/tx/sighash/witness_signature_hasher.dart';

export 'package:digicoinlib/src/address.dart';
export 'package:digicoinlib/src/coin_unit.dart';
export 'package:digicoinlib/src/network.dart';
export 'package:digicoinlib/src/taproot.dart';

Future<void> loadDigiCoinlib() => secp256k1.load();

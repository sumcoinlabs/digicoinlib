import 'package:digicoinlib/digicoinlib.dart';
import 'package:test/test.dart';
import '../vectors/keys.dart';

final privKey = WIF
    .fromString(
      "L3P4UEwSKsNoQqZ5tnhs3QwwYDifqJYaCAq2EpxA2TnN7BfmCpdp",
      version: Network.mainnet.wifPrefix,
    )
    .privkey;
final addrs = [
  P2PKHAddress.fromPublicKey(
    privKey.pubkey,
    version: Network.mainnet.p2pkhPrefix,
  ),
  P2WPKHAddress.fromPublicKey(privKey.pubkey, hrp: Network.mainnet.bech32Hrp),
];
// Public deterministic signatures generated with RFC6979/secp256k1 using
// the DigiByte message prefix. The key is a synthetic fixture, not a wallet.
final msgSigs = [
  [
    "Hello, this is a message",
    "IJbu3Ea1d2CJ+X7fZSp4etobmPKnMhYFTRSTelEZ7vn5EBEul3zmuOcQsxUXohKmZ91DWsogskiZz+B834qMSrY=",
  ],
  [
    "The recid for this message is 1",
    "ILvzU6t3khfSBZGSTPMWQS9W4Y5vxsXtVFxHGZg6B/FnIm+1lYVnzB7m98xYbQdLoYjAP+olsvSszh06PIjLAew=",
  ],
];

final prefix = Network.mainnet.messagePrefix;

void main() {
  group("MessageSignature", () {
    setUpAll(loadDigiCoinlib);

    test("can sign messages", () {
      for (final vec in msgSigs) {
        final msgSig = MessageSignature.sign(
          key: privKey,
          message: vec[0],
          prefix: prefix,
        );
        expect(msgSig.toString(), vec[1]);
      }
    });

    test("verifies against public key and address", () {
      for (final vec in msgSigs) {
        final msgSig = MessageSignature.fromBase64(vec[1]);
        expect(
          msgSig.verifyPublicKey(
            pubkey: privKey.pubkey,
            message: vec[0],
            prefix: prefix,
          ),
          true,
        );
        for (final addr in addrs) {
          expect(
            msgSig.verifyAddress(
              address: addr,
              message: vec[0],
              prefix: prefix,
            ),
            true,
          );
        }
      }
    });

    test("fails against wrong public key or address", () {
      final msgSig = MessageSignature.fromBase64(msgSigs[0][1]);
      expect(
        msgSig.verifyPublicKey(
          pubkey: keyPairVectors[0].publicObj,
          message: msgSigs[0][0],
          prefix: prefix,
        ),
        false,
      );
      expect(
        msgSig.verifyAddress(
          address: Address.fromString(
            "D596YFweJQuHY1BbjazZYmAbt8jJPbKehC",
            Network.mainnet,
          ),
          message: msgSigs[0][0],
          prefix: prefix,
        ),
        false,
      );
    });
  });
}

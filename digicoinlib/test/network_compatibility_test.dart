import 'dart:typed_data';
import 'package:digicoinlib/digicoinlib.dart';
import 'package:test/test.dart';

void main() {
  setUpAll(loadDigiCoinlib);

  test(
    'DigiByte mainnet remains byte-for-byte compatible at the network layer',
    () {
      final n = Network.mainnet;
      expect(n.wifPrefix, 128);
      expect(n.p2pkhPrefix, 30);
      expect(n.p2shPrefix, 63);
      expect(n.privHDPrefix, 0x0488ADE4);
      expect(n.pubHDPrefix, 0x0488B21E);
      expect(n.bech32Hrp, 'dgb');
      expect(n.messagePrefix, 'DigiByte Signed Message:\n');
    },
  );

  test('Testnet, signet, and regtest follow DigiByte Core encoding', () {
    for (final network in [Network.testnet, Network.signet, Network.regtest]) {
      expect(network.wifPrefix, 254);
      expect(network.p2pkhPrefix, 126);
      expect(network.p2shPrefix, 140);
      expect(network.privHDPrefix, 0x04358394);
      expect(network.pubHDPrefix, 0x043587CF);
    }
    expect(Network.testnet.bech32Hrp, 'dgbt');
    expect(Network.signet.bech32Hrp, 'dgbt');
    expect(Network.regtest.bech32Hrp, 'dgbrt');
  });

  test('Known synthetic address hash round trips on each network', () {
    for (final n in [
      Network.mainnet,
      Network.testnet,
      Network.signet,
      Network.regtest,
    ]) {
      final hash = Uint8List(20);
      final legacy = P2PKHAddress.fromHash(hash, version: n.p2pkhPrefix);
      expect(Address.fromString(legacy.toString(), n), isA<P2PKHAddress>());
      final segwit = P2WPKHAddress.fromHash(hash, hrp: n.bech32Hrp);
      expect(segwit.toString().startsWith('${n.bech32Hrp}1'), isTrue);
      expect(Address.fromString(segwit.toString(), n), isA<P2WPKHAddress>());
    }
  });

  test(
    'BIP32 default remains Bitcoin seed; optional custom label is honored',
    () {
      final seed = Uint8List.fromList(List<int>.generate(32, (i) => i));
      final standard = HDPrivateKey.fromSeed(seed);
      final explicit = HDPrivateKey.fromSeed(seed, key: 'Bitcoin seed');
      final custom = HDPrivateKey.fromSeed(seed, key: 'DigiByte test vector');
      expect(
        standard.encode(Network.mainnet.privHDPrefix),
        explicit.encode(Network.mainnet.privHDPrefix),
      );
      expect(
        standard.encode(Network.mainnet.privHDPrefix),
        isNot(custom.encode(Network.mainnet.privHDPrefix)),
      );
    },
  );
}

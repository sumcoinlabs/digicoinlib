import 'dart:typed_data';
import 'package:digicoinlib/digicoinlib.dart';
import 'package:test/test.dart';
import 'vectors/taproot.dart';

final wrongNetwork = Network(
  wifPrefix: 0,
  p2pkhPrefix: 0xfa,
  p2shPrefix: 0xfb,
  privHDPrefix: 0,
  pubHDPrefix: 0,
  bech32Hrp: "wrong",
  messagePrefix: "",
  feePerKb: BigInt.from(10000),
  minFee: BigInt.from(1000),
  minOutput: BigInt.from(10000),
);

void expectBase58Equal(Base58Address addr, Base58Address expected) {
  expect(addr.hash, expected.hash);
  expect(addr.version, expected.version);
  expect(addr.toString(), expected.toString());
  if (addr is P2PKHAddress) {
    expect(addr.program.pkHash, addr.hash);
  } else if (addr is P2SHAddress) {
    expect(addr.program.scriptHash, addr.hash);
  }
}

void expectBech32Equal(Bech32Address addr, Bech32Address expected) {
  expect(addr.data, expected.data);
  expect(addr.hrp, expected.hrp);
  expect(addr.toString(), expected.toString());
  if (addr is P2WPKHAddress) {
    expect(addr.program.pkHash, addr.data);
  } else if (addr is P2WSHAddress) {
    expect(addr.program.scriptHash, addr.data);
  } else if (addr is P2TRAddress) {
    expect(addr.program.tweakedKey.x, addr.data);
  } else if (addr is UnknownWitnessAddress) {
    expect(addr.program.data, addr.data);
  }
}

void expectValidAddress<T extends Address>(
  String encoded,
  Network network,
  T expected,
) {
  final baseDecoded = Address.fromString(encoded, network);
  expect(baseDecoded, isA<T>());

  late Address subDecoded;
  if (expected is Base58Address) {
    subDecoded = Base58Address.fromString(encoded, network);
  }
  if (expected is Bech32Address) {
    subDecoded = Bech32Address.fromString(encoded, network);
  }
  expect(subDecoded, isA<T>());

  expect(expected.toString(), encoded);

  expect(
    () => Address.fromString(encoded, wrongNetwork),
    throwsA(isA<InvalidAddressNetwork>()),
  );

  // Compare expected with both decoded addresses
  if (expected is Base58Address) {
    final b58Base = baseDecoded as Base58Address;
    final b58Sub = subDecoded as Base58Address;
    expectBase58Equal(b58Base, expected);
    expectBase58Equal(b58Sub, expected);
  }
  if (expected is Bech32Address) {
    final b32Base = baseDecoded as Bech32Address;
    final b32Sub = subDecoded as Bech32Address;
    expectBech32Equal(b32Base, expected);
    expectBech32Equal(b32Sub, expected);
  }
}

void main() {
  group("Address", () {
    late ECPublicKey pubkey;
    setUpAll(() async {
      await loadDigiCoinlib();
      pubkey = ECPublicKey.fromHex(
        "03aea0dfd576151cb399347aa6732f8fdf027b9ea3ea2e65fb754803f776e0a509",
      );
    });

    test("valid P2PKH addresses", () {
      expectValidAddress(
        "D596YFweJQuHY1BbjazZYmAbt8jJPbKehC",
        Network.mainnet,
        P2PKHAddress.fromHash(
          hexToBytes("0000000000000000000000000000000000000000"),
          version: Network.mainnet.p2pkhPrefix,
        ),
      );

      expectValidAddress(
        "DDJGGqQ7tqdgjN66MaePJZZUprHizV2YXW",
        Network.mainnet,
        P2PKHAddress.fromPublicKey(
          pubkey,
          version: Network.mainnet.p2pkhPrefix,
        ),
      );
    });

    test("valid P2SH addresses", () {
      expectValidAddress(
        "Skdc1x5SSYf5LjvYZrKQ32RMHHVNUBJJt6",
        Network.mainnet,
        P2SHAddress.fromHash(
          hexToBytes("ffffffffffffffffffffffffffffffffffffffff"),
          version: Network.mainnet.p2shPrefix,
        ),
      );

      expectValidAddress(
        "SbqMb54wcMPUqky5nz1HtkdUPprhjHFRf2",
        Network.mainnet,
        P2SHAddress.fromRedeemScript(
          Script.fromAsm("0"),
          version: Network.mainnet.p2shPrefix,
        ),
      );
    });

    test("valid P2WPKH addresses", () {
      expectValidAddress(
        "dgb1qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqjz6vm7",
        Network.mainnet,
        P2WPKHAddress.fromHash(
          hexToBytes("0000000000000000000000000000000000000000"),
          hrp: Network.mainnet.bech32Hrp,
        ),
      );

      expectValidAddress(
        "dgb1qt97wqg464zrhnx23upykca5annqvwkwu9fv8w2",
        Network.mainnet,
        P2WPKHAddress.fromPublicKey(pubkey, hrp: Network.mainnet.bech32Hrp),
      );
    });

    test("valid P2WSH addresses", () {
      expectValidAddress(
        "dgb1qllllllllllllllllllllllllllllllllllllllllllllllllllls5r8ra0",
        Network.mainnet,
        P2WSHAddress.fromHash(
          hexToBytes(
            "ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          ),
          hrp: Network.mainnet.bech32Hrp,
        ),
      );

      expectValidAddress(
        "dgb1qdc6qh88lkdaf3899gnntk7q293ufq8flkvmnsa59zx3sv9a05qws84x624",
        Network.mainnet,
        P2WSHAddress.fromWitnessScript(
          Script.fromAsm("0"),
          hrp: Network.mainnet.bech32Hrp,
        ),
      );
    });

    test("valid P2TR addresses", () {
      expectValidAddress(
        "dgb1punvppl2stp38f7kwv2u2spltjuvuaayuqsthe34hd2dyy5w4g58qarclht",
        Network.mainnet,
        P2TRAddress.fromTweakedKeyX(
          hexToBytes(
            "e4d810fd50586274face62b8a807eb9719cef49c04177cc6b76a9a4251d5450e",
          ),
          hrp: Network.mainnet.bech32Hrp,
        ),
      );

      expectValidAddress(
        "dgb1pz37fc4cn9ah8anwm4xqqhvxygjf9rjf2resrw8h8w4tmvcs0863sqqakc9",
        Network.mainnet,
        P2TRAddress.fromTweakedKey(
          ECPublicKey.fromXOnlyHex(
            "147c9c57132f6e7ecddba9800bb0c4449251c92a1e60371ee77557b6620f3ea3",
          ),
          hrp: Network.mainnet.bech32Hrp,
        ),
      );

      expectValidAddress(
        "dgb1p2wsldez5mud2yam29q22wgfh9439spgduvct83k3pm50fcxa5dpsf0nhat",
        Network.mainnet,
        P2TRAddress.fromTaproot(
          taprootVectors[0].object,
          hrp: Network.mainnet.bech32Hrp,
        ),
      );
    });

    test("valid unknown witness addresses", () {
      // 40 program bytes
      expectValidAddress(
        "dgb1sqqqsyqcyq5rqwzqfpg9scrgwpugpzysnzs23v9ccrydpk8qarc0jqgfzyvjz2f38dwqqym",
        Network.mainnet,
        UnknownWitnessAddress.fromHex(
          "000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f2021222324252627",
          version: 16,
          hrp: Network.mainnet.bech32Hrp,
        ),
      );

      // 2 program bytes
      expectValidAddress(
        "dgb1sqqqsg82cq5",
        Network.mainnet,
        UnknownWitnessAddress.fromHex(
          "0001",
          version: 16,
          hrp: Network.mainnet.bech32Hrp,
        ),
      );
    });

    test("invalid addresses", () {
      for (final invalid in [
        // Neither valid bech32 or base58
        "",
        // Too-short
        "61pApofd7QTRzWAb5UebizEXJ6C1cCzLU",
        "TTazDDREDxxh1mPyGySut6H98h4UKPG6",
        "dgb1qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqru3065",
        "dgb1qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq6x32u6",
        "dgb1pqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq609htp",
        // Too-long
        "9tT9KH26AxgN8j9uTpKdwUkK6LFcSKp4FpF",
        "dgb1qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq52efs9",
        "dgb1pqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq2hupv",
        // Segwit version 17
        "dgb13qqqsyqcyq5rqwzqfpg9scrgwpugpzysnzs23v9ccrydpk8qarc0sf24me3",
        // Too long unknown segwit
        "dgb1sqqqsyqcyq5rqwzqfpg9scrgwpugpzysnzs23v9ccrydpk8qarc0jqgfzyvjz2f389qud8hnp",
        // Too short unknown segwit
        "dgb1sqqtathd9",
        // Bech32m for v=0
        "dgb1qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq872q7u",
        // Bech32 for v=1
        "dgb1pqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqeud8k4",
        // Unpadded bits
        "dgb1qqqqsyqcyq5rqwzqfpg9scrgwpugpzysnzs23v9ccrydpk8qarc0slf0s4",
      ]) {
        expect(
          () => Address.fromString(invalid, Network.mainnet),
          throwsA(isA<InvalidAddress>()),
          reason: invalid,
        );
      }
    });

    test("invalid checksums", () {
      expect(
        () => Address.fromString(
          "D596YFweJQuHY1BbjazZYmAbt8jJPbKehD",
          Network.mainnet,
        ),
        throwsA(isA<InvalidBase58Checksum>()),
      );
      expect(
        () => Address.fromString(
          "dgb1qllllllllllllllllllllllllllllllllllllllllllllllllllls5r8raa",
          Network.mainnet,
        ),
        throwsA(isA<InvalidBech32Checksum>()),
      );
    });

    test("invalid base58 version", () {
      for (final v in [-1, 256]) {
        expect(
          () => P2PKHAddress.fromPublicKey(pubkey, version: v),
          throwsArgumentError,
        );
      }
    });

    test("invalid version, program and hrp arguments", () {
      // Too small program
      expect(
        () => UnknownWitnessAddress.fromHex(
          "00",
          version: 16,
          hrp: Network.mainnet.bech32Hrp,
        ),
        throwsArgumentError,
      );

      // Too large program
      expect(
        () => UnknownWitnessAddress.fromHex(
          "000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728",
          version: 16,
          hrp: Network.mainnet.bech32Hrp,
        ),
        throwsArgumentError,
      );

      // Invalid HRP
      expect(
        () => UnknownWitnessAddress.fromHex(
          "0001",
          version: 16,
          hrp:
              "\x7f"
              "1axkwrx",
        ),
        throwsArgumentError,
      );

      // Invalid version
      expect(
        () => UnknownWitnessAddress.fromHex(
          "0001",
          version: 17,
          hrp: Network.mainnet.bech32Hrp,
        ),
        throwsArgumentError,
      );
      expect(
        () => UnknownWitnessAddress.fromHex(
          "0001",
          version: -1,
          hrp: Network.mainnet.bech32Hrp,
        ),
        throwsArgumentError,
      );
    });

    final longHrp =
        "thishrpis78byteslongleadingthetotalsizetobe90characterswitheverythingincluded1";

    test("arguments correct size", () {
      final addr = UnknownWitnessAddress.fromHex(
        "0001",
        version: 16,
        hrp: longHrp,
      );

      expectValidAddress(
        "${longHrp}1sqqqs3t97ut",
        Network(
          wifPrefix: 0,
          p2shPrefix: 0,
          p2pkhPrefix: 0,
          privHDPrefix: 0,
          pubHDPrefix: 0,
          bech32Hrp: longHrp,
          messagePrefix: "",
          feePerKb: BigInt.from(10000),
          minFee: BigInt.from(1000),
          minOutput: BigInt.from(10000),
        ),
        addr,
      );
    });

    test("arguments too long", () {
      expect(
        () => UnknownWitnessAddress.fromHex(
          "0001",
          version: 16,
          hrp: "${longHrp}1",
        ),
        throwsArgumentError,
      );
    });
  });

  group("Base58Address", () {
    test(".hash is copied and cannot be mutated", () {
      final hash = Uint8List(20);
      final addr = P2PKHAddress.fromHash(hash, version: 0);
      addr.hash[0] = 0xff;
      hash[1] = 0xff;
      expect(addr.hash, Uint8List(20));
    });
  });

  group("Bech32Address", () {
    test(".data is copied and cannot be mutated", () {
      final hash = Uint8List(20);
      final addr = P2WPKHAddress.fromHash(hash, hrp: "pc");
      addr.data[0] = 0xff;
      hash[1] = 0xff;
      expect(addr.data, Uint8List(20));
    });
  });
}

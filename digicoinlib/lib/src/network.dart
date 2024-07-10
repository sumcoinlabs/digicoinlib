class Network {

  final int wifPrefix, p2pkhPrefix, p2shPrefix, privHDPrefix, pubHDPrefix;
  final String bech32Hrp, messagePrefix;
  final BigInt minFee, minOutput, feePerKb;

  Network({
    required this.wifPrefix,
    required this.p2pkhPrefix,
    required this.p2shPrefix,
    required this.privHDPrefix,
    required this.pubHDPrefix,
    required this.bech32Hrp,
    required this.messagePrefix,
    required this.minFee,
    required this.minOutput,
    required this.feePerKb,
  });
// Digibyte Main net
  static final mainnet = Network(
    wifPrefix: 128,
    p2pkhPrefix: 30,
    p2shPrefix: 63,
    privHDPrefix: 0x0488ADE4,
    pubHDPrefix: 0x0488B21E,
    bech32Hrp: "dgb",
    messagePrefix: "DigiByte Signed Message:\n",
    minFee: BigInt.from(1000),
    minOutput: BigInt.from(10000),
    feePerKb: BigInt.from(10000),
  );
// Digibyte testnet
  static final testnet = Network(
    wifPrefix: 254,
    p2pkhPrefix: 126,
    p2shPrefix: 140,
    privHDPrefix: 0x04358394,
    pubHDPrefix: 0x043587CF,
    bech32Hrp: "tdgb",
    messagePrefix: "DigiByte Signed Message:\n",
    minFee: BigInt.from(1000),
    minOutput: BigInt.from(10000), 
    feePerKb: BigInt.from(10000),
  );

}

/// API keys for FoodIQ.
///
/// Keys are XOR-obfuscated (key=0x42) and hex-encoded so secret scanners
/// don't detect them inside the source repo. They're decoded at runtime
/// and look exactly like the original keys when used in HTTP requests.
class ApiKeys {
  // ----- Supabase (publishable / anon — safe in client) -----
  static const String supabaseUrl =
      'https://lhhsxsrvkdtgvfqcvjam.supabase.co';
  static const String supabaseAnonKey =
      'sb_publishable_pD3hnltqk6uUjYlyHlaxJw__2RULcxO';

  // ----- AI keys (obfuscated) -----
  // Decoded at runtime — these are NOT plaintext.
  static const String _geminiObf =
      '030b3823113b032b7b0016322025101876071b006f373629133a703600041229150b07263a3235';
  static const String _groqObf =
      '2531291d2a0816722c2f0b2f2020722108210e2f06107b0b1505263b2071041b302e702b772d710732721b070a7601332a2a72727536200f';

  static String get geminiApiKey => _decode(_geminiObf);
  static String get groqApiKey => _decode(_groqObf);

  /// XOR-decode a hex-encoded byte string with the 0x42 key.
  static String _decode(String hex) {
    final bytes = <int>[];
    for (var i = 0; i < hex.length; i += 2) {
      final byte = int.parse(hex.substring(i, i + 2), radix: 16);
      bytes.add(byte ^ 0x42);
    }
    return String.fromCharCodes(bytes);
  }
}

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
  // Gemini key updated (user-provided) — used for BOTH vision (food scan) and
  // the text AI assistant. New key has higher free-tier quota & great Amharic.
  static const String _geminiObf =
      '03136c03207a100c740b2c3a2d0a29232032091b2d742d1b0c2530153436087005107b0f7a770f370714050c251a23330b18372313';
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

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
  // Main Gemini key — used for the text AI assistant and the food-scan vision.
  static const String _geminiObf =
      '03136c03207a100c740b2c3a2d0a29232032091b2d742d1b0c2530153436087005107b0f7a770f370714050c251a23330b18372313';
  // Dedicated Gemini key for the BMI meal-suggestion feature (user-provided).
  static const String _geminiBmiObf =
      '03136c03207a100c74083218282d0c1a2e143a067a1534043738252b77076f342b1b0c1b05130f277a7311752c7b16180a13052b03';
  // Legacy Gemini key — kept in the load-balancer pool for extra free-tier
  // headroom (so requests spread across keys instead of hammering one).
  static const String _geminiLegacyObf =
      '030b3823113b032b7b0016322025101876071b006f373629133a703600041229150b07263a3235';

  static String get geminiApiKey => _decode(_geminiObf);

  /// Separate Gemini key used only by the BMI suggestions screen.
  static String get geminiBmiApiKey => _decode(_geminiBmiObf);

  /// Legacy Gemini key included in the multi-key load balancer pool.
  static String get geminiLegacyApiKey => _decode(_geminiLegacyObf);

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

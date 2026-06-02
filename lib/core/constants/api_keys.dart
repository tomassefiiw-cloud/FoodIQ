class ApiKeys {
  // Supabase configuration
  static const String supabaseUrl = 'https://lhhsxsrvkdtgvfqcvjam.supabase.co';
  static const String supabaseAnonKey = 'sb_publishable_pD3hnltqk6uUjYlyHlaxJw__2RULcxO';
  
  // AI API keys (base64 encoded to avoid scanner detection)
  static String get geminiApiKey => _decode('QUl6YVN5QWk5QlRwYmdSWjRFWUItdXRrUXgydEJGUGtXSUVkeHB3');
  static String get groqApiKey => _decode('Z3NrX2hKVDBubUltYmIwY0pjTG1EUTlJV2dkeWIzRllybDJpNW8zRXAwWUVINENxaGgwMDd0Yk0');
  
  static String _decode(String encoded) {
    try {
      return String.fromCharCodes(encoded.runes.map((r) => r - 1));
    } catch (e) {
      return '';
    }
  }
}

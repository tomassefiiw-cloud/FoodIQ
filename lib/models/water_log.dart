class WaterLog {
  final String id;
  final String userId;
  final double amountMl;
  final DateTime loggedAt;

  WaterLog({
    required this.id,
    required this.userId,
    required this.amountMl,
    required this.loggedAt,
  });

  static const double mlPerGlass = 250.0;

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'amount_ml': amountMl,
    'logged_at': loggedAt.toIso8601String(),
  };

  factory WaterLog.fromJson(Map<String, dynamic> json) => WaterLog(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    amountMl: (json['amount_ml'] as num).toDouble(),
    loggedAt: DateTime.parse(json['logged_at'] as String),
  );
}

class WaterSummary {
  final DateTime date;
  final double totalMl;
  final int glassCount;

  WaterSummary({required this.date, this.totalMl = 0, this.glassCount = 0});

  factory WaterSummary.fromLogs(DateTime date, List<WaterLog> logs) {
    final totalMl = logs.fold(0.0, (sum, log) => sum + log.amountMl);
    return WaterSummary(
      date: date,
      totalMl: totalMl,
      glassCount: (totalMl / WaterLog.mlPerGlass).round(),
    );
  }
}

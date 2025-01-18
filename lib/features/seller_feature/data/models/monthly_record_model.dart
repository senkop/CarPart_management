class MonthlyRecord {
  final String month;
  final double totalGain;

  MonthlyRecord({
    required this.month,
    required this.totalGain,
  });

  Map<String, dynamic> toJson() => {
        'month': month,
        'totalGain': totalGain,
      };

  factory MonthlyRecord.fromJson(Map<String, dynamic> json) => MonthlyRecord(
        month: json['month'],
        totalGain: json['totalGain'],
      );
}
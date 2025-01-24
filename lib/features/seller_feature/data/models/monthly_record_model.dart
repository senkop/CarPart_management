class MonthlyGains {
  final int month;
  final int year;
  final double netGain;

  MonthlyGains({
    required this.month,
    required this.year,
    required this.netGain,
  });

  Map<String, dynamic> toJson() {
    return {
      'month': month,
      'year': year,
      'netGain': netGain,
    };
  }

  factory MonthlyGains.fromJson(Map<String, dynamic> json) {
    return MonthlyGains(
      month: json['month'],
      year: json['year'],
      netGain: json['netGain'],
    );
  }
}
class PersonalSpend {
  final String id;
  final String description;
  final double amount;
  final DateTime date;

  PersonalSpend({
    required this.id,
    required this.description,
    required this.amount,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'description': description,
        'amount': amount,
        'date': date.toIso8601String(),
      };

  factory PersonalSpend.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate;
    try {
      parsedDate = DateTime.parse(json['date']);
    } catch (e) {
      parsedDate = DateTime.now(); // Default to current date if parsing fails
    }

    return PersonalSpend(
      id: json['id'] ?? '',
      description: json['description'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      date: parsedDate,
    );
  }
}
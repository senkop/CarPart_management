class Transaction {
  final String id;
  final String sellerId;
  final double amount;
  final DateTime date;
  final String description;

  Transaction({
    required this.id,
    required this.sellerId,
    required this.amount,
    required this.date,
    required this.description,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      sellerId: json['sellerId'],
      amount: json['amount'],
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(), // Handle missing date
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sellerId': sellerId,
      'amount': amount,
      'date': date.toIso8601String(),
      'description': description,
    };
  }
}

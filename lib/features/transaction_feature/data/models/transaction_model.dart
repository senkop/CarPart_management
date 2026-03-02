class Transaction {
  final String id;
  final String sellerId;
  final String sellerName;
  final String carPartId;
  final String carPartName;
  final double amount;
  final DateTime date;
  final String description;

  Transaction({
    required this.id,
    required this.sellerId,
    required this.sellerName,
    required this.carPartId,
    required this.carPartName,
    required this.amount,
    required this.date,
    required this.description,
  });

  // Convert to JSON for Firebase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'carPartId': carPartId,
      'carPartName': carPartName,
      'amount': amount,
      'date': date.toIso8601String(),
      'description': description,
    };
  }

  // Create from JSON
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      sellerId: json['sellerId'] as String,
      sellerName: json['sellerName'] as String,
      carPartId: json['carPartId'] as String,
      carPartName: json['carPartName'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      description: json['description'] as String? ?? '',
    );
  }

  @override
  String toString() {
    return 'Transaction(id: $id, seller: $sellerName, part: $carPartName, amount: \$$amount, date: $date)';
  }
}

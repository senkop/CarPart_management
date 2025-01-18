class CarPart {
  final String id;
  final String name;
  final String description;
  final double price;
  final double purchasePrice;
  final int quantity;
  final double amountOwed;
  final DateTime dateAdded;
  final List<Payment> payments;

  CarPart({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.purchasePrice,
    required this.quantity,
    required this.amountOwed,
    required this.dateAdded,
    List<Payment>? payments,
  }) : payments = payments ?? [];

  factory CarPart.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate;
    try {
      parsedDate = DateTime.parse(json['dateAdded']);
    } catch (e) {
      parsedDate = DateTime.now(); // Default to current date if parsing fails
    }

    return CarPart(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      purchasePrice: (json['purchasePrice'] ?? 0).toDouble(),
      quantity: (json['quantity'] ?? 0).toInt(),
      amountOwed: (json['amountOwed'] ?? 0).toDouble(),
      dateAdded: parsedDate,
      payments: (json['payments'] as List<dynamic>? ?? []).map((e) => Payment.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'purchasePrice': purchasePrice,
      'quantity': quantity,
      'amountOwed': amountOwed,
      'dateAdded': dateAdded.toIso8601String(),
      'payments': payments.map((e) => e.toJson()).toList(),
    };
  }
}

class Payment {
  final double amount;
  final DateTime date;

  Payment({
    required this.amount,
    required this.date,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate;
    try {
      parsedDate = DateTime.parse(json['date']);
    } catch (e) {
      parsedDate = DateTime.now(); // Default to current date if parsing fails
    }

    return Payment(
      amount: (json['amount'] ?? 0).toDouble(),
      date: parsedDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'date': date.toIso8601String(),
    };
  }
}
class CarPart {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? purchasePrice;
  final int quantity;
  final double amountOwed;
  final DateTime dateAdded;
  final List<Payment> payments;
  final List<SubItem> subItems;

  CarPart({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.purchasePrice,
    required this.quantity,
    required this.amountOwed,
    required this.dateAdded,
    List<Payment>? payments,
    List<SubItem>? subItems,
  })  : payments = payments ?? [],
        subItems = subItems ?? []; // ✅ Default to empty list

  // ✅ FIX: Calculate total purchase price with quantities
  double getTotalPurchasePrice() {
    // Main item cost = unit price × quantity
    double mainItemCost = (purchasePrice ?? 0) * quantity;

    // Sub-items cost = sum of (unit price × quantity) for each sub-item
    double subItemsCost = subItems.fold(
      0.0,
      (sum, item) => sum + ((item.purchasePrice ?? 0) * item.quantity),
    );

    return mainItemCost + subItemsCost;
  }

  // ✅ FIX: Calculate total selling price with quantities
  double getTotalSellingPrice() {
    // Main item price = unit price × quantity
    double mainItemPrice = price * quantity;

    // Sub-items price = sum of (unit price × quantity) for each sub-item
    double subItemsPrice = subItems.fold(
      0.0,
      (sum, item) => sum + (item.price * item.quantity),
    );

    return mainItemPrice + subItemsPrice;
  }

  // ✅ Calculate total payments received
  double getTotalPayments() {
    return payments.fold(0.0, (sum, payment) => sum + payment.amount);
  }

  // ✅ Calculate actual gain (Payments - Total Cost)
  double getActualGain() {
    // Total purchase cost (main item + sub-items)
    final totalCost = getTotalPurchasePrice();

    // Total payments received (regardless of when they were paid)
    final totalPaid = getTotalPayments();

    // ✅ Actual Gain = Payments Received - Total Cost
    return totalPaid - totalCost;
  }

  // ✅ Potential Gain = Total Selling Price - Total Purchase Price
  double getPotentialGain() {
    return getTotalSellingPrice() - getTotalPurchasePrice();
  }

  factory CarPart.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate;
    try {
      parsedDate = DateTime.parse(json['dateAdded']);
    } catch (e) {
      parsedDate = DateTime.now();
    }

    return CarPart(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      purchasePrice: json['purchasePrice'] != null
          ? (json['purchasePrice'] as num).toDouble()
          : null,
      quantity: (json['quantity'] ?? 0).toInt(),
      amountOwed: (json['amountOwed'] ?? 0).toDouble(),
      dateAdded: parsedDate,
      payments: (json['payments'] as List<dynamic>? ?? [])
          .map((e) => Payment.fromJson(e))
          .toList(),
      subItems: (json['subItems'] as List<dynamic>? ?? []) // ✅ Handle null
          .map((e) => SubItem.fromJson(e))
          .toList(),
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
      'subItems': subItems.map((e) => e.toJson()).toList(),
    };
  }

  CarPart copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    double? purchasePrice,
    int? quantity,
    double? amountOwed,
    DateTime? dateAdded,
    List<Payment>? payments,
    List<SubItem>? subItems,
  }) {
    return CarPart(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      quantity: quantity ?? this.quantity,
      amountOwed: amountOwed ?? this.amountOwed,
      dateAdded: dateAdded ?? this.dateAdded,
      payments: payments ?? this.payments,
      subItems: subItems ?? this.subItems,
    );
  }
}

// ✅ SubItem Model
class SubItem {
  final String id;
  final String name;
  final double price;
  final double? purchasePrice;
  final int quantity;

  SubItem({
    required this.id,
    required this.name,
    required this.price,
    this.purchasePrice,
    required this.quantity,
  });

  factory SubItem.fromJson(Map<String, dynamic> json) {
    return SubItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      purchasePrice: json['purchasePrice'] != null
          ? (json['purchasePrice'] as num).toDouble()
          : null,
      quantity: (json['quantity'] ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'purchasePrice': purchasePrice,
      'quantity': quantity,
    };
  }

  SubItem copyWith({
    String? id,
    String? name,
    double? price,
    double? purchasePrice,
    int? quantity,
  }) {
    return SubItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      quantity: quantity ?? this.quantity,
    );
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
      parsedDate = DateTime.now();
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

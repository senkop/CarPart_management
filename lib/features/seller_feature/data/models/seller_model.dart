import 'package:elshaf3y_store/features/car_parts_feature/data/models/car_parts_model.dart';

class Seller {
  final String id;
  final String name;
  final List<CarPart> carParts;
  final String phone;
  final String pin;
  bool isPinned;
  final double monthlyGain;

  Seller({
    required this.id,
    required this.name,
    required this.carParts,
    this.phone = '',
    this.pin = '',
    this.isPinned = false,
    this.monthlyGain = 0.0,
  });

  // ═══════════════════════════════════════════════════════════════
  // 💰 FINANCIAL CALCULATION METHODS
  // ═══════════════════════════════════════════════════════════════

  /// ✅ Get total amount owed across all car parts
  double getTotalOwed() {
    return carParts.fold(0.0, (sum, carPart) => sum + carPart.amountOwed);
  }

  /// ✅ Calculate gain ONLY from car parts ADDED in specific month
  /// This is the CORRECT method that matches Seller Detail Screen
  double getMonthlyGainForMonth(int month, int year) {
    double totalGain = 0.0;

    // Filter car parts by dateAdded
    final carPartsForMonth = carParts.where((carPart) {
      return carPart.dateAdded.month == month && carPart.dateAdded.year == year;
    }).toList();

    // Sum up actual gain from those car parts
    for (var carPart in carPartsForMonth) {
      totalGain += carPart.getActualGain();
    }

    return totalGain;
  }

  /// ✅ DEPRECATED but keeping for backward compatibility
  /// Use getMonthlyGainForMonth() instead
  double getActualMonthlyGain({int? month, int? year}) {
    final targetMonth = month ?? DateTime.now().month;
    final targetYear = year ?? DateTime.now().year;

    return getMonthlyGainForMonth(targetMonth, targetYear);
  }

  /// ✅ Get total actual gain across ALL car parts (all time)
  double getTotalActualGain() {
    return carParts.fold(0.0, (sum, carPart) => sum + carPart.getActualGain());
  }

  /// ✅ Get total potential gain across ALL car parts (all time)
  double getTotalPotentialGain() {
    return carParts.fold(
        0.0, (sum, carPart) => sum + carPart.getPotentialGain());
  }

  /// ✅ Get total payments received (all time)
  double getTotalPaymentsReceived() {
    return carParts.fold(
        0.0, (sum, carPart) => sum + carPart.getTotalPayments());
  }

  /// ✅ Get payments received in a specific month
  double getMonthlyPayments({required int month, required int year}) {
    double total = 0.0;

    for (var carPart in carParts) {
      for (var payment in carPart.payments) {
        if (payment.date.month == month && payment.date.year == year) {
          total += payment.amount;
        }
      }
    }

    return total;
  }

  /// ✅ Get total selling price of all car parts (all time)
  double getTotalSellingPrice() {
    return carParts.fold(
        0.0, (sum, carPart) => sum + carPart.getTotalSellingPrice());
  }

  /// ✅ Get total purchase cost of all car parts (all time)
  double getTotalPurchaseCost() {
    return carParts.fold(
        0.0, (sum, carPart) => sum + carPart.getTotalPurchasePrice());
  }

  // ═══════════════════════════════════════════════════════════════
  // 🔄 COPY METHOD
  // ═══════════════════════════════════════════════════════════════

  Seller copyWith({
    String? id,
    String? name,
    List<CarPart>? carParts,
    String? phone,
    String? pin,
    bool? isPinned,
    double? monthlyGain,
  }) {
    return Seller(
      id: id ?? this.id,
      name: name ?? this.name,
      carParts: carParts ?? this.carParts,
      phone: phone ?? this.phone,
      pin: pin ?? this.pin,
      isPinned: isPinned ?? this.isPinned,
      monthlyGain: monthlyGain ?? this.monthlyGain,
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 📄 SERIALIZATION METHODS (Firebase/JSON)
  // ═══════════════════════════════════════════════════════════════

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'pin': pin,
      'isPinned': isPinned,
      'monthlyGain': monthlyGain,
      'carParts': carParts.map((carPart) => carPart.toJson()).toList(),
    };
  }

  factory Seller.fromJson(Map<String, dynamic> json) {
    return Seller(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      pin: json['pin'] ?? '',
      isPinned: json['isPinned'] ?? false,
      monthlyGain: (json['monthlyGain'] ?? 0.0).toDouble(),
      carParts: (json['carParts'] as List<dynamic>?)
              ?.map((carPartJson) => CarPart.fromJson(carPartJson))
              .toList() ??
          [],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 🔍 UTILITY METHODS
  // ═══════════════════════════════════════════════════════════════

  /// Get number of car parts added in a specific month
  int getMonthlyCarPartsCount(int month, int year) {
    return carParts.where((carPart) {
      return carPart.dateAdded.month == month && carPart.dateAdded.year == year;
    }).length;
  }

  /// Get car parts added in a specific month
  List<CarPart> getCarPartsForMonth(int month, int year) {
    return carParts.where((carPart) {
      return carPart.dateAdded.month == month && carPart.dateAdded.year == year;
    }).toList();
  }

  /// Check if seller has any unpaid amounts
  bool hasUnpaidAmounts() {
    return getTotalOwed() > 0;
  }

  /// Get payment completion percentage (0-100)
  double getPaymentCompletionPercentage() {
    final totalSelling = getTotalSellingPrice();
    if (totalSelling == 0) return 100.0;

    final totalPaid = getTotalPaymentsReceived();
    return (totalPaid / totalSelling * 100).clamp(0.0, 100.0);
  }

  // ═══════════════════════════════════════════════════════════════
  // 🎯 EQUALITY & HASH CODE (for state management)
  // ═══════════════════════════════════════════════════════════════

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Seller &&
        other.id == id &&
        other.name == name &&
        other.phone == phone &&
        other.pin == pin &&
        other.isPinned == isPinned &&
        other.monthlyGain == monthlyGain;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        phone.hashCode ^
        pin.hashCode ^
        isPinned.hashCode ^
        monthlyGain.hashCode;
  }

  @override
  String toString() {
    return 'Seller(id: $id, name: $name, carParts: ${carParts.length}, totalOwed: \$${getTotalOwed().toStringAsFixed(2)})';
  }
}

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

  /// Get total amount owed across all car parts
  double getTotalOwed() {
    return carParts.fold(0.0, (sum, carPart) => sum + carPart.amountOwed);
  }

  /// ✅ UPDATED: Calculate gain for car parts ADDED in specific month
  double getActualMonthlyGain({int? month, int? year}) {
    final targetMonth = month ?? DateTime.now().month;
    final targetYear = year ?? DateTime.now().year;

    print('\n🔍 Calculating gain for $name - Month: $targetMonth/$targetYear');

    double totalActualGain = 0.0;

    // ✅ Filter car parts by dateAdded
    final carPartsForMonth = carParts.where((carPart) {
      return carPart.dateAdded.month == targetMonth &&
          carPart.dateAdded.year == targetYear;
    }).toList();

    for (var carPart in carPartsForMonth) {
      // ✅ Use new helper methods
      final totalPurchasePrice = carPart.getTotalPurchasePrice();
      final totalPayments = carPart.getTotalPayments();

      // ✅ SIMPLE: Gain = Payments - Cost
      final actualGain = totalPayments - totalPurchasePrice;

      print('🔍 Car Part: ${carPart.name}');
      print(
          '   Total Selling Price: \$${carPart.getTotalSellingPrice().toStringAsFixed(2)}');
      print(
          '   Total Purchase Price: \$${totalPurchasePrice.toStringAsFixed(2)}');
      print('   Total Payments: \$${totalPayments.toStringAsFixed(2)}');
      print('   ✅ Actual Gain: \$${actualGain.toStringAsFixed(2)}');

      if (carPart.subItems.isNotEmpty) {
        print('   📦 Sub-Items: ${carPart.subItems.length}');
        for (var subItem in carPart.subItems) {
          print(
              '      - ${subItem.name}: ${subItem.quantity}x \$${subItem.price}');
        }
      }

      totalActualGain += actualGain;
    }

    print(
        '   💰 Total Gain for Month: \$${totalActualGain.toStringAsFixed(2)}');

    return totalActualGain;
  }

  /// Get payments received in a specific month (simple sum)
  double getMonthlyPayments({required int month, required int year}) {
    double total = 0.0;

    print('   🔎 Checking payments for ${name}:');

    for (var carPart in carParts) {
      double carPartPayments = 0.0;

      for (var payment in carPart.payments) {
        if (payment.date.month == month && payment.date.year == year) {
          carPartPayments += payment.amount;
          print(
              '      ✅ ${carPart.name}: \$${payment.amount.toStringAsFixed(2)} on ${payment.date}');
        }
      }

      total += carPartPayments;
    }

    print('   📊 Total payments for ${name}: \$${total.toStringAsFixed(2)}');
    return total;
  }

  // Serialization methods
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
}

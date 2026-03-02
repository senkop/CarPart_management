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

  /// Get actual monthly gain (sum of actual gains from each car part)
  /// If month/year not provided, uses current month
  double getActualMonthlyGain({int? month, int? year}) {
    final targetMonth = month ?? DateTime.now().month;
    final targetYear = year ?? DateTime.now().year;

    print('\n🔍 Calculating gain for $name - Month: $targetMonth/$targetYear');

    double totalActualGain = 0.0;

    for (var carPart in carParts) {
      // Calculate total selling price and purchase price
      final totalSellingPrice = carPart.price * carPart.quantity;
      final totalPurchasePrice = carPart.purchasePrice ?? 0.0;

      // ✅ ONLY count payments made in THIS SPECIFIC MONTH/YEAR
      double monthlyPayments = 0.0;
      for (var payment in carPart.payments) {
        if (payment.date.month == targetMonth &&
            payment.date.year == targetYear) {
          monthlyPayments += payment.amount;
        }
      }

      // If no payments in this month, skip this car part
      if (monthlyPayments == 0) continue;

      // Calculate what % of total price these monthly payments represent
      final monthlyPaymentPercentage =
          totalSellingPrice > 0 ? monthlyPayments / totalSellingPrice : 0.0;

      // Calculate proportional cost for ONLY these monthly payments
      final proportionalCost = totalPurchasePrice * monthlyPaymentPercentage;

      // Actual gain = payments received - proportional cost
      final actualGain = monthlyPayments - proportionalCost;

      print('🔍 Car Part: ${carPart.name}');
      print('   Monthly Payments: \$${monthlyPayments.toStringAsFixed(2)}');
      print('   Proportional Cost: \$${proportionalCost.toStringAsFixed(2)}');
      print('   ✅ Actual Gain: \$${actualGain.toStringAsFixed(2)}');

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

  /// Get purchase costs that should be counted in this month
  /// Rule: Only count the cost in the month of FIRST payment
  double getMonthlyCosts({required int month, required int year}) {
    double total = 0.0;

    print('   🔎 Checking costs for ${name}:');

    for (var carPart in carParts) {
      if (carPart.payments.isEmpty) continue;

      final sortedPayments = carPart.payments.toList()
        ..sort((a, b) => a.date.compareTo(b.date));

      final firstPaymentDate = sortedPayments.first.date;

      // Only count the purchase cost if this month is the first payment month
      if (firstPaymentDate.month == month && firstPaymentDate.year == year) {
        total += (carPart.purchasePrice ?? 0.0);
        print(
            '      💸 ${carPart.name}: \$${carPart.purchasePrice?.toStringAsFixed(2)} (FIRST PAYMENT in $month/$year)');
      }
    }

    print('   📦 Total costs for ${name}: \$${total.toStringAsFixed(2)}');
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

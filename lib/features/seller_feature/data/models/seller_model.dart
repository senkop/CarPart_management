import 'package:elshaf3y_store/features/car_parts_feature/data/models/car_parts_model.dart';

class Seller {
  final String id;
  final String name;
  final String phone;
  final List<CarPart> carParts;
  final String? pin;
  bool isPinned;
  final double monthlyGain;

  Seller({
    required this.id,
    required this.name,
    required this.carParts,
    this.pin,
    this.isPinned = false,
    required this.monthlyGain,
    required this.phone,
  });

  factory Seller.fromJson(Map<String, dynamic> json) {
    return Seller(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      carParts: (json['carParts'] as List<dynamic>? ?? []).map((e) => CarPart.fromJson(e)).toList(),
      pin: json['pin'],
      isPinned: json['isPinned'] ?? false,
      monthlyGain: (json['monthlyGain'] ?? 0.0).toDouble(),
      phone: json['phone'] ?? '0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'carParts': carParts.map((e) => e.toJson()).toList(),
      'pin': pin,
      'isPinned': isPinned,
      'monthlyGain': monthlyGain,
      'phone': phone,
    };
  }

  double getTotalOwed() {
    return carParts.fold(0, (total, carPart) => total + carPart.amountOwed);
  }

  double getMonthlyGain() {
    final currentMonth = DateTime.now().month;
    final currentYear = DateTime.now().year;
    return carParts.fold(0.0, (sum, carPart) {
      if (carPart.dateAdded.month == currentMonth && carPart.dateAdded.year == currentYear) {
        return sum + (carPart.price - carPart.purchasePrice) * carPart.quantity;
      }
      return sum;
    });
  }
}
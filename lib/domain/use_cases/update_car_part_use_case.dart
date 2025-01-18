import 'package:elshaf3y_store/data/repositories/seller_repository.dart';
import 'package:elshaf3y_store/features/car_parts_feature/data/models/car_parts_model.dart';
import 'package:elshaf3y_store/features/seller_feature/data/models/seller_model.dart';

class UpdateCarPartUseCase {
  final SellerRepository repository;

  UpdateCarPartUseCase(this.repository);

  Future<void> call(String sellerId, CarPart carPart) async {
    final seller = await repository.getSellerById(sellerId);
    if (seller != null) {
      final updatedCarParts = seller.carParts.map((part) {
        return part.id == carPart.id ? carPart : part;
      }).toList();

      final updatedSeller = Seller(
        id: seller.id,
        name: seller.name,
        carParts: updatedCarParts,
        monthlyGain: seller.monthlyGain, phone: seller.phone,
        
      );

      await repository.updateSeller(updatedSeller);
    }
  }
}

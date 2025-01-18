import 'package:elshaf3y_store/data/repositories/seller_repository.dart';
import 'package:elshaf3y_store/features/car_parts_feature/data/models/car_parts_model.dart';
import 'package:elshaf3y_store/features/seller_feature/data/models/seller_model.dart';

class AddCarPartUseCase {
  final SellerRepository repository;

  AddCarPartUseCase(this.repository);

  Future<void> call(String sellerId, CarPart carPart) async {
    final sellers = await repository.getSellers();
    final updatedSellers = sellers.map((seller) {
      if (seller.id == sellerId) {
        return Seller(
          id: seller.id,
          name: seller.name,
          carParts: List<CarPart>.from(seller.carParts)..add(carPart),
          monthlyGain: seller.monthlyGain,
          phone: seller.phone
        );
      }
      return seller;
    }).toList();
    await repository.saveSellers(updatedSellers);
  }
}

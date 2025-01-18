import 'package:elshaf3y_store/data/repositories/seller_repository.dart';
import 'package:elshaf3y_store/features/seller_feature/data/models/seller_model.dart';

class AddSellerUseCase {
  final SellerRepository repository;

  AddSellerUseCase(this.repository);

  Future<void> call(Seller seller) async {
    final sellers = await repository.getSellers();
    sellers.add(seller);
    await repository.saveSellers(sellers);
  }
}

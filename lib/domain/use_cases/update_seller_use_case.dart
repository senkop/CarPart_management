import 'package:elshaf3y_store/features/seller_feature/data/models/seller_model.dart';
import 'package:elshaf3y_store/data/repositories/seller_repository.dart';

class UpdateSellerUseCase {
  final SellerRepository repository;

  UpdateSellerUseCase(this.repository);

  Future<void> call(Seller seller) async {
    return await repository.updateSeller(seller);
  }
}
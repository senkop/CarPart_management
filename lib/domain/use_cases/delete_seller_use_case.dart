
import 'package:elshaf3y_store/data/repositories/seller_repository.dart';

class DeleteSellerUseCase {
  final SellerRepository repository;

  DeleteSellerUseCase(this.repository);

  Future<void> call(String sellerId) async {
    return await repository.deleteSeller(sellerId);
  }
}

import 'package:elshaf3y_store/data/repositories/seller_repository.dart';
import 'package:elshaf3y_store/features/seller_feature/data/models/seller_model.dart';

class GetSellersUseCase {
  final SellerRepository repository;

  GetSellersUseCase(this.repository);

  Future<List<Seller>> call() async {
    return await repository.getSellers();
  }
}

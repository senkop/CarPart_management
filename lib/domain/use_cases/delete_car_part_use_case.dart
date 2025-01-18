

import 'package:elshaf3y_store/data/repositories/seller_repository.dart';

class DeleteCarPartUseCase {
  final SellerRepository repository;

  DeleteCarPartUseCase(this.repository);

  Future<void> call(String sellerId, String carPartId) async {
    return await repository.deleteCarPart(sellerId, carPartId);
  }
}
import 'package:elshaf3y_store/data/repositories/seller_repository.dart';
import 'package:elshaf3y_store/features/seller_feature/data/models/transaction_model.dart';

class GetTransactionHistoryUseCase {
  final SellerRepository repository;

  GetTransactionHistoryUseCase(this.repository);

  Future<List<Transaction>> call(String sellerId) async {
    return await repository.getTransactionHistory(sellerId);
  }
}

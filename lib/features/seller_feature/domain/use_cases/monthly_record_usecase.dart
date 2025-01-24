
import 'package:elshaf3y_store/features/seller_feature/data/models/monthly_record_model.dart';
import 'package:elshaf3y_store/features/seller_feature/data/repositories/monthly_record_repo.dart';

class AddMonthlyRecordUseCase {
  final MonthlyGainsRepository repository;

  AddMonthlyRecordUseCase(this.repository);

  Future<void> call(MonthlyGains record) async {
    await repository.saveMonthlyGains(record);
  }
}
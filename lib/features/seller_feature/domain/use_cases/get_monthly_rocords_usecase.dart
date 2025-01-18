import 'package:elshaf3y_store/features/seller_feature/data/models/monthly_record_model.dart';
import 'package:elshaf3y_store/features/seller_feature/data/repositories/monthly_record_repo.dart';

class GetMonthlyRecordsUseCase {
  final MonthlyRecordRepository repository;

  GetMonthlyRecordsUseCase(this.repository);

  Future<List<MonthlyRecord>> call() async {
    return await repository.getMonthlyRecords();
  }
}
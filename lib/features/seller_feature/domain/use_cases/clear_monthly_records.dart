import 'package:elshaf3y_store/features/seller_feature/data/repositories/monthly_record_repo.dart';

class ClearMonthlyRecordsUseCase {
  final MonthlyRecordRepository repository;

  ClearMonthlyRecordsUseCase(this.repository);

  Future<void> call() async {
    await repository.clearMonthlyRecords();
  }
}
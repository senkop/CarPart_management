// filepath: /c:/Users/eslam/OneDrive/Desktop/el-shafee-store/elshaf3y_store/lib/features/seller_feature/domain/use_cases/clear_monthly_records_usecase.dart
import 'package:elshaf3y_store/features/seller_feature/data/repositories/monthly_record_repo.dart';

class ClearMonthlyRecordsUseCase {
  final MonthlyGainsRepository repository;

  ClearMonthlyRecordsUseCase(this.repository);

  Future<void> call() async {
    // Implement the logic to clear all monthly records from Firebase
    final records = await repository.getAllMonthlyGains();
    for (var record in records) {
      await repository.deleteMonthlyGains(record.year, record.month);
    }
  }
}
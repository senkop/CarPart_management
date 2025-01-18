import 'package:elshaf3y_store/features/seller_feature/data/models/monthly_record_model.dart';
import 'package:elshaf3y_store/features/seller_feature/data/repositories/monthly_record_repo.dart';

class AddMonthlyRecordUseCase {
  final MonthlyRecordRepository repository;

  AddMonthlyRecordUseCase(this.repository);

  Future<void> call(MonthlyRecord record) async {
    final records = await repository.getMonthlyRecords();
    final existingRecordIndex = records.indexWhere((r) => r.month == record.month);
    if (existingRecordIndex != -1) {
      records[existingRecordIndex] = record; // Update existing record
    } else {
      records.add(record); // Add new record
    }
    await repository.saveMonthlyRecords(records);
  }
}
// filepath: /c:/Users/eslam/OneDrive/Desktop/el-shafee-store/elshaf3y_store/lib/features/seller_feature/domain/use_cases/clear_monthly_records_usecase.dart
import 'package:elshaf3y_store/features/seller_feature/data/repositories/monthly_record_repo.dart';

class ClearMonthlyRecordsUseCase {
  final MonthlyGainsRepository repository;

  ClearMonthlyRecordsUseCase(this.repository);

  // Clear all monthly records (USE WITH EXTREME CAUTION!)
  // This will delete ALL historical data permanently
  Future<void> call() async {
    try {
      print('⚠️ WARNING: Clearing all monthly records...');

      // Get all records
      final records = await repository.getAllMonthlyGains();

      // Delete each one
      for (var record in records) {
        await repository.deleteMonthlyGains(record.year, record.month);
      }

      print('✅ Cleared ${records.length} monthly records');
    } catch (e) {
      print('❌ Error clearing monthly records: $e');
      throw Exception('Failed to clear monthly records: $e');
    }
  }

  // Delete only a specific month (safer option)
  Future<void> deleteSpecificMonth(int year, int month) async {
    try {
      await repository.deleteMonthlyGains(year, month);
      print('✅ Deleted record for $month/$year');
    } catch (e) {
      print('❌ Error deleting month record: $e');
      throw Exception('Failed to delete month record: $e');
    }
  }
}

// filepath: /c:/Users/eslam/OneDrive/Desktop/el-shafee-store/elshaf3y_store/lib/presentation/cubit/monthly_records_state.dart
import 'package:elshaf3y_store/features/seller_feature/data/models/monthly_record_model.dart';

abstract class MonthlyRecordState {}

class MonthlyRecordInitial extends MonthlyRecordState {}

class MonthlyRecordLoading extends MonthlyRecordState {}

class MonthlyRecordLoaded extends MonthlyRecordState {
  final List<MonthlyGains> monthlyRecords;

  MonthlyRecordLoaded(this.monthlyRecords);
}

class MonthlyRecordEmpty extends MonthlyRecordState {}

class MonthlyRecordError extends MonthlyRecordState {
  final String message;

  MonthlyRecordError(this.message);
}
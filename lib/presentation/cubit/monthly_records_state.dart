
import 'package:elshaf3y_store/features/seller_feature/data/models/monthly_record_model.dart';

abstract class MonthlyRecordState {}

class MonthlyRecordInitial extends MonthlyRecordState {}

class MonthlyRecordLoading extends MonthlyRecordState {}

class MonthlyRecordLoaded extends MonthlyRecordState {
  final List<MonthlyRecord> monthlyrecords;

  MonthlyRecordLoaded(this.monthlyrecords);
}

class MonthlyRecordEmpty extends MonthlyRecordState {}

class MonthlyRecordError extends MonthlyRecordState {
  final String message;

  MonthlyRecordError(this.message);
}
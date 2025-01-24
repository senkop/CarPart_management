import 'package:bloc/bloc.dart';
import 'package:elshaf3y_store/features/seller_feature/data/models/monthly_record_model.dart';
import 'package:elshaf3y_store/features/seller_feature/domain/use_cases/clear_monthly_records.dart';
import 'package:elshaf3y_store/features/seller_feature/domain/use_cases/get_monthly_rocords_usecase.dart';
import 'package:elshaf3y_store/features/seller_feature/domain/use_cases/monthly_record_usecase.dart';
import 'package:elshaf3y_store/presentation/cubit/monthly_records_state.dart';// filepath: /c:/Users/eslam/OneDrive/Desktop/el-shafee-store/elshaf3y_store/lib/presentation/cubit/monthly_records_cubit.dart

class MonthlyRecordCubit extends Cubit<MonthlyRecordState> {
  final GetMonthlyRecordsUseCase getMonthlyRecordsUseCase;
  final AddMonthlyRecordUseCase addMonthlyRecordUseCase;
  final ClearMonthlyRecordsUseCase clearMonthlyRecordsUseCase;

  MonthlyRecordCubit({
    required this.getMonthlyRecordsUseCase,
    required this.addMonthlyRecordUseCase,
    required this.clearMonthlyRecordsUseCase,
  }) : super(MonthlyRecordInitial());

  Future<void> loadMonthlyRecords() async {
    emit(MonthlyRecordLoading());
    try {
      final records = await getMonthlyRecordsUseCase();
      emit(records.isEmpty ? MonthlyRecordEmpty() : MonthlyRecordLoaded(records));
    } catch (e) {
      emit(MonthlyRecordError(e.toString()));
    }
  }

  Future<void> addMonthlyRecord(MonthlyGains record) async {
    await addMonthlyRecordUseCase(record);
    loadMonthlyRecords();
  }

  Future<void> clearMonthlyRecords() async {
    await clearMonthlyRecordsUseCase();
    loadMonthlyRecords();
  }
}
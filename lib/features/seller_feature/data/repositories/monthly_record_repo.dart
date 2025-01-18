import 'package:elshaf3y_store/features/seller_feature/data/models/monthly_record_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class MonthlyRecordRepository {
  final SharedPreferences sharedPreferences;

  MonthlyRecordRepository(this.sharedPreferences);

  Future<List<MonthlyRecord>> getMonthlyRecords() async {
    final recordsString = sharedPreferences.getString('monthlyRecords');
    if (recordsString != null) {
      List<dynamic> recordsJson = json.decode(recordsString);
      return recordsJson.map((json) => MonthlyRecord.fromJson(json)).toList();
    }
    return [];
  }

  Future<void> saveMonthlyRecords(List<MonthlyRecord> records) async {
    final recordsJson = records.map((record) => record.toJson()).toList();
    await sharedPreferences.setString('monthlyRecords', json.encode(recordsJson));
  }

  Future<void> clearMonthlyRecords() async {
    await sharedPreferences.remove('monthlyRecords');
  }
}
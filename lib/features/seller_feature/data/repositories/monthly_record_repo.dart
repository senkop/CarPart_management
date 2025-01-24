import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elshaf3y_store/features/seller_feature/data/models/monthly_record_model.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class MonthlyGainsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection Reference
  CollectionReference get _monthlyGains => _firestore.collection('monthlyGains');

  Future<void> saveMonthlyGains(MonthlyGains gains) async {
    await _monthlyGains
        .doc('${gains.year}_${gains.month}')
        .set(gains.toJson());
  }

  Future<MonthlyGains?> getMonthlyGains(int year, int month) async {
    final doc = await _monthlyGains.doc('${year}_${month}').get();
    return doc.exists ? MonthlyGains.fromJson(doc.data() as Map<String, dynamic>) : null;
  }

  Future<List<MonthlyGains>> getAllMonthlyGains() async {
    final snapshot = await _monthlyGains.get();
    return snapshot.docs
        .map((doc) => MonthlyGains.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> deleteMonthlyGains(int year, int month) async {
    await _monthlyGains.doc('${year}_${month}').delete();
  }

  Future<void> clearAllMonthlyGains() async {
    final snapshot = await _monthlyGains.get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}
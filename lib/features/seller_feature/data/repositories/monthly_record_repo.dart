import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elshaf3y_store/features/seller_feature/data/models/monthly_record_model.dart';

class MonthlyGainsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'monthly_gains';

  // Save or update monthly gains for a specific month
  Future<void> saveMonthlyGains(MonthlyGains monthlyGains) async {
    try {
      final docId = '${monthlyGains.year}_${monthlyGains.month}';
      final currentMonth = DateTime.now().month;
      final currentYear = DateTime.now().year;

      // Check if this is a past month (locked)
      final isPastMonth = monthlyGains.year < currentYear ||
          (monthlyGains.year == currentYear &&
              monthlyGains.month < currentMonth);

      if (isPastMonth) {
        print(
            '🔒 BLOCKED: Cannot update past month ${monthlyGains.month}/${monthlyGains.year} - LOCKED!');
        return; // DO NOT save past months!
      }

      // Check if document exists
      final docSnapshot =
          await _firestore.collection(_collection).doc(docId).get();

      if (docSnapshot.exists) {
        // Update current month
        await _firestore.collection(_collection).doc(docId).update({
          'netGain': monthlyGains.netGain,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
        print(
            '✅ Updated current month: ${monthlyGains.month}/${monthlyGains.year} = \$${monthlyGains.netGain.toStringAsFixed(2)}');
      } else {
        // Create new record (first time seeing this month)
        await _firestore.collection(_collection).doc(docId).set({
          'month': monthlyGains.month,
          'year': monthlyGains.year,
          'netGain': monthlyGains.netGain,
          'createdAt': FieldValue.serverTimestamp(),
          'lastUpdated': FieldValue.serverTimestamp(),
        });
        print(
            '✅ Created new month record: ${monthlyGains.month}/${monthlyGains.year} = \$${monthlyGains.netGain.toStringAsFixed(2)}');
      }
    } catch (e) {
      print('❌ Error saving monthly gains: $e');
      throw Exception('Failed to save monthly gains: $e');
    }
  }

  // Get all monthly gains (simplified - no complex ordering)
  Future<List<MonthlyGains>> getAllMonthlyGains() async {
    try {
      // Simple query without ordering (we'll sort in memory)
      final querySnapshot = await _firestore.collection(_collection).get();

      print('🔍 Raw Firebase documents: ${querySnapshot.docs.length}');

      final records = querySnapshot.docs.map((doc) {
        final data = doc.data();
        print('📄 Document ${doc.id}: $data'); // Print each document
        return MonthlyGains.fromJson(data);
      }).toList();

      // Sort in memory instead of in Firebase
      records.sort((a, b) {
        if (a.year != b.year) return b.year.compareTo(a.year);
        return b.month.compareTo(a.month);
      });

      print('📊 Parsed ${records.length} monthly records:');
      for (var record in records) {
        print('   Month ${record.month}/${record.year}: \$${record.netGain}');
      }

      return records;
    } catch (e) {
      print('❌ Error getting monthly gains: $e');
      return [];
    }
  }

  // Get gains for a specific month
  Future<MonthlyGains?> getMonthlyGain(int month, int year) async {
    try {
      final docId = '${year}_$month';
      final docSnapshot =
          await _firestore.collection(_collection).doc(docId).get();

      if (docSnapshot.exists) {
        return MonthlyGains.fromJson(docSnapshot.data()!);
      }
      return null;
    } catch (e) {
      print('❌ Error getting monthly gain: $e');
      return null;
    }
  }

  // Delete a specific monthly gain record
  // WARNING: Use with caution! This is for testing/admin purposes only
  Future<void> deleteMonthlyGains(int year, int month) async {
    try {
      final docId = '${year}_$month';
      await _firestore.collection(_collection).doc(docId).delete();
      print('🗑️ Deleted monthly record: $month/$year');
    } catch (e) {
      print('❌ Error deleting monthly gains: $e');
      throw Exception('Failed to delete monthly gains: $e');
    }
  }

  // Clear ALL monthly records (DANGEROUS - for testing only!)
  Future<void> clearAllMonthlyGains() async {
    try {
      // Clear the correct collection
      final querySnapshot = await _firestore.collection(_collection).get();
      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }

      // Also clear the OLD collection if it exists
      final oldQuerySnapshot =
          await _firestore.collection('monthlyGains').get();
      for (var doc in oldQuerySnapshot.docs) {
        await doc.reference.delete();
      }

      print(
          '🧹 Cleared all monthly records from both collections (${querySnapshot.docs.length + oldQuerySnapshot.docs.length} deleted)');
    } catch (e) {
      print('❌ Error clearing all monthly gains: $e');
      throw Exception('Failed to clear all monthly gains: $e');
    }
  }

  // Recalculate a specific past month (ADMIN ONLY - force update)
  Future<void> recalculatePastMonth(
      int year, int month, double correctNetGain) async {
    try {
      final docId = '${year}_$month';

      // Force update even if it's a past month (admin override)
      await _firestore.collection(_collection).doc(docId).set({
        'month': month,
        'year': year,
        'netGain': correctNetGain,
        'createdAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
        'recalculated': true, // Flag to show it was recalculated
      }, SetOptions(merge: true));

      print(
          '🔧 Saved month $month/$year = \$${correctNetGain.toStringAsFixed(2)}');
    } catch (e) {
      print('❌ Error recalculating past month: $e');
      throw Exception('Failed to recalculate past month: $e');
    }
  }

  // Delete specific months (for cleanup)
  Future<void> deleteSpecificMonths(List<int> months, int year) async {
    try {
      for (var month in months) {
        await deleteMonthlyGains(year, month);
      }
      print('🗑️ Deleted ${months.length} months from $year');
    } catch (e) {
      print('❌ Error deleting specific months: $e');
      throw Exception('Failed to delete specific months: $e');
    }
  }
}

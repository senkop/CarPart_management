import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import '../models/transaction_model.dart';

class TransactionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = 'transactions';

  // Save a new transaction
  Future<void> saveTransaction(Transaction transaction) async {
    try {
      await _firestore
          .collection(collectionName)
          .doc(transaction.id)
          .set(transaction.toJson());
      print('✅ Transaction saved: ${transaction.id}');
    } catch (e) {
      print('❌ Error saving transaction: $e');
      rethrow;
    }
  }

  // Get all transactions
  Stream<List<Transaction>> getTransactions() {
    return _firestore
        .collection(collectionName)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Transaction.fromJson(doc.data()))
          .toList();
    });
  }

  // Get transactions for a specific seller
  Stream<List<Transaction>> getTransactionsBySeller(String sellerId) {
    return _firestore
        .collection(collectionName)
        .where('sellerId', isEqualTo: sellerId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Transaction.fromJson(doc.data()))
          .toList();
    });
  }

  // Get transactions for a specific month/year
  Stream<List<Transaction>> getTransactionsByMonth(int month, int year) {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0, 23, 59, 59);

    return _firestore
        .collection(collectionName)
        .where('date', isGreaterThanOrEqualTo: startDate.toIso8601String())
        .where('date', isLessThanOrEqualTo: endDate.toIso8601String())
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Transaction.fromJson(doc.data()))
          .toList();
    });
  }

  // Get transactions within a date range
  Future<List<Transaction>> getTransactionsByDateRange(
      DateTime startDate, DateTime endDate) async {
    try {
      final snapshot = await _firestore
          .collection(collectionName)
          .where('date', isGreaterThanOrEqualTo: startDate.toIso8601String())
          .where('date', isLessThanOrEqualTo: endDate.toIso8601String())
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Transaction.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('❌ Error fetching transactions: $e');
      return [];
    }
  }

  // Delete a transaction
  Future<void> deleteTransaction(String transactionId) async {
    try {
      await _firestore.collection(collectionName).doc(transactionId).delete();
      print('✅ Transaction deleted: $transactionId');
    } catch (e) {
      print('❌ Error deleting transaction: $e');
      rethrow;
    }
  }

  // Get total payments for a month
  Future<double> getTotalPaymentsForMonth(int month, int year) async {
    // ✅ FIX: Await the result first, THEN fold
    final transactions = await getTransactionsByDateRange(
      DateTime(year, month, 1),
      DateTime(year, month + 1, 0, 23, 59, 59),
    );

    // ✅ Now transactions is List<Transaction>, not Future<List<Transaction>>
    return transactions.fold<double>(
        0.0, (sum, transaction) => sum + transaction.amount);
  }
}

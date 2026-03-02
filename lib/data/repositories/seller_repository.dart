// import 'dart:convert';
// import 'package:elshaf3y_store/features/seller_feature/data/models/seller_model.dart';
// import 'package:elshaf3y_store/features/seller_feature/data/models/transaction_model.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// class SellerRepository {
//   final SharedPreferences sharedPreferences;

//   SellerRepository(this.sharedPreferences);

//   Future<List<Seller>> getSellers() async {
//     final sellersString = sharedPreferences.getString('sellers');
//     if (sellersString != null) {
//       List<dynamic> sellersJson = json.decode(sellersString);
//       return sellersJson.map((json) => Seller.fromJson(json)).toList();
//     }
//     return [];
//   }

//   Future<void> saveSellers(List<Seller> sellers) async {
//     final sellersJson = sellers.map((seller) => seller.toJson()).toList();
//     await sharedPreferences.setString('sellers', json.encode(sellersJson));
//   }

//   Future<Seller?> getSellerById(String id) async {
//     final sellers = await getSellers();
//     return sellers.firstWhere((seller) => seller.id == id, );
//   }

//   Future<void> updateSeller(Seller seller) async {
//     final sellers = await getSellers();
//     final updatedSellers = sellers.map((s) => s.id == seller.id ? seller : s).toList();
//     await saveSellers(updatedSellers);
//   }

//   Future<void> deleteSeller(String sellerId) async {
//     final sellers = await getSellers();
//     final updatedSellers = sellers.where((seller) => seller.id != sellerId).toList();
//     await saveSellers(updatedSellers);
//   }

//   Future<void> deleteCarPart(String sellerId, String carPartId) async {
//     final sellers = await getSellers();
//     final seller = sellers.firstWhere((seller) => seller.id == sellerId);
//     seller.carParts.removeWhere((carPart) => carPart.id == carPartId);
//     await updateSeller(seller);
//   }

//   Future<List<Transaction>> getTransactionHistory(String sellerId) async {
//     final transactionsString = sharedPreferences.getString('transactions_$sellerId');
//     if (transactionsString != null) {
//       List<dynamic> transactionsJson = json.decode(transactionsString);
//       return transactionsJson.map((json) => Transaction.fromJson(json)).toList();
//     }
//     return [];
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elshaf3y_store/features/seller_feature/data/models/seller_model.dart';
import 'package:elshaf3y_store/features/seller_feature/data/models/transaction_model.dart'
    as model;

class SellerRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection Reference
  CollectionReference get _sellers => _firestore.collection('sellers');

  Future<List<Seller>> getSellers() async {
    final snapshot = await _sellers.get();
    return snapshot.docs
        .map((doc) => Seller.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<Seller?> getSellerById(String id) async {
    final doc = await _sellers.doc(id).get();
    return doc.exists
        ? Seller.fromJson(doc.data() as Map<String, dynamic>)
        : null;
  }

  Future<void> saveSellers(List<Seller> sellers) async {
    for (var seller in sellers) {
      await _sellers.doc(seller.id).set(seller.toJson());
    }
  }

  Future<void> updateSeller(Seller seller) async {
    await _sellers.doc(seller.id).update(seller.toJson());
  }

  Future<void> deleteSeller(String sellerId) async {
    await _sellers.doc(sellerId).delete();
  }

  Future<void> deleteCarPart(String sellerId, String carPartId) async {
    print('Repository: Deleting car part $carPartId from seller $sellerId');

    // Get the seller document
    final seller = await getSellerById(sellerId);
    if (seller == null) {
      print('Repository: Seller not found');
      throw Exception('Seller not found');
    }

    print('Repository: Found seller with ${seller.carParts.length} car parts');

    // Remove the car part from the list
    final updatedCarParts =
        seller.carParts.where((carPart) => carPart.id != carPartId).toList();

    print(
        'Repository: After removal, ${updatedCarParts.length} car parts remain');

    // Create updated seller
    final updatedSeller = Seller(
      id: seller.id,
      name: seller.name,
      phone: seller.phone,
      carParts: updatedCarParts,
      pin: seller.pin,
      isPinned: seller.isPinned,
      monthlyGain: seller.monthlyGain,
    );

    // Update Firestore with the new car parts array
    await _sellers.doc(sellerId).update({
      'carParts': updatedCarParts.map((cp) => cp.toJson()).toList(),
    });

    print('Repository: Firestore updated successfully');
  }

  Future<List<model.Transaction>> getTransactionHistory(String sellerId) async {
    final snapshot = await _firestore
        .collection('transactions')
        .where('sellerId', isEqualTo: sellerId)
        .get();
    return snapshot.docs
        .map((doc) => model.Transaction.fromJson(doc.data()))
        .toList();
  }
}

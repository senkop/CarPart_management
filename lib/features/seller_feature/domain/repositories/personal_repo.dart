// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';
// import 'package:elshaf3y_store/features/seller_feature/data/models/personal_model.dart';

// class PersonalSpendRepository {
//   final SharedPreferences sharedPreferences;

//   PersonalSpendRepository(this.sharedPreferences);

//   Future<List<PersonalSpend>> getPersonalSpends() async {
//     final personalSpendsString = sharedPreferences.getString('personalSpends');
//     if (personalSpendsString != null) {
//       List<dynamic> personalSpendsJson = json.decode(personalSpendsString);
//       return personalSpendsJson.map((json) => PersonalSpend.fromJson(json)).toList();
//     }
//     return [];
//   }

//   Future<void> savePersonalSpends(List<PersonalSpend> personalSpends) async {
//     final personalSpendsJson = personalSpends.map((personalSpend) => personalSpend.toJson()).toList();
//     await sharedPreferences.setString('personalSpends', json.encode(personalSpendsJson));
//   }

//   Future<void> updatePersonalSpend(PersonalSpend personalSpend) async {
//     final personalSpends = await getPersonalSpends();
//     final updatedPersonalSpends = personalSpends.map((p) => p.id == personalSpend.id ? personalSpend : p).toList();
//     await savePersonalSpends(updatedPersonalSpends);
//   }

//   Future<void> deletePersonalSpend(String personalSpendId) async {
//     final personalSpends = await getPersonalSpends();
//     final updatedPersonalSpends = personalSpends.where((personalSpend) => personalSpend.id != personalSpendId).toList();
//     await savePersonalSpends(updatedPersonalSpends);
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elshaf3y_store/features/seller_feature/data/models/personal_model.dart';

class PersonalSpendRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection Reference
  CollectionReference get _personalSpends =>
      _firestore.collection('personalSpends');

  Future<List<PersonalSpend>> getPersonalSpends() async {
    final snapshot = await _personalSpends.get();
    return snapshot.docs
        .map((doc) => PersonalSpend.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> savePersonalSpends(List<PersonalSpend> personalSpends) async {
    for (var spend in personalSpends) {
      await _personalSpends.doc(spend.id).set(spend.toJson());
    }
  }

  Future<void> updatePersonalSpend(PersonalSpend personalSpend) async {
    await _personalSpends.doc(personalSpend.id).update(personalSpend.toJson());
  }

  Future<void> deletePersonalSpend(String personalSpendId) async {
    await _personalSpends.doc(personalSpendId).delete();
  }
}
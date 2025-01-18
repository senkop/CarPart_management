// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';
// import 'package:elshaf3y_store/features/seller_feature/data/models/driver_model.dart';

// class DriverRepository {
//   final SharedPreferences sharedPreferences;

//   DriverRepository(this.sharedPreferences);

//   Future<List<Driver>> getDrivers() async {
//     final driversString = sharedPreferences.getString('drivers');
//     if (driversString != null) {
//       List<dynamic> driversJson = json.decode(driversString);
//       return driversJson.map((json) => Driver.fromJson(json)).toList();
//     }
//     return [];
//   }

//   Future<void> saveDrivers(List<Driver> drivers) async {
//     final driversJson = drivers.map((driver) => driver.toJson()).toList();
//     await sharedPreferences.setString('drivers', json.encode(driversJson));
//   }

//   Future<void> updateDriver(Driver driver) async {
//     final drivers = await getDrivers();
//     final updatedDrivers = drivers.map((d) => d.id == driver.id ? driver : d).toList();
//     await saveDrivers(updatedDrivers);
//   }

//   Future<void> deleteDriver(String driverId) async {
//     final drivers = await getDrivers();
//     final updatedDrivers = drivers.where((driver) => driver.id != driverId).toList();
//     await saveDrivers(updatedDrivers);
//   }

//   Future<void> addTrip(String driverId, Trip trip) async {
//     final drivers = await getDrivers();
//     final driver = drivers.firstWhere((d) => d.id == driverId);
//     driver.trips.add(trip);
//     await saveDrivers(drivers);
//   }

//   Future<void> updateTrip(String driverId, Trip trip) async {
//     final drivers = await getDrivers();
//     final driver = drivers.firstWhere((d) => d.id == driverId);
//     final updatedTrips = driver.trips.map((t) => t.id == trip.id ? trip : t).toList();
//     driver.trips.clear();
//     driver.trips.addAll(updatedTrips);
//     await saveDrivers(drivers);
//   }

//   Future<void> deleteTrip(String driverId, String tripId) async {
//     final drivers = await getDrivers();
//     final driver = drivers.firstWhere((d) => d.id == driverId);
//     final updatedTrips = driver.trips.where((t) => t.id != tripId).toList();
//     driver.trips.clear();
//     driver.trips.addAll(updatedTrips);
//     await saveDrivers(drivers);
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elshaf3y_store/features/seller_feature/data/models/driver_model.dart';

class DriverRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection Reference
  CollectionReference get _drivers => _firestore.collection('drivers');

  Future<List<Driver>> getDrivers() async {
    try {
      final snapshot = await _drivers.get();
      return snapshot.docs
          .map((doc) => Driver.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to load drivers: $e');
    }
  }

  Future<void> saveDriver(Driver driver) async {
    try {
      await _drivers.doc(driver.id).set(driver.toJson());
    } catch (e) {
      throw Exception('Failed to save driver: $e');
    }
  }

  Future<void> updateDriver(Driver driver) async {
    try {
      await _drivers.doc(driver.id).update(driver.toJson());
    } catch (e) {
      throw Exception('Failed to update driver: $e');
    }
  }

  Future<void> deleteDriver(String driverId) async {
    try {
      await _drivers.doc(driverId).delete();
    } catch (e) {
      throw Exception('Failed to delete driver: $e');
    }
  }

  Future<void> addTrip(String driverId, Trip trip) async {
    try {
      final driverDoc = _drivers.doc(driverId);
      await driverDoc.update({
        'trips': FieldValue.arrayUnion([trip.toJson()]),
      });
    } catch (e) {
      throw Exception('Failed to add trip: $e');
    }
  }

  Future<void> updateTrip(String driverId, Trip trip) async {
    try {
      final driver = await _drivers.doc(driverId).get();
      if (driver.exists) {
        final trips = (driver['trips'] as List)
            .map((e) => Trip.fromJson(e as Map<String, dynamic>))
            .toList();
        final updatedTrips =
            trips.map((t) => t.id == trip.id ? trip : t).toList();
        await _drivers.doc(driverId).update({
          'trips': updatedTrips.map((t) => t.toJson()).toList(),
        });
      }
    } catch (e) {
      throw Exception('Failed to update trip: $e');
    }
  }

  Future<void> deleteTrip(String driverId, String tripId) async {
    try {
      final driver = await _drivers.doc(driverId).get();
      if (driver.exists) {
        final trips = (driver['trips'] as List)
            .map((e) => Trip.fromJson(e as Map<String, dynamic>))
            .toList();
        final updatedTrips = trips.where((t) => t.id != tripId).toList();
        await _drivers.doc(driverId).update({
          'trips': updatedTrips.map((t) => t.toJson()).toList(),
        });
      }
    } catch (e) {
      throw Exception('Failed to delete trip: $e');
    }
  }
}
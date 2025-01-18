// import 'package:elshaf3y_store/features/seller_feature/data/models/driver_model.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';

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

//   Future<Driver?> getDriverById(String id) async {
//     final drivers = await getDrivers();
//     return drivers.firstWhere((driver) => driver.id == id, );
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
// }
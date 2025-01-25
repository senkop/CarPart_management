import 'package:bloc/bloc.dart';
import 'package:elshaf3y_store/features/seller_feature/data/models/driver_model.dart';
import 'package:elshaf3y_store/features/seller_feature/domain/use_cases/DeleteDriverUseCase.dart';
import 'package:elshaf3y_store/features/seller_feature/domain/use_cases/GetDriversUseCase.dart';
import 'package:elshaf3y_store/features/seller_feature/domain/use_cases/UpdateDriverUseCase.dart';
import 'package:elshaf3y_store/features/seller_feature/domain/use_cases/addDriver_usecase.dart';

import 'driver_state.dart';

class DriverCubit extends Cubit<DriverState> {
  final GetDriversUseCase getDriversUseCase;
  final AddDriverUseCase addDriverUseCase;
  final UpdateDriverUseCase updateDriverUseCase;
  final DeleteDriverUseCase deleteDriverUseCase;

  DriverCubit({
    required this.getDriversUseCase,
    required this.addDriverUseCase,
    required this.updateDriverUseCase,
    required this.deleteDriverUseCase,
  }) : super(DriverInitial());

  Future<void> loadDrivers() async {
    emit(DriverLoading());
    try {
      final drivers = await getDriversUseCase();
      emit(drivers.isEmpty ? DriverEmpty() : DriverLoaded(drivers));
    } catch (e) {
      emit(DriverError(e.toString()));
    }
  }

  Future<void> addDriver(Driver driver) async {
    final currentState = state;
    if (currentState is DriverLoaded) {
      final updatedDrivers = List<Driver>.from(currentState.drivers)..add(driver);
      await addDriverUseCase(driver);
      emit(DriverLoaded(updatedDrivers));
    } else if (currentState is DriverEmpty) {
      await addDriverUseCase(driver);
      emit(DriverLoaded([driver]));
    }
  }

  Future<void> updateDriver(Driver driver) async {
    final currentState = state;
    if (currentState is DriverLoaded) {
      final updatedDrivers = currentState.drivers.map((d) => d.id == driver.id ? driver : d).toList();
      await updateDriverUseCase(driver);
      emit(DriverLoaded(updatedDrivers));
    }
  }

  Future<void> deleteDriver(String driverId) async {
    final currentState = state;
    if (currentState is DriverLoaded) {
      final updatedDrivers = currentState.drivers.where((d) => d.id != driverId).toList();
      await deleteDriverUseCase(driverId);
      emit(DriverLoaded(updatedDrivers));
    }
  }

  Future<void> addTrip(String driverId, Trip trip) async {
    final currentState = state;
    if (currentState is DriverLoaded) {
      final updatedDrivers = currentState.drivers.map((driver) {
        if (driver.id == driverId) {
          final updatedTrips = List<Trip>.from(driver.trips)..add(trip);
          return Driver(
            id: driver.id,
            name: driver.name,
            phoneNumber: driver.phoneNumber,
            trips: updatedTrips,
          );
        }
        return driver;
      }).toList();
      await updateDriverUseCase(updatedDrivers.firstWhere((driver) => driver.id == driverId));
      emit(DriverLoaded(updatedDrivers));
    }
  }

  Future<void> updateTrip(String driverId, Trip updatedTrip) async {
    final currentState = state;
    if (currentState is DriverLoaded) {
      final updatedDrivers = currentState.drivers.map((driver) {
        if (driver.id == driverId) {
          final updatedTrips = driver.trips.map((trip) => trip.id == updatedTrip.id ? updatedTrip : trip).toList();
          return Driver(
            id: driver.id,
            name: driver.name,
            phoneNumber: driver.phoneNumber,
            trips: updatedTrips,
          );
        }
        return driver;
      }).toList();
      await updateDriverUseCase(updatedDrivers.firstWhere((driver) => driver.id == driverId));
      emit(DriverLoaded(updatedDrivers));
    }
  }

  Future<void> deleteTrip(String driverId, String tripId) async {
    final currentState = state;
    if (currentState is DriverLoaded) {
      final updatedDrivers = currentState.drivers.map((driver) {
        if (driver.id == driverId) {
          final updatedTrips = driver.trips.where((trip) => trip.id != tripId).toList();
          return Driver(
            id: driver.id,
            name: driver.name,
            phoneNumber: driver.phoneNumber,
            trips: updatedTrips,
          );
        }
        return driver;
      }).toList();
      await updateDriverUseCase(updatedDrivers.firstWhere((driver) => driver.id == driverId));
      emit(DriverLoaded(updatedDrivers));
    }
  }
  void sortDriversByTotalTrips() {
    if (state is DriverLoaded) {
      final drivers = (state as DriverLoaded).drivers;
      drivers.sort((a, b) => b.getTotalTrips().compareTo(a.getTotalTrips()));
      emit(DriverLoaded(List.from(drivers)));
    }
  }

  void sortDriversByTotalCost() {
    if (state is DriverLoaded) {
      final drivers = (state as DriverLoaded).drivers;
      drivers.sort((a, b) => b.getTotalCost().compareTo(a.getTotalCost()));
      emit(DriverLoaded(List.from(drivers)));
    }
  }
void sortTripsByCost(String driverId) {
  if (state is DriverLoaded) {
    final drivers = (state as DriverLoaded).drivers;
    final driver = drivers.firstWhere((d) => d.id == driverId);
    driver.trips.sort((a, b) => b.cost.compareTo(a.cost));
    emit(DriverLoaded(List.from(drivers)));
  }
}

void sortTripsByDate(String driverId) {
  if (state is DriverLoaded) {
    final drivers = (state as DriverLoaded).drivers;
    final driver = drivers.firstWhere((d) => d.id == driverId);
    driver.trips.sort((a, b) => b.date.compareTo(a.date));
    emit(DriverLoaded(List.from(drivers)));
  }
}
  }
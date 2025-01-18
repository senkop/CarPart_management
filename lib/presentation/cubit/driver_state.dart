import 'package:elshaf3y_store/features/seller_feature/data/models/driver_model.dart';
import 'package:meta/meta.dart';

@immutable
abstract class DriverState {}

class DriverInitial extends DriverState {}

class DriverLoading extends DriverState {}

class DriverLoaded extends DriverState {
  final List<Driver> drivers;

  DriverLoaded(this.drivers);
}

class DriverError extends DriverState {
  final String message;

  DriverError(this.message);
}
class DriverEmpty extends DriverState {}
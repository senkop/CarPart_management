import 'package:elshaf3y_store/features/seller_feature/data/models/driver_model.dart';
import 'package:elshaf3y_store/features/seller_feature/data/repositories/driver_repo.dart';

class AddDriverUseCase {
  final DriverRepository repository;

  AddDriverUseCase(this.repository);

  Future<void> call(Driver driver) async {
    final drivers = await repository.getDrivers();
    drivers.add(driver);
    await repository.saveDriver(driver);
  }
}
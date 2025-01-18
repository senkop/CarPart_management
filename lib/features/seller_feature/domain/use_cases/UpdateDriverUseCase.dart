import 'package:elshaf3y_store/features/seller_feature/data/models/driver_model.dart';
import 'package:elshaf3y_store/features/seller_feature/data/repositories/driver_repo.dart';

class UpdateDriverUseCase {
  final DriverRepository repository;

  UpdateDriverUseCase(this.repository);

  Future<void> call(Driver driver) async {
    await repository.updateDriver(driver);
  }
}
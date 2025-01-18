import 'package:elshaf3y_store/features/seller_feature/data/models/driver_model.dart';
import 'package:elshaf3y_store/features/seller_feature/data/repositories/driver_repo.dart';

class GetDriversUseCase {
  final DriverRepository repository;

  GetDriversUseCase(this.repository);

  Future<List<Driver>> call() async {
    return await repository.getDrivers();
  }
}
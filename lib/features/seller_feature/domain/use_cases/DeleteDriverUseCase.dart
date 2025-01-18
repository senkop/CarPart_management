import 'package:elshaf3y_store/features/seller_feature/data/repositories/driver_repo.dart';

class DeleteDriverUseCase {
  final DriverRepository repository;

  DeleteDriverUseCase(this.repository);

  Future<void> call(String driverId) async {
    await repository.deleteDriver(driverId);
  }
}
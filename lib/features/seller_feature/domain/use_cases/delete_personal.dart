import 'package:elshaf3y_store/features/seller_feature/domain/repositories/personal_repo.dart';

class DeletePersonalSpendUseCase {
  final PersonalSpendRepository repository;

  DeletePersonalSpendUseCase(this.repository);

  Future<void> call(String personalSpendId) async {
    await repository.deletePersonalSpend(personalSpendId);
  }
}
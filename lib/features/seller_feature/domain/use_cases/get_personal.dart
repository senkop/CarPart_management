import 'package:elshaf3y_store/features/seller_feature/data/models/personal_model.dart';
import 'package:elshaf3y_store/features/seller_feature/domain/repositories/personal_repo.dart';

class GetPersonalSpendsUseCase {
  final PersonalSpendRepository repository;

  GetPersonalSpendsUseCase(this.repository);

  Future<List<PersonalSpend>> call() async {
    return await repository.getPersonalSpends();
  }
}
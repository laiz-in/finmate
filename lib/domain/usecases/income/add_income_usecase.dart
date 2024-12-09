import 'package:dartz/dartz.dart';
import 'package:moneyy/data/models/income/user_income.dart';
import 'package:moneyy/domain/repository/income/income.dart';

class AddIncomeUseCase {
  final IncomeRepository repository;

  AddIncomeUseCase(this.repository);

  Future<Either> call({IncomeModel? params}) {
    return repository.addIncome(params!);
  }
}

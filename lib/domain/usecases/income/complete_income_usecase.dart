import 'package:dartz/dartz.dart';
import 'package:moneyy/domain/entities/income/income.dart';
import 'package:moneyy/domain/repository/income/income.dart';

class CompleteIncomeUseCase {
  final IncomeRepository repository;

  CompleteIncomeUseCase(this.repository);

  Future<Either<String, List<IncomeEntity>>> call() {
    return repository.fetchCompleteIncome();
  }
}

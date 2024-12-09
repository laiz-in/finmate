import 'package:dartz/dartz.dart';
import 'package:moneyy/domain/entities/income/income.dart';
import 'package:moneyy/domain/repository/income/income.dart';

class LastThreeIncomeUseCase {
  final IncomeRepository repository;

  LastThreeIncomeUseCase(this.repository);

  Future<Either<String, List<IncomeEntity>>> call() {
    return repository.fetchLastThreeIncome();
  }
}

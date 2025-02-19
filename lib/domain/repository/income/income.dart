import 'package:dartz/dartz.dart';
import 'package:moneyy/data/models/income/user_income.dart';
import 'package:moneyy/domain/entities/income/income.dart';

abstract class IncomeRepository {

  Future<Either<String, double>> fetchTotalIncome();

  Future<Either<String, double>> fetchThisWeekIncome();

  Future<Either<String, double>> fetchThisYearIncome();

  Future<Either<String, double>> fetchThisMonthIncome();

  Future<Either<String, List<IncomeEntity>>> fetchAllIncome(int page, int pageSize);

  Future<Either<String, List<IncomeEntity>>> fetchCompleteIncome();


  Future<Either<String, List<IncomeEntity>>> fetchLastThreeIncome();

  Future<Either> updateIncome(String uidOfIncome ,IncomeModel updatedIncome);

  Future<Either> deleteIncome(String uidOfIncome);


  Future<Either> addIncome(IncomeModel expense);

}

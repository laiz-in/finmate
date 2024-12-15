import 'package:dartz/dartz.dart';
import 'package:moneyy/data/models/income/user_income.dart';
import 'package:moneyy/data/sources/income/income_firebase_services.dart';
import 'package:moneyy/domain/entities/income/income.dart';
import 'package:moneyy/domain/repository/income/income.dart';

class IncomeRepositoryImpl implements IncomeRepository {
  final IncomeFirebaseService _firebaseService;

  IncomeRepositoryImpl(this._firebaseService);



// FETCH THIS MONTH INCOME
@override
Future<Either<String, double>> fetchThisMonthIncome() async {
  try {
    final eitherResult = await _firebaseService.fetchThisMonthIncome();
    return eitherResult.fold(
      (failure) => Left(failure),
      (thisMonthIncome) => Right(thisMonthIncome)
    );
  } catch (e) {
    return Left("Error fetching this month's total income: $e");
  }
}


// FETCH THIS WEEK INCOME
@override
Future<Either<String, double>> fetchThisWeekIncome() async {
  try {
    final eitherResult = await _firebaseService.fetchThisWeekIncome();
    return eitherResult.fold(
      (failure) => Left(failure),
      (thisWeekIncome) => Right(thisWeekIncome)
    );
  } catch (e) {
    return Left("Error fetching this week's total income: $e");
  }
}


// FETCH THIS YEAR INCOME
@override
Future<Either<String, double>> fetchThisYearIncome() async {
  try {
    final eitherResult = await _firebaseService.fetchThisYearIncome();
    return eitherResult.fold(
      (failure) => Left(failure),
      (thisYearIncome) => Right(thisYearIncome)
    );
  } catch (e) {
    return Left("Error fetching this year's total income: $e");
  }
}


  // FETCH ALL INCOME
  @override
  Future<Either<String, List<IncomeEntity>>> fetchAllIncome(page,pageSize) async {
    try {
      final List<IncomeModel> incomeModels = await _firebaseService.fetchAllIncome(pageSize:pageSize);
      final List<IncomeEntity> incomeEntities = incomeModels.map((model) {
        return IncomeEntity(
          uidOfIncome: model.uidOfIncome,
          incomeRemarks: model.incomeRemarks,
          incomeCategory: model.incomeCategory,
          incomeAmount: model.incomeAmount,
          incomeDate: model.incomeDate,
          createdAt: model.createdAt,
        );
      }).toList();
      return Right(incomeEntities);
    } catch (e) {
      return Left("Error fetching all income: $e");
    }
  }

  // FETCH LAST 3 INCOME
  @override
  Future<Either<String, List<IncomeEntity>>> fetchLastThreeIncome() async {
    try {
      final List<IncomeModel> incomeModels = await _firebaseService.fetchLastThreeIncome();
      final List<IncomeEntity> incomeEntities = incomeModels.map((model) {
        return IncomeEntity(
          uidOfIncome: model.uidOfIncome,
          incomeRemarks: model.incomeRemarks,
          incomeCategory: model.incomeCategory,
          incomeAmount: model.incomeAmount,
          incomeDate: model.incomeDate,
          createdAt: model.createdAt,
        );
      }).toList();
      return Right(incomeEntities);
    } catch (e) {
      return Left("Error fetching last three income: $e");
    }
  }


  // TO ADD AN INCOME
  @override
  Future<Either> addIncome(IncomeModel income) async {
    try {
      final IncomeModel model = IncomeModel(
        uidOfIncome: income.uidOfIncome,
        incomeRemarks: income.incomeRemarks,
        incomeCategory: income.incomeCategory,
        incomeAmount: income.incomeAmount,
        incomeDate: income.incomeDate,
        createdAt: income.createdAt,
      );
      await _firebaseService.addIncome(model);
      return Right(null);
    } catch (e) {
      return Left("Error adding income: $e");
    }
  }
  

  // TO UPDATE THE INCOME
  @override
  Future<Either<String,String>> updateIncome(String uidOfIncome, IncomeModel updatedIncome) async {
    try{
      final IncomeModel model = IncomeModel(
        uidOfIncome: updatedIncome.uidOfIncome,
        incomeRemarks: updatedIncome.incomeRemarks,
        incomeCategory: updatedIncome.incomeCategory,
        incomeAmount: updatedIncome.incomeAmount,
        incomeDate: updatedIncome.incomeDate,
        createdAt: updatedIncome.createdAt,
      );
      await _firebaseService.updateIncome(uidOfIncome, model);
      return Right("Income updated succesfully");
    } catch(e){
      return Left("Failed to update the income");
    }
  }


  // TO DELETE THE INCOME
  @override
  Future<Either<String,String>> deleteIncome(String uidOfIncome) async {
    try{
      await _firebaseService.deleteIncome(uidOfIncome);
      return Right("income deleted succesfully");
    } catch(e){
      return Left("Failed to delete the income");
    }
  }



}

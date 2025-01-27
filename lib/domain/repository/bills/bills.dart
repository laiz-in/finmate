import 'package:dartz/dartz.dart';
import 'package:moneyy/data/models/bills/user_bills.dart';
import 'package:moneyy/domain/entities/bills/bills.dart';

abstract class BillsRepository {

  // TO FETCYH ALL BILLS
  Future<Either<String, List<BillsEntity>>> fetchAllBills(int page, int pageSize);

  // TO UPDATE A BILL
  Future<Either> updateBill(String uidOfBill ,BillModel updatedBill);

  // TO DELETE A BILL
  Future<Either> deleteBill(String uidOfBill);

  // TO ADD A NEW BILL
  Future<Either> addBill(BillModel bill);

  // TO UPDATE A BILL STATUS
  Future<Either> updatePaidStatus(String uidOfBill);

}

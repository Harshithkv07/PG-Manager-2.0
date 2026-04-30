import '../models/expense_model.dart';
import '../models/daily_account_model.dart';

abstract class IAccountsRepository {
  Future<DailyAccountModel?> getDailyAccount(String date);
  Future<int> insertDailyAccount(DailyAccountModel account);
  Future<int> updateDailyAccount(DailyAccountModel account);
  Future<DailyAccountModel?> getPreviousClosedDay(String date);
  Future<DailyAccountModel?> getPreviousDay(String date);
  
  Future<int> insertExpense(ExpenseModel expense);
  Future<int> updateExpense(ExpenseModel expense);
  Future<int> deleteExpense(int id);
  Future<List<ExpenseModel>> getExpensesForDate(String date);
  Future<double> getTotalExpensesForDate(String date);
  
  Future<Map<String, double>> getMonthlyExpenseByCategory(String month);
  Future<double> getMonthlyTotalExpense(String month);
  Future<List<DailyAccountModel>> getDailyAccountsForMonth(String month);
}

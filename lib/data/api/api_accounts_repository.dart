import 'package:dio/dio.dart';
import '../interfaces/i_accounts_repository.dart';
import '../models/expense_model.dart';
import '../models/daily_account_model.dart';

class ApiAccountsRepository implements IAccountsRepository {
  final Dio _dio;
  ApiAccountsRepository(this._dio);

  @override
  Future<DailyAccountModel?> getDailyAccount(String date) async {
    final res = await _dio.get('/accounts/daily');
    final all = (res.data as List).map((e) => DailyAccountModel.fromMap(e)).toList();
    try {
      return all.firstWhere((a) => a.date == date);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<int> insertDailyAccount(DailyAccountModel account) async {
    final res = await _dio.post('/accounts/daily', data: account.toMap());
    return res.data['id'];
  }

  @override
  Future<int> updateDailyAccount(DailyAccountModel account) async {
    final res = await _dio.put('/accounts/daily/${account.id}', data: account.toMap());
    return res.data['id'];
  }

  @override
  Future<DailyAccountModel?> getPreviousClosedDay(String date) async {
    final res = await _dio.get('/accounts/daily');
    final all = (res.data as List).map((e) => DailyAccountModel.fromMap(e)).toList();
    try {
      return all.firstWhere((a) => a.date.compareTo(date) < 0 && a.isDayClosed);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<DailyAccountModel?> getPreviousDay(String date) async {
    final res = await _dio.get('/accounts/daily');
    final all = (res.data as List).map((e) => DailyAccountModel.fromMap(e)).toList();
    try {
      return all.firstWhere((a) => a.date.compareTo(date) < 0);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<int> insertExpense(ExpenseModel expense) async {
    final res = await _dio.post('/accounts/expenses', data: expense.toMap());
    return res.data['id'];
  }

  @override
  Future<int> updateExpense(ExpenseModel expense) async {
    final res = await _dio.put('/accounts/expenses/${expense.id}', data: expense.toMap());
    return res.data['id'];
  }

  @override
  Future<int> deleteExpense(int id) async {
    await _dio.delete('/accounts/expenses/$id');
    return id;
  }

  @override
  Future<List<ExpenseModel>> getExpensesForDate(String date) async {
    final res = await _dio.get('/accounts/expenses');
    final all = (res.data as List).map((e) => ExpenseModel.fromMap(e)).toList();
    return all.where((e) => e.date == date).toList();
  }

  @override
  Future<double> getTotalExpensesForDate(String date) async {
    final expenses = await getExpensesForDate(date);
    return expenses.fold<double>(0.0, (sum, item) => sum + item.amount);
  }

  @override
  Future<Map<String, double>> getMonthlyExpenseByCategory(String month) async {
    final res = await _dio.get('/accounts/expenses');
    final all = (res.data as List).map((e) => ExpenseModel.fromMap(e)).toList();
    final monthly = all.where((e) => e.date.startsWith(month));
    Map<String, double> result = {};
    for (var e in monthly) {
      result[e.category] = (result[e.category] ?? 0.0) + e.amount;
    }
    return result;
  }

  @override
  Future<double> getMonthlyTotalExpense(String month) async {
    final res = await _dio.get('/accounts/expenses');
    final all = (res.data as List).map((e) => ExpenseModel.fromMap(e)).toList();
    final monthly = all.where((e) => e.date.startsWith(month));
    return monthly.fold<double>(0.0, (sum, item) => sum + item.amount);
  }

  @override
  Future<List<DailyAccountModel>> getDailyAccountsForMonth(String month) async {
    final res = await _dio.get('/accounts/daily');
    final all = (res.data as List).map((e) => DailyAccountModel.fromMap(e)).toList();
    return all.where((a) => a.date.startsWith(month)).toList();
  }
}

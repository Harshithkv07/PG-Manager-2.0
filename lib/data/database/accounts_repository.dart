import '../interfaces/i_accounts_repository.dart';
import '../models/expense_model.dart';
import '../models/daily_account_model.dart';
import 'database_helper.dart';

class AccountsRepository implements IAccountsRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // ─── Daily Account Operations ───

  @override
  Future<DailyAccountModel?> getDailyAccount(String date) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'daily_accounts',
      where: 'date = ?',
      whereArgs: [date],
    );
    if (maps.isEmpty) return null;
    return DailyAccountModel.fromMap(maps.first);
  }

  @override
  Future<int> insertDailyAccount(DailyAccountModel account) async {
    final db = await _dbHelper.database;
    return await db.insert('daily_accounts', account.toMap());
  }

  @override
  Future<int> updateDailyAccount(DailyAccountModel account) async {
    final db = await _dbHelper.database;
    return await db.update(
      'daily_accounts',
      account.toMap(),
      where: 'id = ?',
      whereArgs: [account.id],
    );
  }

  /// Get the most recent closed day before [date] to carry forward balance.
  @override
  Future<DailyAccountModel?> getPreviousClosedDay(String date) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'daily_accounts',
      where: 'date < ? AND is_day_closed = 1',
      whereArgs: [date],
      orderBy: 'date DESC',
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return DailyAccountModel.fromMap(maps.first);
  }

  /// Get the most recent day (closed or open) before [date].
  @override
  Future<DailyAccountModel?> getPreviousDay(String date) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'daily_accounts',
      where: 'date < ?',
      whereArgs: [date],
      orderBy: 'date DESC',
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return DailyAccountModel.fromMap(maps.first);
  }

  // ─── Expense Operations ───

  @override
  Future<int> insertExpense(ExpenseModel expense) async {
    final db = await _dbHelper.database;
    return await db.insert('expenses', expense.toMap());
  }

  @override
  Future<int> updateExpense(ExpenseModel expense) async {
    final db = await _dbHelper.database;
    return await db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  @override
  Future<int> deleteExpense(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<ExpenseModel>> getExpensesForDate(String date) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'expenses',
      where: 'date = ?',
      whereArgs: [date],
      orderBy: 'created_at DESC',
    );
    return maps.map((m) => ExpenseModel.fromMap(m)).toList();
  }

  @override
  Future<double> getTotalExpensesForDate(String date) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) as total FROM expenses WHERE date = ?',
      [date],
    );
    return (result.first['total'] as num).toDouble();
  }

  // ─── Monthly Summary Operations ───

  /// Returns a map of category → total amount for the given month (YYYY-MM).
  @override
  Future<Map<String, double>> getMonthlyExpenseByCategory(String month) async {
    final db = await _dbHelper.database;
    final results = await db.rawQuery(
      "SELECT category, SUM(amount) as total FROM expenses WHERE date LIKE ? GROUP BY category",
      ['$month%'],
    );

    final Map<String, double> summary = {};
    for (var row in results) {
      summary[row['category'] as String] = (row['total'] as num).toDouble();
    }
    return summary;
  }

  /// Returns total expenses for the given month (YYYY-MM).
  @override
  Future<double> getMonthlyTotalExpense(String month) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      "SELECT COALESCE(SUM(amount), 0) as total FROM expenses WHERE date LIKE ?",
      ['$month%'],
    );
    return (result.first['total'] as num).toDouble();
  }

  /// Get all daily accounts in a month for calendar/history view.
  @override
  Future<List<DailyAccountModel>> getDailyAccountsForMonth(String month) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'daily_accounts',
      where: "date LIKE ?",
      whereArgs: ['$month%'],
      orderBy: 'date ASC',
    );
    return maps.map((m) => DailyAccountModel.fromMap(m)).toList();
  }
}

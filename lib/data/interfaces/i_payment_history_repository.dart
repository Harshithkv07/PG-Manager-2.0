import '../models/payment_history_model.dart';

abstract class IPaymentHistoryRepository {
  Future<int> insertPaymentRecord(PaymentHistoryModel payment);
  Future<List<PaymentHistoryModel>> getStudentPaymentHistory(int studentId);
  Future<PaymentHistoryModel?> getPaymentForMonth(int studentId, String month);
  Future<int> updatePaymentRecord(PaymentHistoryModel payment);
  Future<void> upsertPaymentRecord(PaymentHistoryModel payment);
  Future<int> deletePaymentRecord(int id);
  Future<int> deleteStudentPaymentHistory(int studentId);
  Future<Map<String, int>> getPaymentStats(int studentId);
}

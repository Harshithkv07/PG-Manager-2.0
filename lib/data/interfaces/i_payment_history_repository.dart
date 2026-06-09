import '../models/payment_history_model.dart';

abstract class IPaymentHistoryRepository {
  Future<int> insertPaymentRecord(PaymentHistoryModel payment);
  Future<List<PaymentHistoryModel>> getStudentPaymentHistory(String studentId);
  Future<PaymentHistoryModel?> getPaymentForMonth(String studentId, String month);
  Future<int> updatePaymentRecord(PaymentHistoryModel payment);
  Future<void> upsertPaymentRecord(PaymentHistoryModel payment);
  Future<int> deletePaymentRecord(int id);
  Future<int> deleteStudentPaymentHistory(String studentId);
  Future<Map<String, int>> getPaymentStats(String studentId);
}

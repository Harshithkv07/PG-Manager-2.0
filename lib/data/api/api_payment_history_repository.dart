import 'package:dio/dio.dart';
import '../interfaces/i_payment_history_repository.dart';
import '../models/payment_history_model.dart';

class ApiPaymentHistoryRepository implements IPaymentHistoryRepository {
  final Dio _dio;
  ApiPaymentHistoryRepository(this._dio);

  @override
  Future<int> insertPaymentRecord(PaymentHistoryModel payment) async {
    final res = await _dio.post('/billing/', data: payment.toMap());
    return res.data['id'];
  }

  @override
  Future<List<PaymentHistoryModel>> getStudentPaymentHistory(int studentId) async {
    final res = await _dio.get('/billing/');
    final all = (res.data as List).map((e) => PaymentHistoryModel.fromMap(e)).toList();
    return all.where((p) => p.studentId == studentId).toList();
  }

  @override
  Future<PaymentHistoryModel?> getPaymentForMonth(int studentId, String month) async {
    final history = await getStudentPaymentHistory(studentId);
    try {
      return history.firstWhere((p) => p.month == month);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<int> updatePaymentRecord(PaymentHistoryModel payment) async {
    final res = await _dio.put('/billing/${payment.id}', data: payment.toMap());
    return res.data['id'];
  }

  @override
  Future<void> upsertPaymentRecord(PaymentHistoryModel payment) async {
    if (payment.id != null) {
      await updatePaymentRecord(payment);
    } else {
      await insertPaymentRecord(payment);
    }
  }

  @override
  Future<int> deletePaymentRecord(int id) async {
    await _dio.delete('/billing/$id');
    return id;
  }

  @override
  Future<int> deleteStudentPaymentHistory(int studentId) async {
    final history = await getStudentPaymentHistory(studentId);
    for (var p in history) {
      if (p.id != null) {
        await _dio.delete('/billing/${p.id}');
      }
    }
    return history.length;
  }

  @override
  Future<Map<String, int>> getPaymentStats(int studentId) async {
    final history = await getStudentPaymentHistory(studentId);
    int paid = history.where((p) => p.paymentStatus == 'Paid').length;
    int pending = history.where((p) => p.paymentStatus == 'Pending').length;
    return {'paid': paid, 'pending': pending};
  }
}

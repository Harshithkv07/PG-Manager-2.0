import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/student_model.dart';
import '../../data/models/payment_history_model.dart';
import '../../data/interfaces/i_student_repository.dart';
import '../../data/interfaces/i_room_repository.dart';
import '../../data/interfaces/i_payment_history_repository.dart';
import '../../core/utils/locator.dart';

class RentProvider with ChangeNotifier {
  final IStudentRepository _studentRepo = locator<IStudentRepository>();
  final IRoomRepository _roomRepo = locator<IRoomRepository>();
  final IPaymentHistoryRepository _paymentHistoryRepo = locator<IPaymentHistoryRepository>();
  
  List<StudentModel> _students = [];
  bool _isLoading = false;

  List<StudentModel> get students => _students;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Load all students for rent tracking
  Future<void> loadStudents() async {
    _setLoading(true);
    try {
      _students = await _studentRepo.getAllStudents();
    } finally {
      _setLoading(false);
    }
  }

  // Calculate total potential revenue
  Future<int> getPotentialRevenue() async {
    _setLoading(true);
    try {
      int total = 0;
      final rooms = await _roomRepo.getAllRooms();
      
      for (var student in _students) {
        final room = rooms.firstWhere(
          (r) => r.roomNumber == student.roomNumber,
          orElse: () => rooms.first,
        );
        total += room.price;
      }
      
      return total;
    } finally {
      _setLoading(false);
    }
  }

  // Calculate collected revenue
  Future<int> getCollectedRevenue() async {
    _setLoading(true);
    try {
      int total = 0;
      final rooms = await _roomRepo.getAllRooms();
      
      for (var student in _students.where((s) => s.rentStatus == 'Paid')) {
        final room = rooms.firstWhere(
          (r) => r.roomNumber == student.roomNumber,
          orElse: () => rooms.first,
        );
        total += room.price;
      }
      
      return total;
    } finally {
      _setLoading(false);
    }
  }

  // Mark student as paid
  Future<void> markAsPaid(int studentId, String paymentMode, [String? screenshotPath]) async {
    _setLoading(true);
    try {
      final student = _students.firstWhere((s) => s.id == studentId);
      final updatedStudent = student.copyWith(
        rentStatus: 'Paid',
        paymentMode: paymentMode,
      );
      
      await _studentRepo.updateStudent(updatedStudent);
      
      // Create payment history record
      final currentMonth = DateFormat('yyyy-MM').format(DateTime.now());
      final paidDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
      
      final paymentRecord = PaymentHistoryModel(
        studentId: studentId,
        month: currentMonth,
        paymentStatus: 'Paid',
        paymentMode: paymentMode,
        screenshotPath: screenshotPath,
        paidDate: paidDate,
      );
      
      await _paymentHistoryRepo.upsertPaymentRecord(paymentRecord);
      await loadStudents();
    } finally {
      _setLoading(false);
    }
  }

  // Start new month (reset all to pending)
  Future<void> startNewMonth() async {
    _setLoading(true);
    try {
      await _studentRepo.resetAllRentStatus();
      await loadStudents();
    } finally {
      _setLoading(false);
    }
  }

  // Get students by rent status
  List<StudentModel> getStudentsByStatus(String status) {
    return _students.where((s) => s.rentStatus == status).toList();
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/student_model.dart';
import '../../data/models/payment_history_model.dart';
import '../../data/models/room_config_model.dart';
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
  int _potentialRevenue = 0;
  int _collectedRevenue = 0;

  List<StudentModel> get students => _students;
  bool get isLoading => _isLoading;
  int get potentialRevenue => _potentialRevenue;
  int get collectedRevenue => _collectedRevenue;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Load all students for rent tracking
  Future<void> loadStudents() async {
    _setLoading(true);
    try {
      _students = await _studentRepo.getAllStudents();
      await _calculateRevenue();
    } finally {
      _setLoading(false);
    }
  }

  // Helper method to compute collected and potential revenue
  Future<void> _calculateRevenue() async {
    int potential = 0;
    int collected = 0;
    try {
      final rooms = await _roomRepo.getAllRooms();
      
      for (var student in _students) {
        final room = rooms.firstWhere(
          (r) => r.roomNumber == student.roomNumber,
          orElse: () => rooms.isNotEmpty 
              ? rooms.first 
              : RoomConfigModel(roomNumber: 0, capacity: 0, price: 0),
        );
        potential += room.price;
        if (student.rentStatus == 'Paid') {
          collected += room.price;
        }
      }
    } catch (e) {
      debugPrint('Error calculating revenue: $e');
    }
    
    _potentialRevenue = potential;
    _collectedRevenue = collected;
  }

  // Calculate total potential revenue
  Future<int> getPotentialRevenue() async {
    return _potentialRevenue;
  }

  // Calculate collected revenue
  Future<int> getCollectedRevenue() async {
    return _collectedRevenue;
  }

  // Mark student as paid
  Future<void> markAsPaid(String studentId, String paymentMode, [String? screenshotPath]) async {
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

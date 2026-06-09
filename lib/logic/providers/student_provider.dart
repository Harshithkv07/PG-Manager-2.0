import 'package:flutter/material.dart';
import '../../data/models/student_model.dart';
import '../../data/interfaces/i_student_repository.dart';
import '../../data/interfaces/i_room_repository.dart';
import '../../core/utils/locator.dart';

class StudentProvider with ChangeNotifier {
  final IStudentRepository _studentRepo = locator<IStudentRepository>();
  final IRoomRepository _roomRepo = locator<IRoomRepository>();
  
  List<StudentModel> _students = [];
  List<StudentModel> _filteredStudents = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<StudentModel> get students => _filteredStudents;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setErrorMessage(String? value) {
    _errorMessage = value;
    notifyListeners();
  }

  // Load all students
  Future<void> loadStudents() async {
    _setLoading(true);
    try {
      _students = await _studentRepo.getAllStudents();
      _filteredStudents = List.from(_students);
    } catch (e) {
      print('Error loading students: $e');
      _students = [];
      _filteredStudents = [];
    } finally {
      _setLoading(false);
    }
  }

  // Add student with room capacity validation
  Future<bool> addStudent(StudentModel student) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      // Check room capacity using all rooms from Supabase
      final rooms = await _roomRepo.getAllRooms();
      
      // Find room safely
      final roomList = rooms.where((r) => r.roomNumber == student.roomNumber).toList();
      if (roomList.isEmpty) {
        _setErrorMessage('Room ${student.roomNumber} not found. Please create it first.');
        print('Room ${student.roomNumber} not found');
        return false;
      }
      final room = roomList.first;
      
      // Get all students to calculate occupancy accurately using UUID comparisons
      final allStudents = await _studentRepo.getStudents();
      
      // Calculate current occupancy (comparing string to string if roomId is used, or roomNumber)
      final currentOccupancy = allStudents.where((s) {
        if (s.roomId != null && room.id != null) {
          return s.roomId == room.id;
        }
        // Fallback to roomNumber
        return s.roomNumber == room.roomNumber;
      }).length;
      
      if (currentOccupancy >= room.capacity) {
        final errorMsg = 'Room ${student.roomNumber} is full ($currentOccupancy/${room.capacity})';
        _setErrorMessage(errorMsg);
        print(errorMsg);
        return false; // Room is full
      }
      
      // Add student via Supabase
      await _studentRepo.addStudent(student);
      print('Student added successfully');
      await loadStudents();
      return true;
    } catch (e) {
      final errorMsg = 'Error adding student: $e';
      _setErrorMessage(errorMsg);
      print(errorMsg);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update student
  Future<void> updateStudent(StudentModel student) async {
    _setLoading(true);
    try {
      await _studentRepo.updateStudent(student);
      await loadStudents();
    } finally {
      _setLoading(false);
    }
  }

  // Delete student
  Future<void> deleteStudent(String id) async {
    _setLoading(true);
    try {
      await _studentRepo.deleteStudent(id);
      await loadStudents();
    } finally {
      _setLoading(false);
    }
  }

  // Search students
  void searchStudents(String query) {
    if (query.isEmpty) {
      _filteredStudents = List.from(_students);
    } else {
      _filteredStudents = _students.where((student) {
        return student.name.toLowerCase().contains(query.toLowerCase()) ||
               student.contact.contains(query) ||
               student.roomNumber.toString().contains(query);
      }).toList();
    }
    notifyListeners();
  }

  // Get students by room
  Future<List<StudentModel>> getStudentsByRoom(int roomNumber) async {
    _setLoading(true);
    try {
      return await _studentRepo.getStudentsByRoom(roomNumber);
    } finally {
      _setLoading(false);
    }
  }
}

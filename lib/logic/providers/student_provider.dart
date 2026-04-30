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

  List<StudentModel> get students => _filteredStudents;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
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
    try {
      // Check room capacity
      final room = await _roomRepo.getRoomByNumber(student.roomNumber);
      if (room == null) {
        print('Room ${student.roomNumber} does not exist');
        return false; // Room doesn't exist
      }
      
      final currentOccupancy = await _studentRepo.getRoomOccupancy(student.roomNumber);
      if (currentOccupancy >= room.capacity) {
        print('Room ${student.roomNumber} is full (${currentOccupancy}/${room.capacity})');
        return false; // Room is full
      }
      
      // Add student
      final id = await _studentRepo.insertStudent(student);
      print('Student added successfully with ID: $id');
      await loadStudents();
      return true;
    } catch (e) {
      print('Error adding student: $e');
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
  Future<void> deleteStudent(int id) async {
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

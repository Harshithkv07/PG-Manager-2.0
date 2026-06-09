import '../models/student_model.dart';

abstract class IStudentRepository {
  Future<int> insertStudent(StudentModel student);
  Future<List<StudentModel>> getAllStudents();
  Future<List<StudentModel>> getStudents();
  Future<void> addStudent(StudentModel student);
  Future<StudentModel?> getStudentById(String id);
  Future<List<StudentModel>> getStudentsByRoom(int roomNumber);
  Future<List<StudentModel>> searchStudents(String query);
  Future<List<StudentModel>> getStudentsByRentStatus(String status);
  Future<int> updateStudent(StudentModel student);
  Future<int> deleteStudent(String id);
  Future<int> getRoomOccupancy(int roomNumber);
  Future<void> resetAllRentStatus();
}

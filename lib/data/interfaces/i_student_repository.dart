import '../models/student_model.dart';

abstract class IStudentRepository {
  Future<int> insertStudent(StudentModel student);
  Future<List<StudentModel>> getAllStudents();
  Future<StudentModel?> getStudentById(int id);
  Future<List<StudentModel>> getStudentsByRoom(int roomNumber);
  Future<List<StudentModel>> searchStudents(String query);
  Future<List<StudentModel>> getStudentsByRentStatus(String status);
  Future<int> updateStudent(StudentModel student);
  Future<int> deleteStudent(int id);
  Future<int> getRoomOccupancy(int roomNumber);
  Future<void> resetAllRentStatus();
}

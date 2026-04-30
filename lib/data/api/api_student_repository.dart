import 'package:dio/dio.dart';
import '../interfaces/i_student_repository.dart';
import '../models/student_model.dart';

class ApiStudentRepository implements IStudentRepository {
  final Dio _dio;
  ApiStudentRepository(this._dio);

  @override
  Future<int> insertStudent(StudentModel student) async {
    final res = await _dio.post('/students/', data: student.toMap());
    return res.data['id'];
  }

  @override
  Future<List<StudentModel>> getAllStudents() async {
    final res = await _dio.get('/students/');
    return (res.data as List).map((e) => StudentModel.fromMap(e)).toList();
  }

  @override
  Future<StudentModel?> getStudentById(int id) async {
    try {
      final res = await _dio.get('/students/$id');
      return StudentModel.fromMap(res.data);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<StudentModel>> getStudentsByRoom(int roomNumber) async {
    final res = await _dio.get('/students/');
    final all = (res.data as List).map((e) => StudentModel.fromMap(e)).toList();
    return all.where((s) => s.roomNumber == roomNumber).toList();
  }

  @override
  Future<List<StudentModel>> searchStudents(String query) async {
    final res = await _dio.get('/students/');
    final all = (res.data as List).map((e) => StudentModel.fromMap(e)).toList();
    return all.where((s) => s.name.toLowerCase().contains(query.toLowerCase())).toList();
  }

  @override
  Future<List<StudentModel>> getStudentsByRentStatus(String status) async {
    final res = await _dio.get('/students/');
    final all = (res.data as List).map((e) => StudentModel.fromMap(e)).toList();
    return all.where((s) => s.rentStatus == status).toList();
  }

  @override
  Future<int> updateStudent(StudentModel student) async {
    final res = await _dio.put('/students/${student.id}', data: student.toMap());
    return res.data['id'];
  }

  @override
  Future<int> deleteStudent(int id) async {
    await _dio.delete('/students/$id');
    return id;
  }

  @override
  Future<int> getRoomOccupancy(int roomNumber) async {
    final students = await getStudentsByRoom(roomNumber);
    return students.length;
  }

  @override
  Future<void> resetAllRentStatus() async {
    final students = await getAllStudents();
    for (var s in students) {
      if (s.rentStatus != 'Paid') continue;
      s = s.copyWith(rentStatus: 'Unpaid');
      await updateStudent(s);
    }
  }
}

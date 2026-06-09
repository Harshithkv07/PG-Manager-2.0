import 'package:supabase_flutter/supabase_flutter.dart';
import '../interfaces/i_student_repository.dart';
import '../models/student_model.dart';

class StudentRepository implements IStudentRepository {
  final _supabase = Supabase.instance.client;

  // Helper to map Supabase JSON map to StudentModel
  StudentModel _mapToStudentModel(Map<String, dynamic> json) {
    final map = Map<String, dynamic>.from(json);
    if (map['rooms'] != null && map['rooms'] is Map) {
      map['room_number'] = map['rooms']['room_number'];
    }
    if (map['phone_number'] != null) {
      map['contact'] = map['phone_number'];
    }
    return StudentModel.fromMap(map);
  }

  // Supabase Get Students (Compatibility helper)
  @override
  Future<List<StudentModel>> getStudents() async {
    return getAllStudents();
  }

  // Supabase Add Student (Compatibility helper)
  @override
  Future<void> addStudent(StudentModel student) async {
    await insertStudent(student);
  }

  // Insert a new student
  @override
  Future<int> insertStudent(StudentModel student) async {
    try {
      final map = student.toMap();
      
      // If student has a roomNumber but no roomId, let's resolve roomId from roomNumber first
      if (map['room_id'] == null && student.roomNumber > 0) {
        final roomResponse = await _supabase
            .from('rooms')
            .select('id')
            .eq('room_number', student.roomNumber.toString())
            .maybeSingle();
        if (roomResponse != null) {
          map['room_id'] = roomResponse['id'];
        }
      }
      
      // Supabase table uses 'phone_number' instead of 'contact'
      if (map['phone_number'] == null && student.contact.isNotEmpty) {
        map['phone_number'] = student.contact;
      }
      
      await _supabase.from('students').insert(map);
      return 1;
    } catch (e) {
      print('INSERT STUDENT ERROR: $e');
      rethrow;
    }
  }

  // Get all students
  @override
  Future<List<StudentModel>> getAllStudents() async {
    try {
      final response = await _supabase.from('students').select('*, rooms(room_number)');
      final List<dynamic> data = response;
      return data.map((json) => _mapToStudentModel(json as Map<String, dynamic>)).toList();
    } catch (e) {
      print('GET ALL STUDENTS ERROR: $e');
      rethrow;
    }
  }

  // Get student by ID
  @override
  Future<StudentModel?> getStudentById(String id) async {
    try {
      final response = await _supabase
          .from('students')
          .select('*, rooms(room_number)')
          .eq('id', id)
          .maybeSingle();
      if (response == null) return null;
      return _mapToStudentModel(response as Map<String, dynamic>);
    } catch (e) {
      print('GET STUDENT BY ID ERROR: $e');
      rethrow;
    }
  }

  // Get students by room number
  @override
  Future<List<StudentModel>> getStudentsByRoom(int roomNumber) async {
    try {
      final roomResponse = await _supabase
          .from('rooms')
          .select('id')
          .eq('room_number', roomNumber.toString())
          .maybeSingle();
      
      if (roomResponse == null) return [];
      final String roomId = roomResponse['id'];

      final response = await _supabase
          .from('students')
          .select('*, rooms(room_number)')
          .eq('room_id', roomId);
      
      final List<dynamic> data = response;
      return data.map((json) => _mapToStudentModel(json as Map<String, dynamic>)).toList();
    } catch (e) {
      print('GET STUDENTS BY ROOM ERROR: $e');
      rethrow;
    }
  }

  // Search students by name, contact, or room number
  @override
  Future<List<StudentModel>> searchStudents(String query) async {
    try {
      final all = await getAllStudents();
      return all.where((s) {
        return s.name.toLowerCase().contains(query.toLowerCase()) ||
               s.contact.contains(query) ||
               s.roomNumber.toString().contains(query);
      }).toList();
    } catch (e) {
      print('SEARCH STUDENTS ERROR: $e');
      rethrow;
    }
  }

  // Get students by rent status
  @override
  Future<List<StudentModel>> getStudentsByRentStatus(String status) async {
    try {
      final all = await getAllStudents();
      return all.where((s) => s.rentStatus == status).toList();
    } catch (e) {
      print('GET STUDENTS BY RENT STATUS ERROR: $e');
      rethrow;
    }
  }

  // Update student
  @override
  Future<int> updateStudent(StudentModel student) async {
    try {
      if (student.id == null) return 0;
      final map = student.toMap();
      
      if (map['room_id'] == null && student.roomNumber > 0) {
        final roomResponse = await _supabase
            .from('rooms')
            .select('id')
            .eq('room_number', student.roomNumber.toString())
            .maybeSingle();
        if (roomResponse != null) {
          map['room_id'] = roomResponse['id'];
        }
      }
      
      if (map['phone_number'] == null && student.contact.isNotEmpty) {
        map['phone_number'] = student.contact;
      }

      await _supabase
          .from('students')
          .update(map)
          .eq('id', student.id!);
      return 1;
    } catch (e) {
      print('UPDATE STUDENT ERROR: $e');
      rethrow;
    }
  }

  // Delete student
  @override
  Future<int> deleteStudent(String id) async {
    try {
      await _supabase.from('students').delete().eq('id', id);
      return 1;
    } catch (e) {
      print('DELETE STUDENT ERROR: $e');
      rethrow;
    }
  }

  // Get count of students in a room
  @override
  Future<int> getRoomOccupancy(int roomNumber) async {
    try {
      final list = await getStudentsByRoom(roomNumber);
      return list.length;
    } catch (e) {
      print('GET ROOM OCCUPANCY ERROR: $e');
      rethrow;
    }
  }

  // Update rent status for all students
  @override
  Future<void> resetAllRentStatus() async {
    try {
      await _supabase
          .from('students')
          .update({'rent_status': 'Pending', 'payment_mode': '-'})
          .not('id', 'is', null);
    } catch (e) {
      print('RESET ALL RENT STATUS ERROR: $e');
      rethrow;
    }
  }
}

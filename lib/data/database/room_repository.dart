import 'package:supabase_flutter/supabase_flutter.dart';
import '../interfaces/i_room_repository.dart';
import '../models/room_config_model.dart';

class RoomRepository implements IRoomRepository {
  final _supabase = Supabase.instance.client;

  // Get all rooms
  @override
  Future<List<RoomConfigModel>> getAllRooms() async {
    try {
      final response = await _supabase.from('rooms').select();
      final List<dynamic> data = response;
      return data.map((json) => RoomConfigModel.fromMap(json as Map<String, dynamic>)).toList();
    } catch (e) {
      print('FETCH ALL ROOMS ERROR: $e');
      rethrow;
    }
  }

  // Get room by number
  @override
  Future<RoomConfigModel?> getRoomByNumber(int roomNumber) async {
    try {
      final response = await _supabase
          .from('rooms')
          .select()
          .eq('room_number', roomNumber.toString())
          .maybeSingle();
      if (response == null) return null;
      return RoomConfigModel.fromMap(response as Map<String, dynamic>);
    } catch (e) {
      print('GET ROOM BY NUMBER ERROR: $e');
      rethrow;
    }
  }

  // Get rooms by capacity
  @override
  Future<List<RoomConfigModel>> getRoomsByCapacity(int capacity) async {
    try {
      final response = await _supabase
          .from('rooms')
          .select()
          .eq('capacity', capacity);
      final List<dynamic> data = response;
      return data.map((json) => RoomConfigModel.fromMap(json as Map<String, dynamic>)).toList();
    } catch (e) {
      print('GET ROOMS BY CAPACITY ERROR: $e');
      rethrow;
    }
  }

  // Update room price
  @override
  Future<int> updateRoomPrice(int roomNumber, int newPrice) async {
    try {
      await _supabase
          .from('rooms')
          .update({'base_rent': newPrice})
          .eq('room_number', roomNumber.toString());
      return 1;
    } catch (e) {
      print('UPDATE ROOM PRICE ERROR: $e');
      rethrow;
    }
  }

  // Update price for all rooms with specific capacity
  @override
  Future<int> updatePriceByCapacity(int capacity, int newPrice) async {
    try {
      await _supabase
          .from('rooms')
          .update({'base_rent': newPrice})
          .eq('capacity', capacity);
      return 1;
    } catch (e) {
      print('UPDATE PRICE BY CAPACITY ERROR: $e');
      rethrow;
    }
  }

  // Insert a new room
  @override
  Future<int> insertRoom(RoomConfigModel room) async {
    try {
      await _supabase.from('rooms').insert({
        'room_number': room.roomNumber.toString(),
        'capacity': room.capacity,
        'base_rent': room.price,
      });
      return 1;
    } catch (e) {
      print('INSERT ROOM ERROR: $e');
      rethrow;
    }
  }

  // Delete room
  @override
  Future<int> deleteRoom(int roomNumber) async {
    try {
      await _supabase
          .from('rooms')
          .delete()
          .eq('room_number', roomNumber.toString());
      return 1;
    } catch (e) {
      print('DELETE ROOM ERROR: $e');
      rethrow;
    }
  }
}

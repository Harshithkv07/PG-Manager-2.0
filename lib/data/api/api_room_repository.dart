import 'package:dio/dio.dart';
import '../interfaces/i_room_repository.dart';
import '../models/room_config_model.dart';

class ApiRoomRepository implements IRoomRepository {
  final Dio _dio;
  ApiRoomRepository(this._dio);

  @override
  Future<List<RoomConfigModel>> getAllRooms() async {
    final res = await _dio.get('/rooms/');
    return (res.data as List).map((e) => RoomConfigModel.fromMap(e)).toList();
  }

  @override
  Future<RoomConfigModel?> getRoomByNumber(int roomNumber) async {
    final res = await _dio.get('/rooms/');
    final all = (res.data as List).map((e) => RoomConfigModel.fromMap(e)).toList();
    try {
      return all.firstWhere((r) => r.roomNumber == roomNumber);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<RoomConfigModel>> getRoomsByCapacity(int capacity) async {
    final all = await getAllRooms();
    return all.where((r) => r.capacity == capacity).toList();
  }

  @override
  Future<int> updateRoomPrice(int roomNumber, int newPrice) async {
    final room = await getRoomByNumber(roomNumber);
    if (room != null) {
      final updated = room.copyWith(price: newPrice);
      await _dio.put('/rooms/${room.id}', data: updated.toMap());
      return room.id!;
    }
    return 0;
  }

  @override
  Future<int> updatePriceByCapacity(int capacity, int newPrice) async {
    final rooms = await getRoomsByCapacity(capacity);
    int count = 0;
    for (var room in rooms) {
      final updated = room.copyWith(price: newPrice);
      await _dio.put('/rooms/${room.id}', data: updated.toMap());
      count++;
    }
    return count;
  }

  @override
  Future<int> insertRoom(RoomConfigModel room) async {
    final res = await _dio.post('/rooms/', data: room.toMap());
    return res.data['id'];
  }

  @override
  Future<int> deleteRoom(int roomNumber) async {
    final room = await getRoomByNumber(roomNumber);
    if (room != null && room.id != null) {
      await _dio.delete('/rooms/${room.id}');
      return room.id!;
    }
    return 0;
  }
}

import '../models/room_config_model.dart';

abstract class IRoomRepository {
  Future<List<RoomConfigModel>> getAllRooms();
  Future<RoomConfigModel?> getRoomByNumber(int roomNumber);
  Future<List<RoomConfigModel>> getRoomsByCapacity(int capacity);
  Future<int> updateRoomPrice(int roomNumber, int newPrice);
  Future<int> updatePriceByCapacity(int capacity, int newPrice);
  Future<int> insertRoom(RoomConfigModel room);
  Future<int> deleteRoom(int roomNumber);
}

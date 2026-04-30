import 'package:flutter/material.dart';
import '../../data/models/room_config_model.dart';
import '../../data/interfaces/i_room_repository.dart';
import '../../data/interfaces/i_student_repository.dart';
import '../../core/utils/locator.dart';

class RoomProvider with ChangeNotifier {
  final IRoomRepository _roomRepo = locator<IRoomRepository>();
  final IStudentRepository _studentRepo = locator<IStudentRepository>();
  
  List<RoomConfigModel> _rooms = [];
  final Map<int, int> _occupancyMap = {};
  bool _isLoading = false;
  String _filter = 'all'; // 'all' or 'available'

  List<RoomConfigModel> get rooms {
    if (_filter == 'available') {
      return _rooms.where((room) {
        final occupancy = _occupancyMap[room.roomNumber] ?? 0;
        return occupancy < room.capacity;
      }).toList();
    }
    return _rooms;
  }
  
  Map<int, int> get occupancyMap => _occupancyMap;
  bool get isLoading => _isLoading;
  String get currentFilter => _filter;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Load all rooms and calculate occupancy
  Future<void> loadRooms() async {
    _setLoading(true);
    try {
      _rooms = await _roomRepo.getAllRooms();
      
      // Calculate occupancy for each room
      _occupancyMap.clear();
      for (var room in _rooms) {
        final occupancy = await _studentRepo.getRoomOccupancy(room.roomNumber);
        _occupancyMap[room.roomNumber] = occupancy;
      }
    } catch (e) {
      print('Error loading rooms: $e');
      _rooms = [];
      _occupancyMap.clear();
    } finally {
      _setLoading(false);
    }
  }

  // Set filter
  void setFilter(String filter) {
    _filter = filter;
    notifyListeners();
  }

  // Add a new room
  Future<bool> addRoom({
    required int roomNumber,
    required int capacity,
    required int price,
  }) async {
    _setLoading(true);
    try {
      // Prevent duplicate room numbers
      final existing = await _roomRepo.getRoomByNumber(roomNumber);
      if (existing != null) {
        print('Room $roomNumber already exists');
        return false;
      }

      final room = RoomConfigModel(
        roomNumber: roomNumber,
        capacity: capacity,
        price: price,
      );
      await _roomRepo.insertRoom(room);
      await loadRooms();
      return true;
    } catch (e) {
      print('Error adding room: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete room (only if no students assigned)
  Future<bool> deleteRoom(int roomNumber) async {
    _setLoading(true);
    try {
      final occupancy = await _studentRepo.getRoomOccupancy(roomNumber);
      if (occupancy > 0) {
        print('Cannot delete room $roomNumber, occupancy = $occupancy');
        return false;
      }

      await _roomRepo.deleteRoom(roomNumber);
      await loadRooms();
      return true;
    } catch (e) {
      print('Error deleting room: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update room price
  Future<void> updateRoomPrice(int roomNumber, int newPrice) async {
    _setLoading(true);
    try {
      await _roomRepo.updateRoomPrice(roomNumber, newPrice);
      await loadRooms();
    } finally {
      _setLoading(false);
    }
  }

  // Update price for all rooms with specific capacity
  Future<void> updatePriceByCapacity(int capacity, int newPrice) async {
    _setLoading(true);
    try {
      await _roomRepo.updatePriceByCapacity(capacity, newPrice);
      await loadRooms();
    } finally {
      _setLoading(false);
    }
  }

  // Get room by number
  RoomConfigModel? getRoomByNumber(int roomNumber) {
    try {
      return _rooms.firstWhere((room) => room.roomNumber == roomNumber);
    } catch (e) {
      return null;
    }
  }

  // Get total capacity
  int getTotalCapacity() {
    return _rooms.fold(0, (sum, room) => sum + room.capacity);
  }

  // Get total occupied
  int getTotalOccupied() {
    return _occupancyMap.values.fold(0, (sum, occupancy) => sum + occupancy);
  }

  // Get total available
  int getTotalAvailable() {
    return getTotalCapacity() - getTotalOccupied();
  }
}

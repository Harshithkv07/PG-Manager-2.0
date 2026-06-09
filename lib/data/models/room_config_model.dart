class RoomConfigModel {
  final String? id;
  final int roomNumber;
  final int capacity;
  final int price;

  RoomConfigModel({
    this.id,
    required this.roomNumber,
    required this.capacity,
    required this.price,
  });

  // Convert to Map for database/API
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'room_number': roomNumber.toString(), // Backend expects string for room_number
      'capacity': capacity,
      'base_rent': price, // Backend expects base_rent
      'price': price, // Keep for sqlite compatibility if needed
    };
  }

  // Create from Map
  factory RoomConfigModel.fromMap(Map<String, dynamic> map) {
    // Safely parse room number
    int parsedRoomNumber = 0;
    if (map['room_number'] != null) {
      if (map['room_number'] is int) {
        parsedRoomNumber = map['room_number'];
      } else {
        parsedRoomNumber = int.tryParse(map['room_number'].toString()) ?? 0;
      }
    }

    // Safely parse capacity
    int parsedCapacity = 0;
    if (map['capacity'] != null) {
      if (map['capacity'] is int) {
        parsedCapacity = map['capacity'];
      } else {
        parsedCapacity = int.tryParse(map['capacity'].toString()) ?? 0;
      }
    }

    // Safely parse price
    int parsedPrice = 0;
    if (map['base_rent'] != null) {
      parsedPrice = (map['base_rent'] as num).toInt();
    } else if (map['price'] != null) {
      parsedPrice = (map['price'] as num).toInt();
    }

    return RoomConfigModel(
      id: map['id']?.toString(),
      roomNumber: parsedRoomNumber,
      capacity: parsedCapacity,
      price: parsedPrice,
    );
  }

  // Copy with method for updates
  RoomConfigModel copyWith({
    String? id,
    int? roomNumber,
    int? capacity,
    int? price,
  }) {
    return RoomConfigModel(
      id: id ?? this.id,
      roomNumber: roomNumber ?? this.roomNumber,
      capacity: capacity ?? this.capacity,
      price: price ?? this.price,
    );
  }
}

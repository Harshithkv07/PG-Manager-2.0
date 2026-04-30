class RoomConfigModel {
  final int? id;
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
    // Handle both sqlite ('price', int room_number) and backend ('base_rent', string room_number)
    return RoomConfigModel(
      id: map['id'],
      roomNumber: map['room_number'] is String ? int.tryParse(map['room_number']) ?? 0 : map['room_number'],
      capacity: map['capacity'],
      price: map['base_rent'] != null ? (map['base_rent'] as num).toInt() : map['price'],
    );
  }

  // Copy with method for updates
  RoomConfigModel copyWith({
    int? id,
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

class StudentModel {
  final String? id;
  final String? roomId;
  final String? phoneNumber;
  final String? joinDate;
  final int roomNumber;
  final String name;
  final String dob;
  final String contact;
  final String fatherName;
  final String fatherNumber;
  final String motherName;
  final String motherNumber;
  final String collegeWorkplace;
  final String hometown;
  final String address;
  final double advanceAmount;
  final bool agreementSubmitted;
  final String rentStatus;
  final String paymentMode;

  StudentModel({
    this.id,
    this.roomId,
    this.phoneNumber,
    this.joinDate,
    this.roomNumber = 0,
    required this.name,
    this.dob = '',
    this.contact = '',
    this.fatherName = '',
    this.fatherNumber = '',
    this.motherName = '',
    this.motherNumber = '',
    this.collegeWorkplace = '',
    this.hometown = '',
    this.address = '',
    this.advanceAmount = 0.0,
    this.agreementSubmitted = false,
    this.rentStatus = 'Pending',
    this.paymentMode = '-',
  });

  // Convert to Map for database
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'dob': dob,
      'phone_number': phoneNumber,
      'father_name': fatherName,
      'father_number': fatherNumber,
      'mother_name': motherName,
      'mother_number': motherNumber,
      'college_workplace': collegeWorkplace,
      'hometown': hometown,
      'address': address,
      'room_id': roomId,
      'advance_amount': advanceAmount,
      'agreement_submitted': agreementSubmitted,
      'rent_status': rentStatus,
      'payment_mode': paymentMode,
    };
  }

  // Create from Map
  factory StudentModel.fromMap(Map<String, dynamic> map) {
    return StudentModel(
      id: map['id']?.toString(),
      roomId: map['room_id']?.toString(),
      phoneNumber: map['phone_number']?.toString() ?? map['contact']?.toString(),
      joinDate: map['join_date']?.toString(),
      roomNumber: map['room_number'] != null ? int.tryParse(map['room_number'].toString()) ?? 0 : 0,
      name: map['name'] ?? '',
      dob: map['dob'] ?? '',
      contact: map['contact'] ?? '',
      fatherName: map['father_name'] ?? '',
      fatherNumber: map['father_number'] ?? '',
      motherName: map['mother_name'] ?? '',
      motherNumber: map['mother_number'] ?? '',
      collegeWorkplace: map['college_workplace'] ?? map['college'] ?? '',
      hometown: map['hometown'] ?? '',
      address: map['address'] ?? '',
      advanceAmount: map['advance_amount'] != null ? double.tryParse(map['advance_amount'].toString()) ?? 0.0 : 0.0,
      agreementSubmitted: map['agreement_submitted'] == true || map['agreement_submitted']?.toString().toLowerCase() == 'true',
      rentStatus: map['rent_status'] ?? 'Pending',
      paymentMode: map['payment_mode'] ?? '-',
    );
  }

  // Copy with method for updates
  StudentModel copyWith({
    String? id,
    String? roomId,
    String? phoneNumber,
    String? joinDate,
    int? roomNumber,
    String? name,
    String? dob,
    String? contact,
    String? fatherName,
    String? fatherNumber,
    String? motherName,
    String? motherNumber,
    String? collegeWorkplace,
    String? hometown,
    String? address,
    double? advanceAmount,
    bool? agreementSubmitted,
    String? rentStatus,
    String? paymentMode,
  }) {
    return StudentModel(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      joinDate: joinDate ?? this.joinDate,
      roomNumber: roomNumber ?? this.roomNumber,
      name: name ?? this.name,
      dob: dob ?? this.dob,
      contact: contact ?? this.contact,
      fatherName: fatherName ?? this.fatherName,
      fatherNumber: fatherNumber ?? this.fatherNumber,
      motherName: motherName ?? this.motherName,
      motherNumber: motherNumber ?? this.motherNumber,
      collegeWorkplace: collegeWorkplace ?? this.collegeWorkplace,
      hometown: hometown ?? this.hometown,
      address: address ?? this.address,
      advanceAmount: advanceAmount ?? this.advanceAmount,
      agreementSubmitted: agreementSubmitted ?? this.agreementSubmitted,
      rentStatus: rentStatus ?? this.rentStatus,
      paymentMode: paymentMode ?? this.paymentMode,
    );
  }
}

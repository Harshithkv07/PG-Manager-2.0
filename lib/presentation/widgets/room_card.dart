import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/room_config_model.dart';
import '../../logic/providers/student_provider.dart';
import '../../core/constants/app_colors.dart';
import 'room_details_dialog.dart';

class RoomCard extends StatelessWidget {
  final RoomConfigModel room;
  final int occupancy;

  const RoomCard({
    super.key,
    required this.room,
    required this.occupancy,
  });

  Color _getStatusColor() {
    final available = room.capacity - occupancy;
    if (available == 0) return AppColors.roomFull;
    if (available < room.capacity) return AppColors.roomPartial;
    return AppColors.roomEmpty;
  }

  String _getStatusText() {
    final available = room.capacity - occupancy;
    if (available == 0) return 'FULL';
    if (available < room.capacity) return 'PARTIAL';
    return 'EMPTY';
  }

  void _showRoomDetails(BuildContext context) async {
    final students = await Provider.of<StudentProvider>(context, listen: false)
        .getStudentsByRoom(room.roomNumber);
    
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) => RoomDetailsDialog(
          room: room,
          students: students,
          occupancy: occupancy,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final available = room.capacity - occupancy;

    return InkWell(
      onTap: () => _showRoomDetails(context),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              statusColor.withOpacity(0.3),
              statusColor.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: statusColor,
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Room Number
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Room ${room.roomNumber}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getStatusText(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              // Occupancy Info
              Text(
                '$occupancy/${room.capacity} Beds',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$available Available',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              
              // Price
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.currency_rupee,
                    size: 16,
                    color: AppColors.goldAccent,
                  ),
                  Text(
                    '${room.price}/month',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.goldAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

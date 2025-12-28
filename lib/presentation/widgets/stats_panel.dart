import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/providers/room_provider.dart';
import '../../core/constants/app_colors.dart';

class StatsPanel extends StatelessWidget {
  const StatsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RoomProvider>(
      builder: (context, roomProvider, _) {
        final totalCapacity = roomProvider.getTotalCapacity();
        final totalOccupied = roomProvider.getTotalOccupied();
        final totalAvailable = roomProvider.getTotalAvailable();

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: _StatItem(
                    icon: Icons.bed,
                    label: 'Total Capacity',
                    value: totalCapacity.toString(),
                    color: AppColors.primaryAccent,
                  ),
                ),
                const VerticalDivider(width: 32),
                Expanded(
                  child: _StatItem(
                    icon: Icons.people,
                    label: 'Occupied',
                    value: totalOccupied.toString(),
                    color: AppColors.roomPartial,
                  ),
                ),
                const VerticalDivider(width: 32),
                Expanded(
                  child: _StatItem(
                    icon: Icons.hotel,
                    label: 'Available',
                    value: totalAvailable.toString(),
                    color: AppColors.roomEmpty,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            icon,
            size: 40,
            color: color,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

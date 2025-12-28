import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/providers/room_provider.dart';
import '../../logic/providers/student_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/services/excel_service.dart';
import '../widgets/room_card.dart';
import '../widgets/stats_panel.dart';
import '../widgets/price_manager_dialog.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RoomProvider>(context, listen: false).loadRooms();
      Provider.of<StudentProvider>(context, listen: false).loadStudents();
    });
  }

  Future<void> _downloadExcel() async {
    final studentProvider = Provider.of<StudentProvider>(context, listen: false);
    final roomProvider = Provider.of<RoomProvider>(context, listen: false);
    
    // Get all students and rooms
    final students = studentProvider.students;
    final rooms = roomProvider.rooms;
    
    final roomsMap = {for (var room in rooms) room.roomNumber: room};
    
    final excelService = ExcelService();
    final filePath = await excelService.exportStudentsToExcel(students, roomsMap);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Excel file saved: $filePath'),
          backgroundColor: AppColors.successColor,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  void _showPriceManager() {
    showDialog(
      context: context,
      builder: (context) => const PriceManagerDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await Provider.of<RoomProvider>(context, listen: false).loadRooms();
          await Provider.of<StudentProvider>(context, listen: false).loadStudents();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats Panel
              const StatsPanel(),
              const SizedBox(height: 24),
              
              // Controls Row
              Row(
                children: [
                  // Filter Dropdown
                  Expanded(
                    child: Consumer<RoomProvider>(
                      builder: (context, roomProvider, _) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.borderColor),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: roomProvider.currentFilter,
                              isExpanded: true,
                              icon: const Icon(Icons.filter_list),
                              items: const [
                                DropdownMenuItem(
                                  value: 'all',
                                  child: Text('Show All Rooms'),
                                ),
                                DropdownMenuItem(
                                  value: 'available',
                                  child: Text('Available Only'),
                                ),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  roomProvider.setFilter(value);
                                }
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Set Prices Button
                  ElevatedButton.icon(
                    onPressed: _showPriceManager,
                    icon: const Icon(Icons.attach_money),
                    label: const Text('Set Prices'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Download Excel Button
                  ElevatedButton.icon(
                    onPressed: _downloadExcel,
                    icon: const Icon(Icons.download),
                    label: const Text('Excel'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.successColor,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Room Grid
              Consumer<RoomProvider>(
                builder: (context, roomProvider, _) {
                  if (roomProvider.isLoading) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  
                  final rooms = roomProvider.rooms;
                  
                  if (rooms.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          'No rooms found',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    );
                  }
                  
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: rooms.length,
                    itemBuilder: (context, index) {
                      final room = rooms[index];
                      final occupancy = roomProvider.occupancyMap[room.roomNumber] ?? 0;
                      return RoomCard(
                        room: room,
                        occupancy: occupancy,
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

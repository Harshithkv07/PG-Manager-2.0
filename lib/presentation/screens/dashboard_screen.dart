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
  
  // Calculate grid columns based on screen width
  int _getGridColumns(double width) {
    if (width < 600) return 1;        // Mobile
    if (width < 900) return 2;        // Tablet portrait
    if (width < 1200) return 3;       // Tablet landscape
    return 4;                          // Desktop
  }
  
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
              
              // Controls Row - Responsive
              LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 600;
                  final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 900;
                  
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      // Filter Dropdown
                      Consumer<RoomProvider>(
                        builder: (context, roomProvider, _) {
                          return Container(
                            width: isMobile ? double.infinity : (isTablet ? constraints.maxWidth * 0.48 : 200),
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
                      
                      // Set Prices Button
                      SizedBox(
                        width: isMobile ? double.infinity : null,
                        child: ElevatedButton.icon(
                          onPressed: _showPriceManager,
                          icon: const Icon(Icons.attach_money),
                          label: Text(isMobile ? 'Set Prices' : 'Set Prices'),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 20 : 20,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ),
                      
                      // Download Excel Button
                      SizedBox(
                        width: isMobile ? double.infinity : null,
                        child: ElevatedButton.icon(
                          onPressed: _downloadExcel,
                          icon: const Icon(Icons.download),
                          label: const Text('Excel'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.successColor,
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 20 : 20,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              
              // Room Grid - Responsive
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
                  
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final columns = _getGridColumns(constraints.maxWidth);
                      final spacing = constraints.maxWidth < 600 ? 12.0 : 16.0;
                      
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: spacing,
                          mainAxisSpacing: spacing,
                          childAspectRatio: constraints.maxWidth < 600 ? 1.3 : 1.2,
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

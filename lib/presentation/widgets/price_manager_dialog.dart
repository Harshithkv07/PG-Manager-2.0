import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/providers/room_provider.dart';
import '../../core/constants/app_colors.dart';

class PriceManagerDialog extends StatefulWidget {
  const PriceManagerDialog({super.key});

  @override
  State<PriceManagerDialog> createState() => _PriceManagerDialogState();
}

class _PriceManagerDialogState extends State<PriceManagerDialog> {
  final _priceController = TextEditingController();
  int? _selectedRoomNumber;
  int? _selectedCapacity;

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _updateSingleRoom() async {
    if (_selectedRoomNumber == null || _priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a room and enter a price'),
          backgroundColor: AppColors.errorColor,
        ),
      );
      return;
    }

    final newPrice = int.tryParse(_priceController.text);
    if (newPrice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid price'),
          backgroundColor: AppColors.errorColor,
        ),
      );
      return;
    }

    await Provider.of<RoomProvider>(context, listen: false)
        .updateRoomPrice(_selectedRoomNumber!, newPrice);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Room price updated successfully'),
          backgroundColor: AppColors.successColor,
        ),
      );
    }
  }

  Future<void> _updateByCapacity() async {
    if (_selectedCapacity == null || _priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a capacity and enter a price'),
          backgroundColor: AppColors.errorColor,
        ),
      );
      return;
    }

    final newPrice = int.tryParse(_priceController.text);
    if (newPrice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid price'),
          backgroundColor: AppColors.errorColor,
        ),
      );
      return;
    }

    await Provider.of<RoomProvider>(context, listen: false)
        .updatePriceByCapacity(_selectedCapacity!, newPrice);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('All $_selectedCapacity-sharing rooms updated successfully'),
          backgroundColor: AppColors.successColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Price Manager',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            
            // Rooms List
            Expanded(
              child: Consumer<RoomProvider>(
                builder: (context, roomProvider, _) {
                  final rooms = roomProvider.rooms;
                  
                  return SingleChildScrollView(
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(
                        AppColors.secondaryBackground,
                      ),
                      columns: const [
                        DataColumn(label: Text('Select')),
                        DataColumn(label: Text('Room No')),
                        DataColumn(label: Text('Sharing')),
                        DataColumn(label: Text('Current Price')),
                      ],
                      rows: rooms.map((room) {
                        return DataRow(
                          selected: _selectedRoomNumber == room.roomNumber,
                          onSelectChanged: (selected) {
                            setState(() {
                              _selectedRoomNumber = selected == true ? room.roomNumber : null;
                              _selectedCapacity = selected == true ? room.capacity : null;
                            });
                          },
                          cells: [
                            DataCell(
                              Radio<int>(
                                value: room.roomNumber,
                                groupValue: _selectedRoomNumber,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedRoomNumber = value;
                                    _selectedCapacity = room.capacity;
                                  });
                                },
                              ),
                            ),
                            DataCell(Text(room.roomNumber.toString())),
                            DataCell(Text('${room.capacity}-Sharing')),
                            DataCell(Text('₹${room.price}')),
                          ],
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            
            // New Price Input
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'New Price',
                prefixIcon: Icon(Icons.currency_rupee),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _updateSingleRoom,
                    child: const Text('Update Selected'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _updateByCapacity,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryAccent,
                    ),
                    child: const Text('Update All (Same Sharing)'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

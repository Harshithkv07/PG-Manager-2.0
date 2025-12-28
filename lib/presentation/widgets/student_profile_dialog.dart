import 'package:flutter/material.dart';
import '../../data/models/student_model.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/whatsapp_helper.dart';
import 'rent_history_dialog.dart';

class StudentProfileDialog extends StatelessWidget {
  final StudentModel student;

  const StudentProfileDialog({
    super.key,
    required this.student,
  });

  Widget _buildInfoRow(String label, String value, {IconData? icon, VoidCallback? onIconTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (icon != null && onIconTap != null)
                  IconButton(
                    icon: Icon(icon, size: 20, color: AppColors.primaryAccent),
                    onPressed: onIconTap,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
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
            // Header
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.primaryAccent.withOpacity(0.2),
                  child: Text(
                    student.name[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryAccent,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryAccent.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Room ${student.roomNumber}',
                          style: const TextStyle(
                            color: AppColors.primaryAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Student Details
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Personal Information',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.primaryAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(height: 24),
                    
                    _buildInfoRow('Date of Birth', student.dob),
                    _buildInfoRow(
                      'Contact Number',
                      student.contact,
                      icon: Icons.message,
                      onIconTap: () => WhatsAppHelper.sendCustomMessage(
                        student.contact,
                        'Hello ${student.name}!',
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    Text(
                      'Family Information',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.primaryAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(height: 24),
                    
                    _buildInfoRow("Father's Name", student.fatherName),
                    _buildInfoRow(
                      "Father's Number",
                      student.fatherNumber,
                      icon: Icons.message,
                      onIconTap: () => WhatsAppHelper.sendCustomMessage(
                        student.fatherNumber,
                        'Hello, this is regarding ${student.name}.',
                      ),
                    ),
                    _buildInfoRow("Mother's Name", student.motherName),
                    _buildInfoRow(
                      "Mother's Number",
                      student.motherNumber,
                      icon: Icons.message,
                      onIconTap: () => WhatsAppHelper.sendCustomMessage(
                        student.motherNumber,
                        'Hello, this is regarding ${student.name}.',
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    Text(
                      'Academic & PG Information',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.primaryAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(height: 24),
                    
                    _buildInfoRow('College/Workplace', student.college),
                    _buildInfoRow('Hometown', student.hometown),
                    _buildInfoRow('Address', student.address),
                    _buildInfoRow('Advance Amount', '₹${student.advanceAmount}'),
                    _buildInfoRow('Agreement Submitted', student.agreementSubmitted),
                    _buildInfoRow('Rent Status', student.rentStatus),
                    _buildInfoRow('Payment Mode', student.paymentMode),
                  ],
                ),
              ),
            ),
            
            // Action Buttons
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => RentHistoryDialog(student: student),
                  );
                },
                icon: const Icon(Icons.history),
                label: const Text('View Rent History'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

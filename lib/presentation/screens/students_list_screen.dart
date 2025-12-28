import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/providers/student_provider.dart';
import '../../core/constants/app_colors.dart';
import '../widgets/student_profile_dialog.dart';

class StudentsListScreen extends StatefulWidget {
  const StudentsListScreen({super.key});

  @override
  State<StudentsListScreen> createState() => _StudentsListScreenState();
}

class _StudentsListScreenState extends State<StudentsListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StudentProvider>(context, listen: false).loadStudents();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showStudentProfile(BuildContext context, int studentId) {
    final studentProvider = Provider.of<StudentProvider>(context, listen: false);
    final student = studentProvider.students.firstWhere((s) => s.id == studentId);
    
    showDialog(
      context: context,
      builder: (context) => StudentProfileDialog(student: student),
    );
  }

  Future<void> _deleteStudent(int studentId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Student'),
        content: const Text('Are you sure you want to delete this student? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await Provider.of<StudentProvider>(context, listen: false).deleteStudent(studentId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Student deleted successfully'),
            backgroundColor: AppColors.successColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, room, or contact...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          Provider.of<StudentProvider>(context, listen: false).searchStudents('');
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                Provider.of<StudentProvider>(context, listen: false).searchStudents(value);
              },
            ),
          ),
          
          // Students Table
          Expanded(
            child: Consumer<StudentProvider>(
              builder: (context, studentProvider, _) {
                if (studentProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final students = studentProvider.students;
                
                if (students.isEmpty) {
                  return Center(
                    child: Text(
                      'No students found',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  );
                }
                
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: Card(
                      margin: const EdgeInsets.all(16),
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(
                          AppColors.secondaryBackground,
                        ),
                        columns: const [
                          DataColumn(label: Text('Room', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Student Name', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Contact', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('College', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: students.map((student) {
                          return DataRow(
                            cells: [
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryAccent.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    student.roomNumber.toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryAccent,
                                    ),
                                  ),
                                ),
                                onTap: () => _showStudentProfile(context, student.id!),
                              ),
                              DataCell(
                                Text(student.name),
                                onTap: () => _showStudentProfile(context, student.id!),
                              ),
                              DataCell(
                                Text(student.contact),
                                onTap: () => _showStudentProfile(context, student.id!),
                              ),
                              DataCell(
                                Text(student.college),
                                onTap: () => _showStudentProfile(context, student.id!),
                              ),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.visibility, color: AppColors.primaryAccent),
                                      onPressed: () => _showStudentProfile(context, student.id!),
                                      tooltip: 'View Profile',
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: AppColors.errorColor),
                                      onPressed: () => _deleteStudent(student.id!),
                                      tooltip: 'Delete Student',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

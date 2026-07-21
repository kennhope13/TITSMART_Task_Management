import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/app_repository.dart';
import '../../shared/widgets/task_card.dart';
import 'create_task_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  String _selectedFilter = 'Tất cả';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _filters = [
    'Tất cả',
    'Chờ giao',
    'Đã giao',
    'Đang làm',
    'Chờ duyệt',
    'Cần sửa',
    'Hoàn thành',
    'Trễ hạn',
  ];

  @override
  Widget build(BuildContext context) {
    final repo = AppRepository();
    final user = repo.currentUser;
    final isManager = user?.isManager ?? true;

    final filteredTasks = repo.tasks.where((task) {
      // Search text query
      final query = _searchController.text.toLowerCase().trim();
      if (query.isNotEmpty) {
        final match = task.title.toLowerCase().contains(query) ||
            task.code.toLowerCase().contains(query) ||
            task.location.toLowerCase().contains(query);
        if (!match) return false;
      }

      // Filter tab query
      if (_selectedFilter == 'Chờ giao') return task.status == 'pending';
      if (_selectedFilter == 'Đã giao') return task.status == 'assigned_worker';
      if (_selectedFilter == 'Đang làm') return task.status == 'in_progress';
      if (_selectedFilter == 'Chờ duyệt') return task.status == 'pending_approval';
      if (_selectedFilter == 'Cần sửa') return task.status == 'needs_revision';
      if (_selectedFilter == 'Hoàn thành') return task.status == 'completed';
      if (_selectedFilter == 'Trễ hạn') return task.status == 'needs_revision';
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isManager ? 'Quản lý Công việc' : 'Công việc của tôi',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.post_add, color: AppColors.primary, size: 26),
            tooltip: 'Tạo / Giao việc kèm tài liệu (PDF, XLSX, CSV, DOCX)',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateTaskScreen()));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter header bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm công việc, mã TS, địa điểm...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.outline),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Horizontal Filter Pills
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _filters.map((filter) {
                      final isSelected = _selectedFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(filter),
                          selected: isSelected,
                          selectedColor: AppColors.primaryContainer,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          onSelected: (val) {
                            if (val) {
                              setState(() {
                                _selectedFilter = filter;
                              });
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // List of tasks
          Expanded(
            child: filteredTasks.isEmpty
                ? const Center(
                    child: Text('Không tìm thấy công việc nào phù hợp.',
                        style: TextStyle(color: AppColors.outline)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      return TaskCard(task: filteredTasks[index]);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateTaskScreen()));
        },
        backgroundColor: isManager ? AppColors.primary : AppColors.secondary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Tạo / Giao việc (+ Docs)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

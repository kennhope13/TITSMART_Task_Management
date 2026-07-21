import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/app_repository.dart';
import '../tasks/models/task_model.dart';
import '../../shared/widgets/status_badge.dart';

class ManagerReportsScreen extends StatefulWidget {
  const ManagerReportsScreen({super.key});

  @override
  State<ManagerReportsScreen> createState() => _ManagerReportsScreenState();
}

class _ManagerReportsScreenState extends State<ManagerReportsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = AppRepository();
    final tasks = repo.tasks;

    final pendingApprovalTasks = tasks.where((t) => t.status == 'pending_approval').toList();
    final approvedTasks = tasks.where((t) => t.status == 'completed').toList();
    final rejectedTasks = tasks.where((t) => t.status == 'needs_revision').toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Quản lý Báo cáo & Thống kê', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.onSurfaceVariant,
          indicatorColor: AppColors.primary,
          tabs: [
            Tab(text: 'Chờ duyệt (${pendingApprovalTasks.length})'),
            Tab(text: 'Đã duyệt (${approvedTasks.length})'),
            Tab(text: 'Bị từ chối (${rejectedTasks.length})'),
            const Tab(text: 'Thống kê'),
            const Tab(text: 'Điểm danh'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildReportList(pendingApprovalTasks, isPending: true),
          _buildReportList(approvedTasks),
          _buildReportList(rejectedTasks, isRejected: true),
          _buildStatisticsTab(tasks),
          _buildAttendanceTab(),
        ],
      ),
    );
  }

  Widget _buildReportList(List<TaskModel> list, {bool isPending = false, bool isRejected = false}) {
    if (list.isEmpty) {
      return const Center(
        child: Text('Không có báo cáo nào ở danh mục này.', style: TextStyle(color: AppColors.outline)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final task = list[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.outlineVariant.withOpacity(0.6)),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(task.code, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.outline)),
                  StatusBadge(status: task.status),
                ],
              ),
              const SizedBox(height: 6),
              Text(task.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Thực hiện: ${task.workerName} | ${task.teamName}',
                  style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant)),
              const SizedBox(height: 8),

              if (task.proofPhotos.isNotEmpty) ...[
                const Text('Ảnh minh chứng:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                SizedBox(
                  height: 64,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: task.proofPhotos.length,
                    itemBuilder: (ctx, idx) => Container(
                      width: 64,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.primaryContainer),
                      ),
                      child: const Icon(Icons.image, color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],

              if (isRejected && task.rejectionReason != null) ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning, color: AppColors.error, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Lý do từ chối: ${task.rejectionReason}',
                          style: const TextStyle(color: AppColors.error, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],

              if (isPending) ...[
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                        ),
                        onPressed: () => _showRejectDialog(task),
                        icon: const Icon(Icons.close),
                        label: const Text('Từ chối'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                        ),
                        onPressed: () {
                          AppRepository().approveTaskReport(task.id);
                          setState(() {});
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Đã phê duyệt báo cáo ${task.code}!')),
                          );
                        },
                        icon: const Icon(Icons.check, color: Colors.white),
                        label: const Text('Phê duyệt', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _showRejectDialog(TaskModel task) {
    final reasonCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Từ chối báo cáo ${task.code}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Vui lòng nhập lý do từ chối để nhân viên sửa đổi lại:'),
            const SizedBox(height: 8),
            TextField(
              controller: reasonCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Nhập lý do bắt buộc...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              final reason = reasonCtrl.text.trim();
              if (reason.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Bắt buộc phải nhập lý do từ chối!')),
                );
                return;
              }
              AppRepository().rejectTaskReport(task.id, reason);
              Navigator.pop(ctx);
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Đã từ chối báo cáo ${task.code}!')),
              );
            },
            child: const Text('Từ chối', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsTab(List<TaskModel> tasks) {
    int total = tasks.length;
    int inProgress = tasks.where((t) => t.status == 'in_progress').length;
    int pendingApproval = tasks.where((t) => t.status == 'pending_approval').toList().length;
    int completed = tasks.where((t) => t.status == 'completed').length;
    int revision = tasks.where((t) => t.status == 'needs_revision').length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('THỐNG KÊ TRẠNG THÁI CÔNG VIỆC',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
        const SizedBox(height: 12),

        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.4,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _buildStatCard('Tổng công việc', '$total', AppColors.primary, Icons.assignment),
            _buildStatCard('Đang làm', '$inProgress', AppColors.statusInProgressFg, Icons.pending_actions),
            _buildStatCard('Chờ duyệt', '$pendingApproval', AppColors.statusApprovalFg, Icons.fact_check),
            _buildStatCard('Hoàn thành', '$completed', AppColors.statusCompletedFg, Icons.check_circle),
            _buildStatCard('Cần sửa', '$revision', AppColors.statusRevisionFg, Icons.warning),
            _buildStatCard('Nhân sự', '${AppRepository().staffList.length}', AppColors.secondary, Icons.groups),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 4)),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.outline)),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
              Icon(icon, color: color.withOpacity(0.5)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceTab() {
    final staff = AppRepository().staffList;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('DANH SÁCH ĐIỂM DANH HÔM NAY',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
        const SizedBox(height: 12),
        ...staff.map(
          (u) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: u.isManager ? AppColors.primaryFixedDim : AppColors.secondaryContainer,
                  child: Text(u.name[0]),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(u.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('Check-in: 08:05 AM | ${u.teamName}', style: const TextStyle(fontSize: 12, color: AppColors.outline)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('Online', style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

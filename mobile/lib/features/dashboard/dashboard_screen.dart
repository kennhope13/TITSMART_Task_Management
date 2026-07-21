import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/app_repository.dart';
import '../tasks/create_task_screen.dart';
import '../tasks/task_detail_screen.dart';

class DashboardScreen extends StatelessWidget {
  final Function(int)? onNavigateTab;

  const DashboardScreen({
    super.key,
    this.onNavigateTab,
  });

  @override
  Widget build(BuildContext context) {
    final repo = AppRepository();
    final user = repo.currentUser;

    if (user != null && user.isManager) {
      return _buildManagerDashboard(context, repo);
    } else {
      return _buildWorkerHome(context, repo);
    }
  }

  // ==========================================
  // 1. GIAO DIỆN SẾP / QUẢN LÝ (MANAGER OVERVIEW)
  // ==========================================
  Widget _buildManagerDashboard(BuildContext context, AppRepository repo) {
    final tasks = repo.tasks;
    final total = tasks.length;
    final inProgress = tasks.where((t) => t.status == 'in_progress').length;
    final pendingApproval = tasks.where((t) => t.status == 'pending_approval').length;
    final completed = tasks.where((t) => t.status == 'completed').length;
    final needsRevision = tasks.where((t) => t.status == 'needs_revision').length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppColors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.business_center, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('TITSMART QUẢN LÝ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
                Text('Quản lý: ${repo.currentUser?.name ?? "Quản lý"}',
                    style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_task, color: AppColors.primary),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateTaskScreen()));
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Quick Actions Row
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateTaskScreen()));
                  },
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text('Tạo công việc', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: AppColors.primary),
                  ),
                  onPressed: () {
                    if (onNavigateTab != null) onNavigateTab!(3); // Navigate to Reports
                  },
                  icon: const Icon(Icons.fact_check, color: AppColors.primary),
                  label: Text('Chờ duyệt ($pendingApproval)', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Stats Grid
          const Text('THỐNG KÊ TỔNG QUAN',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary)),
          const SizedBox(height: 10),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.5,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: [
              _buildStatCard('Tổng công việc', '$total', AppColors.primary, Icons.inventory),
              _buildStatCard('Đang làm', '$inProgress', AppColors.statusInProgressFg, Icons.pending),
              _buildStatCard('Chờ duyệt', '$pendingApproval', AppColors.statusApprovalFg, Icons.fact_check),
              _buildStatCard('Hoàn thành', '$completed', AppColors.statusCompletedFg, Icons.check_circle),
              _buildStatCard('Cần sửa / Trễ', '$needsRevision', AppColors.error, Icons.warning),
              _buildStatCard('Điểm danh', '18/24', AppColors.secondary, Icons.badge),
            ],
          ),
          const SizedBox(height: 20),

          // Urgent Alert Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.errorContainer.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.error),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.report_problem, color: AppColors.error),
                    SizedBox(width: 8),
                    Text('CẢNH BÁO KHẨN', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.error)),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('• TS-1026: Kiểm tra PCCC cổng 2 - Quá hạn 2h (Phụ trách: Phạm Văn D)'),
                const SizedBox(height: 4),
                const Text('• TS-1025: Báo cáo bảo trì bị từ chối - Cần sửa gấp ảnh minh chứng'),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Staff Monitoring Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('NẰM BẮT NHÂN SỰ HÔM NAY',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary)),
              TextButton(
                onPressed: () {
                  if (onNavigateTab != null) onNavigateTab!(2); // Staff tab
                },
                child: const Text('Xem tất cả >'),
              ),
            ],
          ),
          _buildStaffMiniItem('Nguyễn Văn An', 'Check-in: 08:05 • Đang làm việc', 'Online', Colors.green),
          _buildStaffMiniItem('Trần Thị B', 'Check-in: 08:15 • Nghỉ giải lao', 'Break', Colors.orange),
          _buildStaffMiniItem('Lê Văn C', 'Chưa check-in', 'Offline', Colors.grey),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
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
          Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.outline)),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
              Icon(icon, color: color.withOpacity(0.4)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStaffMiniItem(String name, String status, String badge, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: color.withOpacity(0.2), child: Text(name[0])),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(status, style: const TextStyle(fontSize: 12, color: AppColors.outline)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
            child: Text(badge, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11)),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 2. GIAO DIỆN NHÂN VIÊN / THỢ (WORKER HOME)
  // ==========================================
  Widget _buildWorkerHome(BuildContext context, AppRepository repo) {
    final tasks = repo.tasks;
    final inProgress = tasks.where((t) => t.status == 'in_progress').toList();
    final pendingApproval = tasks.where((t) => t.status == 'pending_approval').length;
    final needsRevision = tasks.where((t) => t.status == 'needs_revision').length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            const CircleAvatar(
              backgroundColor: AppColors.secondaryContainer,
              child: Icon(Icons.construction, color: AppColors.onSecondaryContainer),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('TITSMART NHÂN VIÊN',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
                Text('Xin chào: ${repo.currentUser?.name ?? "Kỹ thuật viên"}',
                    style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Banner Status
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('VIỆC CỦA BẠN HÔM NAY',
                        style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('${tasks.length} Công việc',
                        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                ),
                const Icon(Icons.engineering, color: Colors.white54, size: 48),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Worker Summary Row
          Row(
            children: [
              Expanded(child: _buildWorkerStatTile('Đang làm', '${inProgress.length}', AppColors.statusInProgressFg)),
              const SizedBox(width: 8),
              Expanded(child: _buildWorkerStatTile('Chờ duyệt', '$pendingApproval', AppColors.statusApprovalFg)),
              const SizedBox(width: 8),
              Expanded(child: _buildWorkerStatTile('Cần sửa', '$needsRevision', AppColors.error)),
            ],
          ),
          const SizedBox(height: 20),

          // Quick Actions for Worker
          const Text('THAO TÁC NHANH',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary)),
          const SizedBox(height: 10),

          _buildQuickActionButton(
            context,
            title: 'Điểm danh đầu ca (GPS + Selfie)',
            subtitle: 'Xác nhận vị trí hiện trường',
            icon: Icons.my_location,
            color: AppColors.secondary,
            onTap: () {
              if (onNavigateTab != null) onNavigateTab!(2); // Attendance tab
            },
          ),
          const SizedBox(height: 10),
          if (inProgress.isNotEmpty) ...[
            _buildQuickActionButton(
              context,
              title: 'Việc đang làm: ${inProgress.first.code}',
              subtitle: inProgress.first.title,
              icon: Icons.play_circle_fill,
              color: AppColors.primary,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => TaskDetailScreen(taskId: inProgress.first.id)),
                );
              },
            ),
            const SizedBox(height: 10),
          ],

          // Notifications section
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('THÔNG BÁO MỚI',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary)),
              TextButton(
                onPressed: () {
                  if (onNavigateTab != null) onNavigateTab!(3);
                },
                child: const Text('Xem tất cả >'),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
            ),
            child: Row(
              children: const [
                Icon(Icons.campaign, color: AppColors.primary),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Nhiệm vụ mới được giao: TS-1024', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('Vui lòng kiểm tra và bấm Bắt đầu công việc.',
                          style: TextStyle(fontSize: 12, color: AppColors.outline)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkerStatTile(String label, String val, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.outline)),
          const SizedBox(height: 4),
          Text(val, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.5)),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.outline)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: color),
          ],
        ),
      ),
    );
  }
}

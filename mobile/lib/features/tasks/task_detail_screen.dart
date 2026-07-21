import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/app_repository.dart';
import '../../shared/widgets/status_badge.dart';
import '../reports/completion_report_screen.dart';
import 'models/task_model.dart';

class TaskDetailScreen extends StatefulWidget {
  final int taskId;

  const TaskDetailScreen({
    super.key,
    required this.taskId,
  });

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final repo = AppRepository();
    final user = repo.currentUser;
    final isManager = user?.isManager ?? true;

    final taskIndex = repo.tasks.indexWhere((t) => t.id == widget.taskId);
    if (taskIndex == -1) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết công việc')),
        body: const Center(child: Text('Không tìm thấy công việc!')),
      );
    }
    final task = repo.tasks[taskIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(task.code, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header Status & Title Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('Độ ưu tiên: ${task.priority}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primary)),
                    ),
                    StatusBadge(status: task.status),
                  ],
                ),
                const SizedBox(height: 10),
                Text(task.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(task.description, style: const TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Rejection Reason Alert if Revision needed
          if (task.status == 'needs_revision' && task.rejectionReason != null) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.errorContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.error),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.warning, color: AppColors.error),
                      SizedBox(width: 8),
                      Text('YÊU CẦU SỬA ĐỔI BÁO CÁO',
                          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.error)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('Lý do từ chối: ${task.rejectionReason}',
                      style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Assignment & Location Info Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
            ),
            child: Column(
              children: [
                _buildInfoRow(Icons.person, 'Người thực hiện:', task.workerName),
                const Divider(),
                _buildInfoRow(Icons.groups, 'Đội / Nhóm:', task.teamName),
                const Divider(),
                _buildInfoRow(Icons.person_outline, 'Quản lý phụ trách:', task.managerName),
                const Divider(),
                _buildInfoRow(Icons.location_on, 'Địa điểm:', task.location),
                if (task.coordinates != null) ...[
                  const Divider(),
                  _buildInfoRow(Icons.my_location, 'Tọa độ GPS:', task.coordinates!),
                ],
                const Divider(),
                _buildInfoRow(Icons.calendar_today, 'Hạn hoàn thành:', task.deadline),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Attached Documents Section (CSV, DOCX, XLSX, PDF)
          if (task.attachedDocuments.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('TÀI LIỆU MINH CHỨNG (CSV, DOCX, XLSX, PDF)',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${task.attachedDocuments.length} file',
                    style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
              ),
              child: Column(
                children: task.attachedDocuments.map((doc) {
                  Color extColor = Colors.blue;
                  IconData extIcon = Icons.insert_drive_file;

                  if (doc.extension == 'csv') {
                    extColor = Colors.teal;
                    extIcon = Icons.table_chart;
                  } else if (doc.extension == 'docx') {
                    extColor = Colors.blue[700]!;
                    extIcon = Icons.description;
                  } else if (doc.extension == 'xlsx') {
                    extColor = Colors.green[800]!;
                    extIcon = Icons.grid_on;
                  } else if (doc.extension == 'pdf') {
                    extColor = Colors.red[700]!;
                    extIcon = Icons.picture_as_pdf;
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: extColor.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: extColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(extIcon, color: extColor, size: 26),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                doc.name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: extColor,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: Text(
                                      doc.extension.toUpperCase(),
                                      style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(doc.size, style: const TextStyle(fontSize: 11, color: AppColors.outline)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.open_in_new, color: AppColors.primary, size: 20),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Đang mở file ${doc.name} (${doc.extension.toUpperCase()})...')),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // History Section
          const Text('LỊCH SỬ XỬ LÝ',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary)),
          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
            ),
            child: Column(
              children: task.history.map((h) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle_outline, size: 20, color: AppColors.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(h.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text(h.time, style: const TextStyle(fontSize: 11, color: AppColors.outline)),
                              ],
                            ),
                            Text(h.description, style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),

      // Bottom Action Bar depending on Role & Task Status
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.outlineVariant)),
        ),
        child: SafeArea(
          child: isManager
              ? _buildManagerActions(context, task)
              : _buildWorkerActions(context, task),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String val) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.outline),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: AppColors.outline, fontSize: 13)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            val,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  // Action Buttons for Sếp / Manager
  Widget _buildManagerActions(BuildContext context, TaskModel task) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (task.status == 'pending_approval') ...[
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error)),
                  onPressed: () => _showRejectDialog(context, task),
                  child: const Text('Yêu cầu sửa'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700]),
                  onPressed: () {
                    AppRepository().approveTaskReport(task.id);
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã duyện hoàn thành công việc!')));
                  },
                  child: const Text('Duyệt hoàn thành', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ] else ...[
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showReassignDialog(context, task),
                  child: const Text('Đổi người thực hiện'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                  onPressed: () => _confirmCancelTask(context, task),
                  child: const Text('Hủy công việc', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  // Action Buttons for Nhân viên / Worker
  Widget _buildWorkerActions(BuildContext context, TaskModel task) {
    if (task.status == 'assigned_worker' || task.status == 'pending') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 14)),
          onPressed: () {
            AppRepository().startTask(task.id);
            setState(() {});
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã bắt đầu công việc!')));
          },
          icon: const Icon(Icons.play_arrow, color: Colors.white),
          label: const Text('BẮT ĐẦU CÔNG VIỆC', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      );
    } else if (task.status == 'in_progress') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary, padding: const EdgeInsets.symmetric(vertical: 14)),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => CompletionReportScreen(task: task)),
            ).then((_) => setState(() {}));
          },
          icon: const Icon(Icons.send, color: Colors.white),
          label: const Text('GỬI BÁO CÁO HOÀN THÀNH', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      );
    } else if (task.status == 'needs_revision') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, padding: const EdgeInsets.symmetric(vertical: 14)),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => CompletionReportScreen(task: task)),
            ).then((_) => setState(() {}));
          },
          icon: const Icon(Icons.refresh, color: Colors.white),
          label: const Text('GỬI LẠI BÁO CÁO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      );
    } else {
      return const SizedBox(
        width: double.infinity,
        child: Center(
          child: Text('Công việc đang ở trạng thái Chờ duyệt hoặc Đã hoàn thành',
              style: TextStyle(color: AppColors.outline, fontWeight: FontWeight.bold)),
        ),
      );
    }
  }

  void _showRejectDialog(BuildContext context, TaskModel task) {
    final reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Yêu cầu sửa đổi báo cáo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Vui lòng nhập lý do từ chối để nhân viên sửa đổi lại *:'),
            const SizedBox(height: 8),
            TextField(controller: reasonCtrl, maxLines: 3, decoration: const InputDecoration(hintText: 'Nhập lý do...')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              if (reasonCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập lý do!')));
                return;
              }
              AppRepository().rejectTaskReport(task.id, reasonCtrl.text.trim());
              Navigator.pop(ctx);
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã yêu cầu nhân viên sửa đổi!')));
            },
            child: const Text('Gửi yêu cầu', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmCancelTask(BuildContext context, TaskModel task) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận HỦY công việc?'),
        content: Text('Bạn có chắc chắn muốn hủy công việc ${task.code} không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Quay lại')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              AppRepository().cancelTask(task.id);
              Navigator.pop(ctx);
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã hủy công việc!')));
            },
            child: const Text('Hủy công việc', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showReassignDialog(BuildContext context, TaskModel task) {
    final staff = AppRepository().staffList.map((s) => s.name).toList();
    String selectedWorker = staff.first;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Đổi người thực hiện'),
          content: DropdownButtonFormField<String>(
            value: selectedWorker,
            items: staff.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (val) {
              if (val != null) setDialogState(() => selectedWorker = val);
            },
            decoration: const InputDecoration(labelText: 'Chọn nhân viên mới'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: () {
                AppRepository().reassignTask(task.id, selectedWorker, task.teamName);
                Navigator.pop(ctx);
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã giao lại cho $selectedWorker!')));
              },
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
  }
}

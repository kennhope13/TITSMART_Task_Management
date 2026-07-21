import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../features/tasks/models/task_model.dart';
import '../../features/tasks/task_detail_screen.dart';
import 'status_badge.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback? onTap;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant, width: 0.8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap ??
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => TaskDetailScreen(taskId: task.id)),
                );
              },
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Task code & status badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          task.code,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.outline,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            task.priority,
                            style: const TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    StatusBadge(status: task.status),
                  ],
                ),
                const SizedBox(height: 6),
                // Title
                Text(
                  task.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                    height: 1.25,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                const Divider(height: 1, color: AppColors.surfaceContainerHigh),
                const SizedBox(height: 10),
                // Location & Worker Details Grid
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 16, color: AppColors.outline),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        task.location,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.outline),
                    const SizedBox(width: 6),
                    Text(
                      'Hạn: ${task.deadline}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Footer: Worker & Team
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 11,
                          backgroundColor: AppColors.secondary,
                          child: Icon(Icons.engineering, size: 12, color: Colors.white),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${task.workerName} (${task.teamName})',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: const [
                        Text(
                          'Chi tiết',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        Icon(Icons.chevron_right, size: 16, color: AppColors.primary),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

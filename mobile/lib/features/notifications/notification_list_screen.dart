import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/app_repository.dart';
import '../../shared/widgets/empty_state_widget.dart';

class NotificationListScreen extends StatefulWidget {
  const NotificationListScreen({super.key});

  @override
  State<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen> {
  String _selectedFilter = 'Tất cả';

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'task':
        return Icons.assignment;
      case 'reminder':
        return Icons.notifications_active;
      case 'approval':
        return Icons.verified;
      case 'update':
        return Icons.edit_note;
      case 'system':
        return Icons.security;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'task':
        return AppColors.primary;
      case 'reminder':
        return Colors.orange;
      case 'approval':
        return Colors.green;
      case 'update':
        return Colors.purple;
      case 'system':
        return AppColors.error;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = AppRepository();
    final notifications = repo.notifications;

    final filteredList = notifications.where((n) {
      if (_selectedFilter == 'Chưa đọc') return !n.isRead;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('THÔNG BÁO'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Đánh dấu tất cả đã đọc',
            onPressed: () {
              setState(() {
                for (var n in notifications) {
                  n.isRead = true;
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter tabs
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('Tất cả'),
                  selected: _selectedFilter == 'Tất cả',
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedFilter = 'Tất cả');
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: Text('Chưa đọc (${repo.unreadNotificationCount})'),
                  selected: _selectedFilter == 'Chưa đọc',
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedFilter = 'Chưa đọc');
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.outlineVariant),

          // List Body
          Expanded(
            child: filteredList.isEmpty
                ? const EmptyStateWidget(
                    title: 'Không có thông báo nào',
                    message: 'Chúng tôi sẽ thông báo cho bạn khi có cập nhật mới.',
                    icon: Icons.notifications_none_outlined,
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final item = filteredList[index];
                      final iconColor = _getNotificationColor(item.type);

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            repo.markNotificationAsRead(item.id);
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: item.isRead
                                ? AppColors.surface
                                : AppColors.primaryContainer.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border(
                              left: BorderSide(
                                color: item.isRead ? AppColors.outlineVariant : AppColors.primary,
                                width: 4,
                              ),
                              top: const BorderSide(color: AppColors.outlineVariant, width: 0.8),
                              right: const BorderSide(color: AppColors.outlineVariant, width: 0.8),
                              bottom: const BorderSide(color: AppColors.outlineVariant, width: 0.8),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: iconColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  _getNotificationIcon(item.type),
                                  color: iconColor,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item.title,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: item.isRead
                                                  ? FontWeight.w600
                                                  : FontWeight.bold,
                                              color: AppColors.onSurface,
                                            ),
                                          ),
                                        ),
                                        if (!item.isRead)
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: const BoxDecoration(
                                              color: AppColors.primary,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item.content,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.onSurfaceVariant,
                                        height: 1.3,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      item.time,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.outline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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

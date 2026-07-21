class NotificationModel {
  final int id;
  final String title;
  final String content;
  final String time;
  bool isRead;
  final String type; // task, reminder, approval, update, system

  NotificationModel({
    required this.id,
    required this.title,
    required this.content,
    required this.time,
    this.isRead = false,
    this.type = 'task',
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? 1,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      time: json['time'] ?? '',
      isRead: json['is_read'] ?? false,
      type: json['type'] ?? 'task',
    );
  }
}

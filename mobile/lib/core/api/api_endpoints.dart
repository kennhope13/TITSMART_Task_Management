class ApiEndpoints {
  // Default Base URL for Android Emulator (10.0.2.2) or local PHP Artisan server (127.0.0.1:8000)
  static String baseUrl = 'http://10.0.2.2:8000/api/v1';

  // Auth
  static const String login = '/auth/login';
  static const String me = '/me';
  static const String logout = '/auth/logout';

  // Tasks
  static const String tasks = '/tasks';
  static String taskDetail(int id) => '/tasks/$id';
  static String startTask(int id) => '/tasks/$id/start';
  static String submitCompletionReport(int id) => '/tasks/$id/completion-reports';

  // Attendance
  static const String checkIn = '/attendance/check-in';

  // Notifications
  static const String notifications = '/notifications';
  static String readNotification(int id) => '/notifications/$id/read';
}

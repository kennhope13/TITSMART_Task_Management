class ApiEndpoints {
  // ADB reverse maps 127.0.0.1:8000 directly to host computer Laravel API server
  static String baseUrl = 'http://127.0.0.1:8000/api/v1';

  // Auth
  static const String login = '/auth/login';
  static const String me = '/me';
  static const String logout = '/auth/logout';

  // Dashboard
  static const String dashboardSummary = '/dashboard/summary';

  // Users
  static const String users = '/users';
  static String userDetail(int id) => '/users/$id';
  static String lockUser(int id) => '/users/$id/lock';
  static String unlockUser(int id) => '/users/$id/unlock';

  // Teams
  static const String teams = '/teams';
  static String teamDetail(int id) => '/teams/$id';
  static String teamMembers(int id) => '/teams/$id/members';
  static String removeTeamMember(int teamId, int userId) => '/teams/$teamId/members/$userId';

  // Tasks
  static const String tasks = '/tasks';
  static String taskDetail(int id) => '/tasks/$id';
  static String assignWorker(int id) => '/tasks/$id/assign-worker';
  static String startTask(int id) => '/tasks/$id/start';
  static String pauseTask(int id) => '/tasks/$id/pause';
  static String cancelTask(int id) => '/tasks/$id/cancel';
  static String reopenTask(int id) => '/tasks/$id/reopen';

  // Completion Reports
  static const String completionReports = '/completion-reports';
  static String submitCompletionReport(int id) => '/tasks/$id/completion-reports';
  static String approveReport(int id) => '/completion-reports/$id/approve';
  static String rejectReport(int id) => '/completion-reports/$id/reject';

  // Attendance
  static const String attendance = '/attendance';
  static const String myAttendanceHistory = '/attendance/my-history';
  static const String checkIn = '/attendance/check-in';

  // Notifications
  static const String notifications = '/notifications';
  static String readNotification(int id) => '/notifications/$id/read';
}

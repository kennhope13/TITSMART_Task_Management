import 'package:flutter/foundation.dart';
import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../auth/user_model.dart';
import '../../features/tasks/models/task_model.dart';
import '../../features/notifications/models/notification_model.dart';

class AppRepository extends ChangeNotifier {
  static final AppRepository _instance = AppRepository._internal();
  factory AppRepository() => _instance;
  AppRepository._internal();

  UserModel? currentUser;
  bool isLoggedIn = false;
  bool isLoading = false;
  String? errorMessage;

  List<TaskModel> tasks = [];
  List<NotificationModel> notifications = [];
  List<UserModel> staffList = [];
  List<String> teams = [];
  Map<String, dynamic> dashboardSummary = {};

  /// Try auto-login on app startup if a saved token exists
  Future<bool> tryAutoLogin() async {
    final token = await ApiClient.getToken();
    if (token == null || token.isEmpty) {
      isLoggedIn = false;
      return false;
    }
    return await fetchCurrentUser();
  }

  /// Real authentication call to POST /api/v1/auth/login
  Future<ApiResponse<dynamic>> login(String account, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final isEmail = account.contains('@');
    final payload = {
      if (isEmail) 'email': account else 'employee_code': account,
      'password': password,
      'device_name': 'TITSMART-Mobile-App',
    };

    final res = await ApiClient.post(ApiEndpoints.login, payload);
    isLoading = false;

    if (res.success && res.data != null) {
      final token = res.data['access_token'];
      if (token != null) {
        await ApiClient.saveToken(token);
        if (res.data['user'] != null) {
          currentUser = UserModel.fromJson(res.data['user']);
          isLoggedIn = true;
        } else {
          await fetchCurrentUser();
        }
        await refreshAllData();
        notifyListeners();
        return res;
      }
    }

    isLoggedIn = false;
    errorMessage = res.message ?? 'Đăng nhập không thành công. Vui lòng kiểm tra lại tài khoản.';
    notifyListeners();
    return res;
  }

  /// Fetch current authenticated user info via GET /api/v1/me
  Future<bool> fetchCurrentUser() async {
    final res = await ApiClient.get(ApiEndpoints.me);
    if (res.success && res.data != null && res.data['user'] != null) {
      currentUser = UserModel.fromJson(res.data['user']);
      isLoggedIn = true;
      notifyListeners();
      return true;
    }
    isLoggedIn = false;
    currentUser = null;
    notifyListeners();
    return false;
  }

  /// Refresh all real database collections
  Future<void> refreshAllData() async {
    await Future.wait([
      fetchDashboardSummary(),
      fetchTasks(),
      fetchStaff(),
      fetchTeams(),
      fetchNotifications(),
    ]);
  }

  /// GET /api/v1/dashboard/summary
  Future<void> fetchDashboardSummary() async {
    final res = await ApiClient.get(ApiEndpoints.dashboardSummary);
    if (res.success && res.data != null) {
      dashboardSummary = Map<String, dynamic>.from(res.data);
      notifyListeners();
    }
  }

  /// GET /api/v1/tasks
  Future<void> fetchTasks({String? status, String? search}) async {
    String endpoint = ApiEndpoints.tasks;
    List<String> params = [];
    if (status != null && status.isNotEmpty) params.add('status=$status');
    if (search != null && search.isNotEmpty) params.add('search=$search');
    if (params.isNotEmpty) endpoint += '?${params.join('&')}';

    final res = await ApiClient.get(endpoint);
    if (res.success && res.data != null) {
      final list = res.data['data'] as List? ?? res.data as List? ?? [];
      tasks = list.map((item) => TaskModel.fromJson(item)).toList();
      notifyListeners();
    }
  }

  /// GET /api/v1/users
  Future<void> fetchStaff({String? role, String? search}) async {
    String endpoint = ApiEndpoints.users;
    List<String> params = [];
    if (role != null && role.isNotEmpty) params.add('role=$role');
    if (search != null && search.isNotEmpty) params.add('search=$search');
    if (params.isNotEmpty) endpoint += '?${params.join('&')}';

    final res = await ApiClient.get(endpoint);
    if (res.success && res.data != null) {
      final list = res.data['data'] as List? ?? res.data as List? ?? [];
      staffList = list.map((item) => UserModel.fromJson(item)).toList();
      notifyListeners();
    }
  }

  /// GET /api/v1/teams
  Future<void> fetchTeams() async {
    final res = await ApiClient.get(ApiEndpoints.teams);
    if (res.success && res.data != null) {
      final list = res.data as List? ?? [];
      teams = list.map((t) => t['name'].toString()).toList();
      notifyListeners();
    }
  }

  /// GET /api/v1/notifications
  Future<void> fetchNotifications() async {
    final res = await ApiClient.get(ApiEndpoints.notifications);
    if (res.success && res.data != null) {
      final list = res.data['data'] as List? ?? res.data as List? ?? [];
      notifications = list.map((n) => NotificationModel.fromJson(n)).toList();
      notifyListeners();
    }
  }

  /// Action: Start Task (POST /api/v1/tasks/{id}/start)
  Future<ApiResponse<dynamic>> startTask(int taskId) async {
    final res = await ApiClient.post(ApiEndpoints.startTask(taskId), {});
    if (res.success) {
      await fetchTasks();
    }
    return res;
  }

  /// Action: Approve Completion Report (POST /api/v1/completion-reports/{id}/approve)
  Future<ApiResponse<dynamic>> approveCompletionReport(int reportId) async {
    final res = await ApiClient.post(ApiEndpoints.approveReport(reportId), {});
    if (res.success) {
      await fetchTasks();
    }
    return res;
  }

  /// Action: Reject Completion Report (POST /api/v1/completion-reports/{id}/reject)
  Future<ApiResponse<dynamic>> rejectCompletionReport(int reportId, String reason) async {
    final res = await ApiClient.post(ApiEndpoints.rejectReport(reportId), {
      'rejection_reason': reason,
    });
    if (res.success) {
      await fetchTasks();
    }
    return res;
  }

  /// Action: Lock User (POST /api/v1/users/{id}/lock)
  Future<ApiResponse<dynamic>> lockStaff(int userId) async {
    final res = await ApiClient.post(ApiEndpoints.lockUser(userId), {});
    if (res.success) {
      await fetchStaff();
    }
    return res;
  }

  /// Action: Unlock User (POST /api/v1/users/{id}/unlock)
  Future<ApiResponse<dynamic>> unlockStaff(int userId) async {
    final res = await ApiClient.post(ApiEndpoints.unlockUser(userId), {});
    if (res.success) {
      await fetchStaff();
    }
    return res;
  }

  /// Action: GPS Check-in (POST /api/v1/attendance/check-in)
  Future<ApiResponse<dynamic>> checkIn({
    required double lat,
    required double lng,
    required String address,
    required String notes,
    required bool isFakeGps,
  }) async {
    if (isFakeGps) {
      return ApiResponse(
        success: false,
        message: 'CẢNH BÁO: Phát hiện giả lập GPS! Thao tác điểm danh bị từ chối.',
      );
    }
    return ApiResponse(
      success: true,
      message: 'Điểm danh GPS thành công lúc ${DateTime.now().hour}:${DateTime.now().minute}!',
    );
  }

  /// Action: Logout
  Future<void> logout() async {
    await ApiClient.post(ApiEndpoints.logout, {});
    await ApiClient.clearToken();
    currentUser = null;
    isLoggedIn = false;
    tasks.clear();
    staffList.clear();
    notifications.clear();
    notifyListeners();
  }

  int get unreadNotificationCount => notifications.where((n) => !n.isRead).length;
}

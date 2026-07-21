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
  List<TaskModel> tasks = [];
  List<NotificationModel> notifications = [];
  List<UserModel> staffList = [];
  List<String> teams = [
    'Đội kỹ thuật số 01',
    'Đội kỹ thuật số 02',
    'Đội thi công 03',
    'Đội bảo trì 04',
    'Đội Cơ điện 05',
  ];

  void initializeDemoData() {
    if (currentUser == null) {
      // Default to Manager role so user can see Sếp interface, but can easily toggle!
      currentUser = UserModel(
        id: 1,
        name: 'NGUYỄN VĂN AN (QUẢN LÝ)',
        employeeCode: 'NV-2024-889',
        email: 'an.nguyen@titsmart.vn',
        phone: '090 123 4567',
        role: 'manager',
        teamName: 'Ban Giám Đốc / Quản Lý',
      );
      isLoggedIn = true;
    }

    staffList = [
      UserModel(
        id: 1,
        name: 'Nguyễn Văn An',
        employeeCode: 'NV-2024-889',
        email: 'an.nguyen@titsmart.vn',
        phone: '090 123 4567',
        role: 'manager',
        teamName: 'Ban Giám Đốc',
      ),
      UserModel(
        id: 2,
        name: 'Trần Thị B',
        employeeCode: 'NV-2024-102',
        email: 'b.tran@titsmart.vn',
        phone: '091 234 5678',
        role: 'worker',
        teamName: 'Đội kỹ thuật số 01',
      ),
      UserModel(
        id: 3,
        name: 'Lê Văn C',
        employeeCode: 'NV-2024-105',
        email: 'c.le@titsmart.vn',
        phone: '098 765 4321',
        role: 'worker',
        teamName: 'Đội thi công 03',
      ),
      UserModel(
        id: 4,
        name: 'Phạm Văn D',
        employeeCode: 'NV-2024-201',
        email: 'd.pham@titsmart.vn',
        phone: '093 333 4444',
        role: 'worker',
        teamName: 'Đội bảo trì 04',
        isLocked: true,
      ),
    ];

    tasks = [
      TaskModel(
        id: 101,
        code: 'TS-1024',
        title: 'Lắp đặt hệ thống camera khu A',
        description:
            'Kiểm tra định kỳ thiết bị vô tuyến, hệ thống nguồn điện dự phòng (UPS) và làm sạch bộ lọc gió tại trạm khu vực Quận 1. Đảm bảo các thông số kỹ thuật đạt chuẩn vận hành.',
        location: 'Khu Công Nghệ Cao, Quận 9, TP.HCM',
        coordinates: '10.7769° N, 106.7009° E',
        deadline: '17:00 - 25/10/2023',
        status: 'in_progress',
        managerName: 'Nguyễn Văn An (Quản lý)',
        workerName: 'Trần Thị B',
        teamName: 'Đội kỹ thuật số 01',
        priority: 'Cao',
        history: [
          TaskHistoryItem(
            title: 'Khởi tạo công việc',
            time: '08:30 - 24/10',
            description: 'Quản lý tạo công việc lắp đặt camera.',
          ),
          TaskHistoryItem(
            title: 'Đã giao việc',
            time: '09:15 - 24/10',
            description: 'Giao việc cho Trần Thị B thuộc Đội 01.',
          ),
          TaskHistoryItem(
            title: 'Đang làm',
            time: '10:00 - 25/10',
            description: 'Trần Thị B đã bấm Bắt đầu công việc.',
          ),
        ],
      ),
      TaskModel(
        id: 102,
        code: 'TS-1025',
        title: 'Bảo trì máy lạnh văn phòng tầng 4',
        description:
            'Bảo dưỡng tổng thể hệ thống điều hòa VRV tầng 4, vệ sinh lưới lọc và nạp gas bổ sung.',
        location: 'Tòa nhà TITSMART, Q.Bình Thạnh',
        coordinates: '10.8012° N, 106.7115° E',
        deadline: '18:00 - 26/10/2023',
        status: 'pending_approval',
        managerName: 'Nguyễn Văn An (Quản lý)',
        workerName: 'Lê Văn C',
        teamName: 'Đội Cơ điện 05',
        priority: 'Cao',
        proofPhotos: [
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBSE8guvY-CCH0pFO8AfJ5CsTNptHRXs3Vryt6SKMOMORdhl11x-qObZseNwXH3q227owAk49tppyMaOORP1jInCgLZB-b9T3WPLcvw1EBFnbZu1PgLswcwawiUfcbG5twqP3guQa3Gz-Wd4lOQPrf7Y37m4XIYbSPsO_JBrx0U3xKvw10YOqqh0z8oc6jsuhEWEpmyGZoDpkoXXJw6c3-IYnGlh8MR4OmXmGZx3uwmPXzPG6oQKB2kOy0U0p4heW7TIrJ8bgo3_A0',
        ],
        attachedDocuments: [
          AttachedDocument(name: 'Bien_ban_nghiem_thu_may_lanh.docx', extension: 'docx', size: '1.8 MB'),
          AttachedDocument(name: 'Bang_thong_so_ap_suat_gas.xlsx', extension: 'xlsx', size: '940 KB'),
          AttachedDocument(name: 'Nhat_ky_kiem_tra_dinh_ky.csv', extension: 'csv', size: '120 KB'),
          AttachedDocument(name: 'So_do_mach_dien_tang_4.pdf', extension: 'pdf', size: '3.4 MB'),
        ],
        history: [
          TaskHistoryItem(
            title: 'Đã gửi báo cáo hoàn thành',
            time: '11:20 - 26/10',
            description: 'Chờ quản lý phê duyệt.',
          ),
        ],
      ),
      TaskModel(
        id: 103,
        code: 'TS-1026',
        title: 'Kiểm tra an ninh & PCCC cổng số 2',
        description: 'Kiểm tra bình chữa cháy tự động và đo điện trở tiếp địa.',
        location: 'Cổng số 2, Kho tổng Q.Thủ Đức',
        deadline: '12:00 - 24/10/2023',
        status: 'needs_revision',
        managerName: 'Nguyễn Văn An (Quản lý)',
        workerName: 'Phạm Văn D',
        teamName: 'Đội thi công 03',
        priority: 'Trung bình',
        rejectionReason: 'Ảnh chụp minh chứng không rõ nét, thiếu góc quay cảm biến PCCC.',
        history: [
          TaskHistoryItem(
            title: 'Yêu cầu sửa đổi báo cáo',
            time: '14:00 - 24/10',
            description: 'Quản lý từ chối báo cáo. Lý do: Ảnh chụp mờ.',
          ),
        ],
      ),
      TaskModel(
        id: 104,
        code: 'TS-1027',
        title: 'Bảo trì trạm biến áp trung thế',
        description: 'Vệ sinh sứ cách điện và siết lại bu lông mặt máy biến áp.',
        location: 'Trạm BTS-402, Q.12',
        deadline: '17:00 - 20/10/2023',
        status: 'completed',
        managerName: 'Nguyễn Văn An (Quản lý)',
        workerName: 'Trần Thị B',
        teamName: 'Đội bảo trì 04',
        priority: 'Thấp',
        history: [
          TaskHistoryItem(
            title: 'Đã nghiệm thu hoàn thành',
            time: '16:45 - 20/10',
            description: 'Quản lý đã duyệt báo cáo và đóng công việc.',
          ),
        ],
      ),
      TaskModel(
        id: 105,
        code: 'TS-1028',
        title: 'Khảo sát lắp đặt tuyến cáp quang mới',
        description: 'Khảo sát địa hình và vẽ sơ đồ đi dây cho nhà xưởng B.',
        location: 'Nhà xưởng B, Q.9',
        deadline: '17:00 - 28/10/2023',
        status: 'pending',
        managerName: 'Nguyễn Văn An (Quản lý)',
        workerName: 'Chưa phân công',
        teamName: 'Đội kỹ thuật số 01',
        priority: 'Trung bình',
        history: [
          TaskHistoryItem(
            title: 'Tạo công việc nháp',
            time: '09:00 - 26/10',
            description: 'Công việc mới được tạo, chờ phân công.',
          ),
        ],
      ),
    ];

    notifications = [
      NotificationModel(
        id: 1,
        title: 'Công việc mới được giao: TS-1024',
        content: 'Bạn vừa được giao nhiệm vụ Lắp đặt hệ thống camera khu A.',
        time: '10 phút trước',
        isRead: false,
        type: 'task',
      ),
      NotificationModel(
        id: 2,
        title: 'Báo cáo chờ duyệt từ Lê Văn C',
        content: 'Báo cáo bảo trì máy lạnh (TS-1025) đang chờ bạn phê duyệt.',
        time: '30 phút trước',
        isRead: false,
        type: 'approval',
      ),
      NotificationModel(
        id: 3,
        title: 'Cảnh báo: Công việc TS-1026 trễ hạn',
        content: 'Công việc Kiểm tra PCCC cổng 2 đã quá hạn hoàn thành.',
        time: '2 giờ trước',
        isRead: true,
        type: 'update',
      ),
    ];
  }

  // --- Toggle User Role (Convenient testing between Manager & Worker UI) ---
  void switchUserRole(String newRole) {
    if (currentUser == null) return;
    final updatedRole = newRole.toLowerCase();
    currentUser = currentUser!.copyWith(
      role: updatedRole,
      name: updatedRole == 'manager' ? 'NGUYỄN VĂN AN (QUẢN LÝ)' : 'NGUYỄN VĂN AN (NHÂN VIÊN)',
    );
    notifyListeners();
  }

  // --- Auth Actions ---
  Future<ApiResponse<dynamic>> login(String account, String password) async {
    final response = await ApiClient.post(ApiEndpoints.login, {
      'email': account,
      'password': password,
      'device_name': 'flutter-android',
    });

    if (response.success && response.data != null) {
      final token = response.data['token'] ?? response.data['access_token'];
      if (token != null) {
        await ApiClient.saveToken(token);
      }
      isLoggedIn = true;
      notifyListeners();
      return response;
    } else {
      // Fallback local login demo
      if (account.isNotEmpty && password.isNotEmpty) {
        final isBoss = account.contains('sep') || account.contains('admin') || account.contains('manager');
        currentUser = UserModel(
          id: isBoss ? 1 : 2,
          name: isBoss ? 'NGUYỄN VĂN AN (QUẢN LÝ)' : 'TRẦN THỊ B (NHÂN VIÊN)',
          employeeCode: isBoss ? 'NV-SEP-01' : 'NV-THO-02',
          email: account,
          phone: '090 123 4567',
          role: isBoss ? 'manager' : 'worker',
        );
        isLoggedIn = true;
        await ApiClient.saveToken('demo_token_sanctum_123456');
        notifyListeners();
        return ApiResponse(success: true, message: 'Đăng nhập thành công');
      }
      return response;
    }
  }

  Future<void> logout() async {
    await ApiClient.post(ApiEndpoints.logout, {});
    await ApiClient.clearToken();
    isLoggedIn = false;
    notifyListeners();
  }

  // --- Create & Assign Task ---
  Future<bool> createTask({
    required String title,
    required String description,
    required String location,
    String? coordinates,
    required String deadline,
    required String teamName,
    required String workerName,
    required String managerName,
    required String priority,
    String? notes,
  }) async {
    final newId = tasks.length + 101;
    final newTask = TaskModel(
      id: newId,
      code: 'TS-10$newId',
      title: title,
      description: description,
      location: location,
      coordinates: coordinates,
      deadline: deadline,
      status: workerName == 'Chưa phân công' ? 'pending' : 'assigned_worker',
      managerName: managerName,
      workerName: workerName,
      teamName: teamName,
      priority: priority,
      notes: notes,
      history: [
        TaskHistoryItem(
          title: 'Khởi tạo công việc',
          time: 'Vừa xong',
          description: 'Quản lý tạo & phân công công việc.',
        ),
      ],
    );
    tasks.insert(0, newTask);
    notifyListeners();
    return true;
  }

  // --- Task Status Actions ---
  Future<bool> startTask(int taskId) async {
    final index = tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      tasks[index].status = 'in_progress';
      tasks[index].history.add(
        TaskHistoryItem(
          title: 'Đang làm',
          time: 'Vừa xong',
          description: 'Kỹ thuật viên đã bấm Bắt đầu công việc.',
        ),
      );
      notifyListeners();
    }
    return true;
  }

  Future<bool> submitCompletionReport(
    int taskId,
    String notes,
    List<String> photos, [
    List<AttachedDocument> documents = const [],
  ]) async {
    final index = tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      tasks[index].status = 'pending_approval';
      tasks[index].proofPhotos = photos;
      tasks[index].attachedDocuments = documents;
      tasks[index].rejectionReason = null;
      tasks[index].history.add(
        TaskHistoryItem(
          title: 'Chờ duyệt',
          time: 'Vừa xong',
          description: documents.isNotEmpty
              ? 'Đã gửi báo cáo hoàn thành cùng ${documents.length} tài liệu đính kèm: $notes'
              : 'Đã gửi báo cáo hoàn thành: $notes',
        ),
      );
      notifyListeners();
    }
    return true;
  }

  Future<bool> approveTaskReport(int taskId) async {
    final index = tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      tasks[index].status = 'completed';
      tasks[index].history.add(
        TaskHistoryItem(
          title: 'Đã nghiệm thu hoàn thành',
          time: 'Vừa xong',
          description: 'Quản lý đã phê duyệt báo cáo công việc.',
        ),
      );
      notifyListeners();
    }
    return true;
  }

  Future<bool> rejectTaskReport(int taskId, String reason) async {
    final index = tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      tasks[index].status = 'needs_revision';
      tasks[index].rejectionReason = reason;
      tasks[index].history.add(
        TaskHistoryItem(
          title: 'Yêu cầu sửa đổi',
          time: 'Vừa xong',
          description: 'Quản lý từ chối báo cáo. Lý do: $reason',
        ),
      );
      notifyListeners();
    }
    return true;
  }

  Future<bool> cancelTask(int taskId) async {
    final index = tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      tasks[index].status = 'cancelled';
      tasks[index].history.add(
        TaskHistoryItem(
          title: 'Đã hủy công việc',
          time: 'Vừa xong',
          description: 'Công việc đã bị Quản lý hủy.',
        ),
      );
      notifyListeners();
    }
    return true;
  }

  Future<bool> reassignTask(int taskId, String newWorker, String newTeam) async {
    final index = tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      tasks[index].workerName = newWorker;
      tasks[index].status = 'assigned_worker';
      tasks[index].history.add(
        TaskHistoryItem(
          title: 'Đổi người thực hiện',
          time: 'Vừa xong',
          description: 'Công việc được giao lại cho $newWorker.',
        ),
      );
      notifyListeners();
    }
    return true;
  }

  // --- Staff Management Actions ---
  void addStaff(UserModel user) {
    staffList.add(user);
    notifyListeners();
  }

  void toggleLockStaff(int userId) {
    final index = staffList.indexWhere((u) => u.id == userId);
    if (index != -1) {
      final current = staffList[index];
      staffList[index] = current.copyWith(isLocked: !current.isLocked);
      notifyListeners();
    }
  }

  // --- Attendance ---
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
        message: 'CẢNH BÁO: Phát hiện thiết bị sử dụng GPS giả lập! Điểm danh bị từ chối.',
      );
    }
    return ApiResponse(
      success: true,
      message: 'Điểm danh thành công lúc ${DateTime.now().hour}:${DateTime.now().minute}!',
    );
  }

  void markNotificationAsRead(int notificationId) {
    final index = notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      notifications[index].isRead = true;
      notifyListeners();
    }
  }

  int get unreadNotificationCount => notifications.where((n) => !n.isRead).length;
}

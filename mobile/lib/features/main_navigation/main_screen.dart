import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/app_repository.dart';
import '../dashboard/dashboard_screen.dart';
import '../tasks/task_list_screen.dart';
import '../staff/staff_list_screen.dart';
import '../reports/manager_reports_screen.dart';
import '../attendance/attendance_screen.dart';
import '../notifications/notification_list_screen.dart';
import '../account/account_screen.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;

  const MainScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    AppRepository().initializeDemoData();
    AppRepository().addListener(_onRepositoryChanged);
  }

  @override
  void dispose() {
    AppRepository().removeListener(_onRepositoryChanged);
    super.dispose();
  }

  void _onRepositoryChanged() {
    setState(() {});
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final repo = AppRepository();
    final user = repo.currentUser;
    final isManager = user?.isManager ?? true;

    // Define Role-specific Pages & Bottom Navigation Items
    final List<Widget> managerPages = [
      DashboardScreen(onNavigateTab: _onTabTapped),
      const TaskListScreen(),
      const StaffListScreen(),
      const ManagerReportsScreen(),
      const AccountScreen(),
    ];

    final List<Widget> workerPages = [
      DashboardScreen(onNavigateTab: _onTabTapped),
      const TaskListScreen(),
      const AttendanceScreen(),
      const NotificationListScreen(),
      const AccountScreen(),
    ];

    final pages = isManager ? managerPages : workerPages;

    // Ensure _currentIndex doesn't overflow when switching roles
    if (_currentIndex >= pages.length) {
      _currentIndex = 0;
    }

    final managerNavItems = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.dashboard_outlined),
        activeIcon: Icon(Icons.dashboard),
        label: 'Tổng quan',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.assignment_outlined),
        activeIcon: Icon(Icons.assignment),
        label: 'Công việc',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.groups_outlined),
        activeIcon: Icon(Icons.groups),
        label: 'Nhân sự',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.analytics_outlined),
        activeIcon: Icon(Icons.analytics),
        label: 'Báo cáo',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.person_outline),
        activeIcon: Icon(Icons.person),
        label: 'Tài khoản',
      ),
    ];

    final workerNavItems = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home),
        label: 'Trang chủ',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.assignment_outlined),
        activeIcon: Icon(Icons.assignment),
        label: 'Việc của tôi',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.photo_camera_outlined),
        activeIcon: Icon(Icons.photo_camera),
        label: 'Điểm danh',
      ),
      BottomNavigationBarItem(
        icon: Stack(
          children: [
            const Icon(Icons.notifications_outlined),
            if (repo.unreadNotificationCount > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
        activeIcon: Stack(
          children: [
            const Icon(Icons.notifications),
            if (repo.unreadNotificationCount > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
        label: 'Thông báo',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.person_outline),
        activeIcon: Icon(Icons.person),
        label: 'Tài khoản',
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: isManager ? AppColors.primary : AppColors.secondary,
          unselectedItemColor: AppColors.outline,
          items: isManager ? managerNavItems : workerNavItems,
        ),
      ),
    );
  }
}

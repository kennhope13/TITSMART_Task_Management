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
    AppRepository().refreshAllData();
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

    final isDirector = user?.isDirector ?? false;
    final isManagerOnly = user?.isManagerOnly ?? false;

    // Define Pages based on Role Requirements:
    // 1. Sếp / Admin: Tổng quan, Công việc, Nhân sự, Báo cáo, Tài khoản
    final List<Widget> directorPages = [
      DashboardScreen(onNavigateTab: _onTabTapped),
      const TaskListScreen(),
      const StaffListScreen(),
      const ManagerReportsScreen(),
      const AccountScreen(),
    ];

    // 2. Quản lý: Tổng quan, Công việc, Nhân sự đội, Báo cáo, Điểm danh, Tài khoản
    final List<Widget> managerPages = [
      DashboardScreen(onNavigateTab: _onTabTapped),
      const TaskListScreen(),
      const StaffListScreen(),
      const ManagerReportsScreen(),
      const AttendanceScreen(),
      const AccountScreen(),
    ];

    // 3. Nhân viên / Thợ: Trang chủ, Việc của tôi, Điểm danh, Thông báo, Tài khoản
    final List<Widget> workerPages = [
      DashboardScreen(onNavigateTab: _onTabTapped),
      const TaskListScreen(),
      const AttendanceScreen(),
      const NotificationListScreen(),
      const AccountScreen(),
    ];

    final pages = isDirector
        ? directorPages
        : (isManagerOnly ? managerPages : workerPages);

    if (_currentIndex >= pages.length) {
      _currentIndex = 0;
    }

    final directorNavItems = [
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
        icon: Icon(Icons.badge_outlined),
        activeIcon: Icon(Icons.badge),
        label: 'Nhân sự đội',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.analytics_outlined),
        activeIcon: Icon(Icons.analytics),
        label: 'Báo cáo',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.camera_alt_outlined),
        activeIcon: Icon(Icons.camera_alt),
        label: 'Điểm danh',
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

    final navItems = isDirector
        ? directorNavItems
        : (isManagerOnly ? managerNavItems : workerNavItems);

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
          selectedItemColor: isDirector
              ? AppColors.primary
              : (isManagerOnly ? AppColors.secondary : AppColors.primary),
          unselectedItemColor: AppColors.outline,
          items: navItems,
        ),
      ),
    );
  }
}

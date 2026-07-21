import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/app_repository.dart';
import '../auth/login_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  @override
  Widget build(BuildContext context) {
    final repo = AppRepository();
    final user = repo.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Chưa đăng nhập.')));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Tài khoản cá nhân', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Header Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: user.isManager ? AppColors.primary : AppColors.secondary,
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 12),
                Text(user.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: user.isManager ? AppColors.primaryContainer.withOpacity(0.15) : AppColors.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    user.roleDisplayLabel.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: user.isManager ? AppColors.primary : AppColors.onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Convenient Role Switcher Banner (Permits testing both Sếp & Thợ UIs)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: user.isManager ? Colors.indigo[50] : Colors.teal[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: user.isManager ? Colors.indigo : Colors.teal),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(user.isManager ? Icons.admin_panel_settings : Icons.construction,
                        color: user.isManager ? Colors.indigo : Colors.teal),
                    const SizedBox(width: 8),
                    Text(
                      'CHUYỂN ĐỔI VAI TRÒ TEST (DEMO)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: user.isManager ? Colors.indigo[900] : Colors.teal[900],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  user.isManager
                      ? 'Đang ở giao diện Quản lý. Bấm bên dưới để xem giao diện Nhân viên.'
                      : 'Đang ở giao diện Nhân viên. Bấm bên dưới để xem giao diện Quản lý.',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: user.isManager ? Colors.teal[700] : Colors.indigo[700],
                    ),
                    onPressed: () {
                      final targetRole = user.isManager ? 'worker' : 'manager';
                      repo.switchUserRole(targetRole);
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Đã chuyển sang giao diện: ${repo.currentUser?.roleDisplayLabel}!'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.swap_horiz, color: Colors.white),
                    label: Text(
                      user.isManager ? 'CHUYỂN SANG VAI TRÒ NHÂN VIÊN' : 'CHUYỂN SANG VAI TRÒ QUẢN LÝ',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // User Information Details Card
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
                const Text('THÔNG TIN CHI TIẾT',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
                const SizedBox(height: 12),
                _buildDetailTile(Icons.badge, 'Mã nhân viên', user.employeeCode),
                const Divider(),
                _buildDetailTile(Icons.email, 'Email liên hệ', user.email),
                const Divider(),
                _buildDetailTile(Icons.phone, 'Số điện thoại', user.phone),
                const Divider(),
                _buildDetailTile(Icons.groups, 'Đội / Phòng ban', user.teamName ?? 'Kỹ thuật'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Account Settings Actions
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.lock_reset, color: AppColors.primary),
                  title: const Text('Đổi mật khẩu'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showChangePasswordDialog(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.logout, color: AppColors.error),
                  title: const Text('Đăng xuất', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
                  onTap: () async {
                    await AppRepository().logout();
                    if (!mounted) return;
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildDetailTile(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.outline),
        const SizedBox(width: 10),
        Text(title, style: const TextStyle(color: AppColors.outline, fontSize: 13)),
        const Spacer(),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final oldPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đổi mật khẩu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: oldPassCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Mật khẩu cũ')),
            TextField(controller: newPassCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Mật khẩu mới')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đổi mật khẩu thành công!')),
              );
            },
            child: const Text('Lưu mật khẩu'),
          ),
        ],
      ),
    );
  }
}

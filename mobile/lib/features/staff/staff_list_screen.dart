import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/auth/user_model.dart';
import '../../core/services/app_repository.dart';

class StaffListScreen extends StatefulWidget {
  const StaffListScreen({super.key});

  @override
  State<StaffListScreen> createState() => _StaffListScreenState();
}

class _StaffListScreenState extends State<StaffListScreen> {
  String _selectedFilter = 'Tất cả';

  final List<String> _filters = [
    'Tất cả',
    'Quản lý',
    'Nhân viên',
    'Đang hoạt động',
    'Bị khóa',
  ];

  @override
  Widget build(BuildContext context) {
    final repo = AppRepository();

    List<UserModel> filteredStaff = repo.staffList.where((u) {
      if (_selectedFilter == 'Quản lý') return u.isManager;
      if (_selectedFilter == 'Nhân viên') return u.isWorker;
      if (_selectedFilter == 'Đang hoạt động') return !u.isLocked;
      if (_selectedFilter == 'Bị khóa') return u.isLocked;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Quản lý Nhân sự', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1, color: AppColors.primary),
            onPressed: () => _showAddStaffDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter horizontal list
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: isSelected,
                      selectedColor: AppColors.primaryContainer,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (val) {
                        if (val) {
                          setState(() {
                            _selectedFilter = filter;
                          });
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          Expanded(
            child: filteredStaff.isEmpty
                ? const Center(child: Text('Không có nhân sự nào.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredStaff.length,
                    itemBuilder: (context, index) {
                      final staff = filteredStaff[index];
                      return _buildStaffCard(staff);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddStaffDialog(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Thêm nhân sự', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildStaffCard(UserModel staff) {
    final repo = AppRepository();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          radius: 26,
          backgroundColor: staff.isManager ? AppColors.primaryFixedDim : AppColors.secondaryContainer,
          child: Text(
            staff.name.isNotEmpty ? staff.name[0].toUpperCase() : 'N',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: staff.isManager ? AppColors.primary : AppColors.onSecondaryContainer,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                staff.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: staff.isLocked ? AppColors.errorContainer : Colors.green.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                staff.isLocked ? 'Bị khóa' : 'Hoạt động',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: staff.isLocked ? AppColors.error : Colors.green[800],
                ),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Mã NV: ${staff.employeeCode} • SĐT: ${staff.phone}', style: const TextStyle(fontSize: 13)),
              const SizedBox(height: 2),
              Text('Vai trò: ${staff.roleDisplayLabel} | ${staff.teamName ?? "Chưa gán đội"}',
                  style: TextStyle(fontSize: 12, color: AppColors.outline)),
            ],
          ),
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: AppColors.outline),
          onSelected: (val) {
            if (val == 'lock') {
              _confirmLockStaff(staff);
            } else if (val == 'assign_team') {
              _showAssignTeamDialog(staff);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'assign_team',
              child: Row(
                children: const [
                  Icon(Icons.groups_outlined, size: 20),
                  SizedBox(width: 8),
                  Text('Gán vào Đội/Nhóm'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'lock',
              child: Row(
                children: [
                  Icon(staff.isLocked ? Icons.lock_open : Icons.lock, size: 20, color: staff.isLocked ? Colors.green : Colors.red),
                  const SizedBox(width: 8),
                  Text(staff.isLocked ? 'Mở khóa tài khoản' : 'Khóa tài khoản',
                      style: TextStyle(color: staff.isLocked ? Colors.green : Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLockStaff(UserModel staff) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(staff.isLocked ? 'Mở khóa tài khoản?' : 'Xác nhận khóa tài khoản?'),
        content: Text(
          staff.isLocked
              ? 'Tài khoản ${staff.name} sẽ được quyền đăng nhập trở lại.'
              : 'Tài khoản ${staff.name} sẽ bị khóa và không thể truy cập hệ thống TITSMART.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: staff.isLocked ? Colors.green : AppColors.error,
            ),
            onPressed: () {
              AppRepository().toggleLockStaff(staff.id);
              Navigator.pop(ctx);
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(staff.isLocked ? 'Đã mở khóa tài khoản!' : 'Đã khóa tài khoản!')),
              );
            },
            child: Text(staff.isLocked ? 'Mở khóa' : 'Khóa', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAssignTeamDialog(UserModel staff) {
    final teams = AppRepository().teams;
    String selectedTeam = staff.teamName ?? teams.first;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Gán ${staff.name} vào Đội'),
          content: DropdownButtonFormField<String>(
            value: teams.contains(selectedTeam) ? selectedTeam : teams.first,
            items: teams
                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                .toList(),
            onChanged: (val) {
              if (val != null) {
                setDialogState(() {
                  selectedTeam = val;
                });
              }
            },
            decoration: const InputDecoration(labelText: 'Chọn Đội/Nhóm'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Đã gán ${staff.name} vào $selectedTeam!')),
                );
              },
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddStaffDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    String role = 'worker';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Thêm Nhân sự Mới'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Họ và tên *')),
                TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Số điện thoại *')),
                TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: role,
                  items: const [
                    DropdownMenuItem(value: 'worker', child: Text('Nhân viên')),
                    DropdownMenuItem(value: 'manager', child: Text('Quản lý')),
                  ],
                  onChanged: (val) {
                    if (val != null) setDialogState(() => role = val);
                  },
                  decoration: const InputDecoration(labelText: 'Vai trò'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.isEmpty || phoneCtrl.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vui lòng nhập Họ tên và SĐT!')),
                  );
                  return;
                }
                final newId = AppRepository().staffList.length + 10;
                final newUser = UserModel(
                  id: newId,
                  name: nameCtrl.text,
                  employeeCode: 'NV-2024-$newId',
                  email: emailCtrl.text.isEmpty ? 'nv$newId@titsmart.vn' : emailCtrl.text,
                  phone: phoneCtrl.text,
                  role: role,
                  teamName: 'Đội kỹ thuật 01',
                );
                AppRepository().addStaff(newUser);
                Navigator.pop(ctx);
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã thêm nhân sự thành công!')),
                );
              },
              child: const Text('Thêm'),
            ),
          ],
        ),
      ),
    );
  }
}

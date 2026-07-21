class UserModel {
  final int id;
  final String name;
  final String employeeCode;
  final String email;
  final String phone;
  final String role; // 'manager', 'admin', 'director', 'worker'
  final String? avatarUrl;
  final String? teamName;
  final bool isLocked;

  UserModel({
    required this.id,
    required this.name,
    required this.employeeCode,
    required this.email,
    required this.phone,
    required this.role,
    this.avatarUrl,
    this.teamName,
    this.isLocked = false,
  });

  bool get isManager {
    final r = role.toLowerCase();
    return r == 'admin' || r == 'director' || r == 'manager' || r == 'sếp' || r == 'quản lý';
  }

  bool get isWorker => !isManager;

  String get roleDisplayLabel {
    if (isManager) return 'Quản lý';
    return 'Nhân viên';
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 1,
      name: json['name'] ?? 'Nguyễn Văn An',
      employeeCode: json['employee_code'] ?? 'NV-2024-889',
      email: json['email'] ?? 'an.nguyen@titsmart.vn',
      phone: json['phone'] ?? '090 123 4567',
      role: json['role'] ?? 'worker',
      avatarUrl: json['avatar_url'],
      teamName: json['team_name'] ?? 'Đội kỹ thuật 1',
      isLocked: json['is_locked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'employee_code': employeeCode,
      'email': email,
      'phone': phone,
      'role': role,
      'avatar_url': avatarUrl,
      'team_name': teamName,
      'is_locked': isLocked,
    };
  }

  UserModel copyWith({
    int? id,
    String? name,
    String? employeeCode,
    String? email,
    String? phone,
    String? role,
    String? avatarUrl,
    String? teamName,
    bool? isLocked,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      employeeCode: employeeCode ?? this.employeeCode,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      teamName: teamName ?? this.teamName,
      isLocked: isLocked ?? this.isLocked,
    );
  }
}

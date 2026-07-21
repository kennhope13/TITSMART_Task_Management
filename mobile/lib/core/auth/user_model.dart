class UserModel {
  final int id;
  final String name;
  final String employeeCode;
  final String email;
  final String phone;
  final String role; // 'director', 'admin', 'manager', 'worker'
  final String? status;
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
    this.status,
    this.avatarUrl,
    this.teamName,
    this.isLocked = false,
  });

  bool get isDirector {
    final r = role.toLowerCase();
    return r == 'director' || r == 'admin' || r == 'sếp';
  }

  bool get isManagerOnly {
    final r = role.toLowerCase();
    return r == 'manager';
  }

  bool get isManager {
    return isDirector || isManagerOnly;
  }

  bool get isWorker {
    return !isDirector && !isManagerOnly;
  }

  String get roleDisplayLabel {
    if (isDirector) return 'Sếp / Tổng Quản Lý';
    if (isManagerOnly) return 'Quản Lý';
    return 'Nhân Viên / Thợ';
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final statusVal = json['status'] ?? 'active';
    return UserModel(
      id: json['id'] ?? 1,
      name: json['name'] ?? '',
      employeeCode: json['employee_code'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? 'worker',
      status: statusVal,
      avatarUrl: json['avatar_url'],
      teamName: json['team'] != null ? json['team']['name'] : json['team_name'],
      isLocked: statusVal == 'inactive' || (json['is_locked'] ?? false),
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
      'status': status,
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
    String? status,
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
      status: status ?? this.status,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      teamName: teamName ?? this.teamName,
      isLocked: isLocked ?? this.isLocked,
    );
  }
}

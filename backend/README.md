# Backend - Laravel + Filament

Backend đảm nhiệm 2 vai trò:

- Web Admin cho Sếp/Quản lý bằng Filament.
- REST API cho app Flutter.

## Cấu trúc đề xuất

```text
backend/
├── app/
│   ├── Domain/               # Module nghiệp vụ chính
│   │   ├── Users/
│   │   ├── Teams/
│   │   ├── Tasks/
│   │   ├── Attendance/
│   │   ├── Reports/
│   │   ├── Notifications/
│   │   └── Imports/
│   ├── Filament/             # Resource/Page cho Web Admin
│   ├── Http/Controllers/Api/ # API versioned cho mobile
│   ├── Jobs/                 # Queue: nén ảnh, gửi thông báo
│   ├── Policies/             # Phân quyền theo vai trò/phạm vi dữ liệu
│   └── Services/             # Service dùng chung
├── database/
│   ├── migrations/
│   └── seeders/
├── routes/
│   ├── api.php
│   └── web.php
└── tests/
```

## Module nghiệp vụ

- `Users`: tài khoản, vai trò, khóa/mở khóa.
- `Teams`: đội nhóm, Quản lý, Thợ thuộc đội.
- `Tasks`: import, phân công, trạng thái công việc.
- `Attendance`: điểm danh GPS + selfie.
- `Reports`: báo cáo hoàn thành, ảnh minh chứng, duyệt/từ chối.
- `Notifications`: push/realtime notification.
- `Imports`: đọc Excel, validate, ghi lỗi import.

## Gói Laravel nên dùng

- `filament/filament`: Web Admin.
- `laravel/sanctum`: token API cho Flutter.
- `maatwebsite/excel`: import/export Excel.
- `spatie/laravel-permission`: phân quyền nếu cần chi tiết.
- `intervention/image`: xử lý/nén ảnh nếu backend cần xử lý thêm.


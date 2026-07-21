# TITSMART Task Management

Hệ thống quản lý công việc nội bộ cho mô hình Sếp -> Quản lý -> Thợ hiện trường.

## Stack đã chốt

- Backend + Web Admin: Laravel + Filament
- Mobile App: Flutter
- Database: MySQL
- Push Notification: Firebase Cloud Messaging
- Map/GPS: Google Maps
- Server: VPS Ubuntu + Nginx

## Cây thư mục chính

```text
TITSMART_Task_Management/
├── backend/    # Laravel: Web Admin + API cho mobile
├── mobile/     # Flutter app cho Thợ/Quản lý hiện trường
├── infra/      # Cấu hình deploy VPS/Nginx/Supervisor/Docker
└── docs/       # Tài liệu kỹ thuật API, database, deployment
```

## Backend

```powershell
cd backend
php artisan serve --host=127.0.0.1 --port=8010
```

Web Admin:

```text
http://127.0.0.1:8010/admin
```

API mobile:

```text
http://127.0.0.1:8010/api/v1
```

## Ghi chú triển khai

- Web Admin dùng cho Sếp và Quản lý.
- Mobile app dùng cho Thợ hiện trường.
- Backend kiểm tra phân quyền ở API, không chỉ ẩn nút trên giao diện.
- Ảnh điểm danh và ảnh báo cáo lưu trên disk/storage, database chỉ lưu đường dẫn.

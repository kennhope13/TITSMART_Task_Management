# Cấu trúc source code

Stack đã chốt:

- Backend + Web Admin: Laravel + Filament
- Mobile App: Flutter
- Database: MySQL
- Push Notification: Firebase Cloud Messaging
- Map/GPS: Google Maps
- Server: VPS Ubuntu + Nginx

## Cây thư mục chính

```text
source_code/
├── backend/                  # Laravel: Web Admin + API cho mobile
├── mobile/                   # Flutter app cho Thợ/Quản lý hiện trường
├── infra/                    # Cấu hình triển khai VPS/Nginx/Supervisor/Docker
└── docs/                     # Tài liệu kỹ thuật API, database, deployment
```

## Quy ước triển khai

- `backend` quản lý toàn bộ nghiệp vụ lõi: tài khoản, đội nhóm, công việc, điểm danh, báo cáo, thông báo.
- `backend/app/Filament` dùng cho Web Admin của Sếp và Quản lý.
- `backend/app/Http/Controllers/Api/V1` dùng cho API mobile Flutter.
- `mobile/lib/features` chia theo nghiệp vụ trên app.
- `infra` chỉ chứa cấu hình triển khai, không chứa secret thật.


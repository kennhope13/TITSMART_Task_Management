# Mobile API

Base URL khi chạy local:

```text
http://127.0.0.1:8000/api/v1
```

Các endpoint cần đăng nhập dùng header:

```http
Authorization: Bearer <access_token>
Accept: application/json
```

## Auth

### Đăng nhập

```http
POST /auth/login
```

Body:

```json
{
  "email": "worker1@titsmart.com",
  "password": "password",
  "device_name": "flutter-android"
}
```

Có thể dùng `employee_code` thay cho `email`.

### Lấy thông tin tài khoản

```http
GET /me
```

### Đăng xuất thiết bị hiện tại

```http
POST /auth/logout
```

## Công Việc

### Danh sách công việc

```http
GET /tasks?status=assigned_worker&per_page=15
```

Quyền dữ liệu:

- `worker`: chỉ thấy công việc được giao cho mình.
- `manager`: chỉ thấy công việc mình quản lý.
- `director`: thấy toàn bộ công việc.

### Chi tiết công việc

```http
GET /tasks/{task_id}
```

### Bắt đầu công việc

```http
POST /tasks/{task_id}/start
```

Chỉ thợ được giao việc được gọi endpoint này. Trạng thái hợp lệ: `assigned_worker`, `needs_revision`.

## Báo Cáo Hoàn Thành

```http
POST /tasks/{task_id}/completion-reports
Content-Type: multipart/form-data
```

Body:

```text
notes: Đã hoàn thành công việc.
photos[]: proof-1.jpg
photos[]: proof-2.jpg
```

Sau khi gửi, công việc chuyển sang `pending_approval`.

## Điểm Danh

```http
POST /attendance/check-in
Content-Type: multipart/form-data
```

Body:

```text
latitude: 10.762622
longitude: 106.660172
address: Nhà máy A
selfie_photo: selfie.jpg
is_fake_gps: false
notes: Có mặt tại công trình
```

## Thông Báo

```http
GET /notifications
POST /notifications/{notification_id}/read
```

## Kiểm Tra Sức Khỏe API

```http
GET /health
```

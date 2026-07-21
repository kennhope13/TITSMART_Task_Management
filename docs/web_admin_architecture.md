# Kiến trúc Web Admin

Web Admin dành cho Sếp/Tổng quản lý và Quản lý/Leader. Thợ không dùng Web Admin, mà thao tác qua Mobile App.

## Công nghệ

- Laravel
- Filament
- Blade/Livewire
- MySQL
- Laravel Sanctum cho API mobile

## Nhóm chức năng Web Admin

1. Tổng quan
   - KPI công việc
   - Việc chờ duyệt
   - Việc trễ hạn
   - Việc cần sửa đổi

2. Nhân sự & đội nhóm
   - Quản lý tài khoản Sếp, Quản lý, Thợ
   - Khóa/mở khóa tài khoản
   - Gán Quản lý cho đội
   - Gán Thợ vào đội

3. Công việc
   - Tạo công việc thủ công
   - Import Excel
   - Phân công 3 cấp
   - Theo dõi trạng thái
   - Lịch sử thao tác

4. Điểm danh
   - GPS
   - Ảnh selfie
   - Cảnh báo Fake GPS
   - Link Google Maps

5. Báo cáo & nghiệm thu
   - Xem ảnh minh chứng
   - Duyệt báo cáo
   - Từ chối và bắt buộc nhập lý do
   - Chuyển trạng thái công việc

6. Thông báo
   - Việc mới
   - Báo cáo chờ duyệt
   - Báo cáo bị từ chối
   - Cảnh báo điểm danh

7. Báo cáo quản trị
   - Theo Quản lý
   - Theo đội
   - Theo Thợ
   - Theo trạng thái công việc
   - Xuất Excel

## Phân quyền

- `director`: toàn quyền hệ thống.
- `manager`: chỉ xem và xử lý dữ liệu thuộc đội mình.
- `worker`: không truy cập Web Admin.

## Trạng thái công việc

- `draft`: Nháp
- `pending_assignment`: Chờ phân công
- `assigned_manager`: Đã giao Quản lý
- `assigned_worker`: Đã giao Thợ
- `in_progress`: Đang làm
- `pending_approval`: Chờ duyệt
- `completed`: Hoàn thành
- `needs_revision`: Cần sửa đổi
- `cancelled`: Hủy

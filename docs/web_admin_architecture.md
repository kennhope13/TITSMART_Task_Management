# Architecture & Scaffold Spec: TITSMART Web Admin (Laravel + Filament)

> [!NOTE]
> Hệ thống Web Admin dành riêng cho **Sếp/Tổng quản lý** và **Quản lý/Leader** với **giao diện sáng (Light Theme)**, bảng dữ liệu tối ưu, bộ lọc đa dạng, action nhanh và phân quyền theo vai trò.

---

## 🎨 Design System & Theme Configuration
- **Theme**: Light Mode Admin Dashboard
- **Color Palette**:
  - `primary`: Blue (`#2563EB`) - Đã giao Thợ
  - `info`: Sky Blue (`#38BDF8`) - Đã giao Quản lý
  - `warning`: Amber (`#F59E0B`) - Chờ phân công
  - `orange`: Orange (`#F97316`) - Chờ duyệt
  - `purple`: Purple (`#8B5CF6`) - Đang làm
  - `success`: Emerald (`#10B981`) - Hoàn thành / Hợp lệ
  - `danger`: Red (`#EF4444`) - Cần sửa đổi / Khóa / Fake GPS
  - `gray/slate`: Gray (`#4B5563`) - Nháp / Hủy

---

## 📁 Project Structure & Filament Scaffold

```text
backend/
├── app/
│   ├── Domain/
│   │   ├── Attendance/
│   │   │   └── Attendance.php
│   │   ├── Imports/
│   │   │   └── BulkImport.php
│   │   ├── Notifications/
│   │   │   └── Notification.php
│   │   ├── Reports/
│   │   │   ├── CompletionReport.php
│   │   │   └── ReportPhoto.php
│   │   ├── Tasks/
│   │   │   ├── Task.php
│   │   │   └── TaskHistory.php
│   │   └── Teams/
│   │       └── Team.php
│   ├── Filament/
│   │   ├── Pages/
│   │   │   ├── AdminReportPage.php
│   │   │   ├── ImportTaskPage.php
│   │   │   └── SystemSettingPage.php
│   │   ├── Resources/
│   │   │   ├── AttendanceResource.php
│   │   │   ├── CompletionReportResource.php
│   │   │   ├── NotificationResource.php
│   │   │   ├── TaskResource.php
│   │   │   ├── TeamResource.php
│   │   │   └── UserResource.php
│   │   └── Widgets/
│   │       ├── TaskStatsOverviewWidget.php
│   │       ├── TaskStatusChartWidget.php
│   │       └── UrgentTasksTableWidget.php
│   ├── Models/
│   │   └── User.php
│   ├── Policies/
│   │   ├── AttendancePolicy.php
│   │   ├── CompletionReportPolicy.php
│   │   ├── TaskPolicy.php
│   │   ├── TeamPolicy.php
│   │   └── UserPolicy.php
│   └── Providers/
│       └── Filament/
│           └── AdminPanelProvider.php
```

---

## 🧭 Navigation Groups & Modules

| STT | Navigation Group | Resource / Page / Widget | Chức năng chính |
| :--- | :--- | :--- | :--- |
| **1** | **Tổng quan** | `Dashboard`<br>`TaskStatsOverviewWidget`<br>`TaskStatusChartWidget`<br>`UrgentTasksTableWidget` | Stat cards chỉ số KPI, biểu đồ tròn phân bố trạng thái công việc, bảng việc gấp đưa việc **Chờ duyệt**, **Trễ hạn**, **Cần sửa đổi** lên ưu tiên đầu. |
| **2** | **Nhân sự & đội nhóm** | `UserResource`<br>`TeamResource` | Quản lý tài khoản (Sếp, Quản lý, Thợ), khóa/mở khóa tài khoản có modal xác nhận, phân đội nhóm, gán Leader và danh sách thành viên. |
| **3** | **Công việc** | `TaskResource`<br>`ImportTaskPage` | Tạo CV thủ công, Import Excel với **Preview dữ liệu hợp lệ/lỗi** trước khi lưu, bộ lọc trạng thái, phân công 3 cấp, lịch sử phân công `TaskHistory`. |
| **4** | **Điểm danh** | `AttendanceResource` | Xem nhật ký điểm danh GPS + selfie, bộ lọc ngày/đội/thợ, cảnh báo **Fake GPS (Fake location)**, mở vị trí trên Google Maps. |
| **5** | **Báo cáo & nghiệm thu** | `CompletionReportResource` | Danh sách báo cáo hoàn thành gửi từ thợ, xem ảnh thực tế, action **Duyệt** (chuyển CV -> Hoàn thành), action **Từ chối** (bắt buộc nhập lý do -> CV -> Cần sửa đổi). |
| **6** | **Thông báo** | `NotificationResource` | Quản lý thông báo hệ thống, việc mới, báo cáo chờ duyệt, bộ lọc Đã đọc/Chưa đọc và action Đánh dấu đã đọc hàng loạt. |
| **7** | **Báo cáo quản trị** | `AdminReportPage` | Thống kê hiệu suất theo Quản lý, Theo đội nhóm, Theo thợ thi công, Tỷ lệ hoàn thành công việc, cho phép Xuất file Excel (.xlsx). |
| **8** | **Cấu hình** | `SystemSettingPage` | Thiết lập thông tin đơn vị, bán kính GPS hợp lệ, bật/tắt tự động cảnh báo Fake GPS, kích hoạt Push Notification sang Mobile Flutter. |

---

## 🔒 Phân quyền dữ liệu (Role-Based Authorization & Scope)

1. **Sếp / Tổng quản lý (`director`)**:
   - Toàn quyền xem, tạo, sửa, xóa, khóa tài khoản, phân bổ công việc cho Quản lý.
   - Xem toàn bộ báo cáo, điểm danh và dữ liệu hệ thống.
2. **Quản lý / Leader (`manager`)**:
   - Chỉ xem và quản lý công việc, thợ thi công, nhật ký điểm danh và báo cáo nghiệm thu thuộc **đội nhóm của mình phụ trách**.
   - Giao việc từ danh sách công việc được Sếp phân bổ cho Thợ trong đội.
   - Không có quyền can thiệp vào dữ liệu của đội khác hoặc tài khoản của Sếp.
3. **Thợ thi công (`worker`)**:
   - Không có quyền truy cập vào Web Admin. Thợ thao tác hoàn toàn qua ứng dụng Mobile Flutter.

# Mobile - Flutter

Flutter app dùng cho Thợ và có thể mở rộng cho Quản lý khi đi hiện trường.

## Cấu trúc đề xuất

```text
mobile/
├── lib/
│   ├── app/                  # Khởi tạo app, router
│   ├── core/
│   │   ├── api/              # HTTP client, API response, interceptor
│   │   ├── auth/             # Token, secure storage, session
│   │   └── theme/            # Màu sắc, typography, UI tokens
│   ├── features/
│   │   ├── auth/             # Đăng nhập
│   │   ├── tasks/            # Danh sách/chi tiết/cập nhật việc
│   │   ├── attendance/       # GPS + selfie check-in
│   │   ├── reports/          # Báo cáo ảnh minh chứng
│   │   └── notifications/    # Thông báo
│   └── shared/widgets/       # Widget dùng chung
├── assets/images/
└── test/
```

## Nguyên tắc UX

- Mỗi nghiệp vụ chính của Thợ tối đa 3 chạm.
- Nút lớn, chữ rõ, trạng thái dễ phân biệt.
- Ảnh phải chụp trực tiếp trong app.
- Khi mạng yếu, ưu tiên thông báo rõ và hỗ trợ gửi lại.


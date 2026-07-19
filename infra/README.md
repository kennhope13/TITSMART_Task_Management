# Hạ tầng triển khai

Triển khai đề xuất cho app nội bộ công ty:

- VPS Ubuntu
- Nginx
- PHP-FPM
- MySQL
- Redis
- Supervisor cho Laravel queue worker
- HTTPS bằng Let's Encrypt

## Thư mục

```text
infra/
├── nginx/        # Virtual host cho Laravel
├── supervisor/   # Queue worker
└── docker/       # Docker Compose nếu team muốn chạy local bằng container
```


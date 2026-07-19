# Deployment

Môi trường production đề xuất:

```text
Ubuntu VPS
Nginx
PHP-FPM
MySQL
Redis
Supervisor
HTTPS
```

Checklist bắt buộc:

- Không commit `.env`.
- Bật HTTPS.
- Backup database hằng ngày.
- Chạy queue worker bằng Supervisor.
- Giới hạn port bằng firewall.
- Log không ghi mật khẩu/token.


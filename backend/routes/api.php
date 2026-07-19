<?php

use Illuminate\Support\Facades\Route;

Route::prefix('v1')->group(function () {
    Route::get('/health', fn () => ['status' => 'ok']);

    // Auth
    // POST /api/v1/auth/login
    // POST /api/v1/auth/logout
    // GET  /api/v1/me

    // Mobile task workflow
    // GET  /api/v1/tasks
    // GET  /api/v1/tasks/{task}
    // POST /api/v1/tasks/{task}/start
    // POST /api/v1/attendance/check-in
    // POST /api/v1/tasks/{task}/completion-reports

    // Notifications
    // GET  /api/v1/notifications
    // POST /api/v1/notifications/{notification}/read
});


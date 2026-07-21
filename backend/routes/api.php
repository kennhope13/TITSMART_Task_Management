<?php

use App\Http\Controllers\Api\V1\AttendanceController;
use App\Http\Controllers\Api\V1\AuthController;
use App\Http\Controllers\Api\V1\CompletionReportController;
use App\Http\Controllers\Api\V1\DashboardController;
use App\Http\Controllers\Api\V1\NotificationController;
use App\Http\Controllers\Api\V1\TaskController;
use App\Http\Controllers\Api\V1\TeamController;
use App\Http\Controllers\Api\V1\UserController;
use Illuminate\Support\Facades\Route;

Route::prefix('v1')->group(function () {
    Route::get('/health', fn () => ['status' => 'ok']);

    Route::post('/auth/login', [AuthController::class, 'login'])->middleware('throttle:10,1');

    Route::middleware('auth:sanctum')->group(function () {
        Route::get('/me', [AuthController::class, 'me']);
        Route::post('/auth/logout', [AuthController::class, 'logout']);

        Route::get('/dashboard/summary', [DashboardController::class, 'summary']);

        // Users Management
        Route::get('/users', [UserController::class, 'index']);
        Route::post('/users', [UserController::class, 'store']);
        Route::get('/users/{targetUser}', [UserController::class, 'show']);
        Route::put('/users/{targetUser}', [UserController::class, 'update']);
        Route::post('/users/{targetUser}/lock', [UserController::class, 'lock']);
        Route::post('/users/{targetUser}/unlock', [UserController::class, 'unlock']);

        // Teams Management
        Route::get('/teams', [TeamController::class, 'index']);
        Route::post('/teams', [TeamController::class, 'store']);
        Route::put('/teams/{team}', [TeamController::class, 'update']);
        Route::post('/teams/{team}/members', [TeamController::class, 'addMember']);
        Route::delete('/teams/{team}/members/{userId}', [TeamController::class, 'removeMember']);

        // Tasks Management
        Route::get('/tasks', [TaskController::class, 'index']);
        Route::post('/tasks', [TaskController::class, 'store']);
        Route::get('/tasks/{task}', [TaskController::class, 'show']);
        Route::post('/tasks/{task}/assign-worker', [TaskController::class, 'assignWorker']);
        Route::post('/tasks/{task}/start', [TaskController::class, 'start']);
        Route::post('/tasks/{task}/pause', [TaskController::class, 'pause']);
        Route::post('/tasks/{task}/cancel', [TaskController::class, 'cancel']);
        Route::post('/tasks/{task}/reopen', [TaskController::class, 'reopen']);

        // Completion Reports & Approval
        Route::get('/completion-reports', [CompletionReportController::class, 'index']);
        Route::post('/tasks/{task}/completion-reports', [CompletionReportController::class, 'store']);
        Route::post('/completion-reports/{report}/approve', [CompletionReportController::class, 'approve']);
        Route::post('/completion-reports/{report}/reject', [CompletionReportController::class, 'reject']);

        // Attendance GPS & Selfie
        Route::get('/attendance', [AttendanceController::class, 'index']);
        Route::get('/attendance/my-history', [AttendanceController::class, 'myHistory']);
        Route::post('/attendance/check-in', [AttendanceController::class, 'checkIn']);

        // Notifications
        Route::get('/notifications', [NotificationController::class, 'index']);
        Route::post('/notifications/{notification}/read', [NotificationController::class, 'markAsRead']);
    });
});

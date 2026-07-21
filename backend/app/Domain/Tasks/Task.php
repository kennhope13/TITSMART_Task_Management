<?php

namespace App\Domain\Tasks;

use App\Domain\Reports\CompletionReport;
use App\Domain\Teams\Team;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;

class Task extends Model
{
    use HasFactory;

    protected $fillable = [
        'code',
        'title',
        'description',
        'location',
        'latitude',
        'longitude',
        'status',
        'team_id',
        'manager_id',
        'worker_id',
        'created_by',
        'due_date',
        'completed_at',
    ];

    protected $casts = [
        'due_date' => 'datetime',
        'completed_at' => 'datetime',
        'latitude' => 'float',
        'longitude' => 'float',
    ];

    public static function getStatusOptions(): array
    {
        return [
            'draft' => 'Nháp',
            'pending_assignment' => 'Chờ phân công',
            'assigned_manager' => 'Đã giao Quản lý',
            'assigned_worker' => 'Đã giao Thợ',
            'in_progress' => 'Đang làm',
            'pending_approval' => 'Chờ duyệt',
            'completed' => 'Hoàn thành',
            'needs_revision' => 'Cần sửa đổi',
            'cancelled' => 'Hủy',
        ];
    }

    public static function getStatusLabel(string $status): string
    {
        return static::getStatusOptions()[$status] ?? $status;
    }

    public static function getStatusColor(string $status): string
    {
        return match ($status) {
            'draft' => 'gray',
            'pending_assignment' => 'warning',
            'assigned_manager' => 'info',
            'assigned_worker' => 'primary',
            'in_progress' => 'purple',
            'pending_approval' => 'orange',
            'completed' => 'success',
            'needs_revision' => 'danger',
            'cancelled' => 'slate',
            default => 'secondary',
        };
    }

    public function team(): BelongsTo
    {
        return $this->belongsTo(Team::class, 'team_id');
    }

    public function manager(): BelongsTo
    {
        return $this->belongsTo(User::class, 'manager_id');
    }

    public function worker(): BelongsTo
    {
        return $this->belongsTo(User::class, 'worker_id');
    }

    public function creator(): BelongsTo
    {
        return $this->belongsTo(User::class, 'created_by');
    }

    public function histories(): HasMany
    {
        return $this->hasMany(TaskHistory::class, 'task_id')->latest();
    }

    public function latestCompletionReport(): HasOne
    {
        return $this->hasOne(CompletionReport::class, 'task_id')->latestOfMany();
    }

    public function completionReports(): HasMany
    {
        return $this->hasMany(CompletionReport::class, 'task_id');
    }
}

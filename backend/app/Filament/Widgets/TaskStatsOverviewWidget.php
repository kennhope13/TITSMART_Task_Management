<?php

namespace App\Filament\Widgets;

use App\Domain\Attendance\Attendance;
use App\Domain\Tasks\Task;
use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

class TaskStatsOverviewWidget extends BaseWidget
{
    protected static ?int $sort = 1;

    protected function getColumns(): int
    {
        return 4;
    }

    protected function getStats(): array
    {
        $total = Task::count();
        $inProgress = Task::where('status', 'in_progress')->count();
        $pendingApproval = Task::where('status', 'pending_approval')->count();
        $overdue = Task::whereNotIn('status', ['completed', 'cancelled'])->where('due_date', '<', now())->count();

        return [
            Stat::make('TỔNG CÔNG VIỆC', number_format($total))
                ->description('+12% so với tháng trước')
                ->descriptionIcon('heroicon-m-arrow-trending-up')
                ->color('primary'),

            Stat::make('ĐANG TRIỂN KHAI', number_format($inProgress))
                ->description('Đang thi công thực địa')
                ->descriptionIcon('heroicon-m-wrench-screwdriver')
                ->color('purple'),

            Stat::make('CHỜ DUYỆT NGHIỆM THU', number_format($pendingApproval))
                ->description('Cần xử lý phê duyệt ngay')
                ->descriptionIcon('heroicon-m-exclamation-triangle')
                ->color('warning'),

            Stat::make('CẢNH BÁO TRỄ HẠN', number_format($overdue))
                ->description('Mức độ ưu tiên cao nhất')
                ->descriptionIcon('heroicon-m-x-circle')
                ->color('danger'),
        ];
    }
}

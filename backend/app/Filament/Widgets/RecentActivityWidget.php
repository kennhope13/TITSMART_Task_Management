<?php

namespace App\Filament\Widgets;

use App\Domain\Attendance\Attendance;
use App\Domain\Reports\CompletionReport;
use App\Domain\Tasks\TaskHistory;
use Filament\Widgets\Widget;

class RecentActivityWidget extends Widget
{
    protected static string $view = 'filament.widgets.recent-activity-widget';

    protected static ?int $sort = 3;

    protected int|string|array $columnSpan = [
        'default' => 'full',
        'lg' => 1,
    ];

    public function getActivities(): array
    {
        $activities = [];

        // Fetch recent attendances
        $attendances = Attendance::with('user')
            ->latest()
            ->take(4)
            ->get();

        foreach ($attendances as $att) {
            $activities[] = [
                'type' => 'attendance',
                'title' => ($att->user?->name ?? 'Thợ') . ' đã điểm danh check-in',
                'sub' => 'Vị trí: ' . ($att->address ?? 'Tọa độ thực địa'),
                'time' => $att->check_in_at ? $att->check_in_at->diffForHumans() : 'Mới đây',
                'is_fake' => (bool) $att->is_fake_gps,
                'icon' => 'location_on',
                'color' => $att->is_fake_gps ? 'bg-rose-100 text-rose-600' : 'bg-emerald-100 text-emerald-600',
            ];
        }

        // Fetch recent reports
        $reports = CompletionReport::with(['task', 'worker'])
            ->latest()
            ->take(4)
            ->get();

        foreach ($reports as $rep) {
            $activities[] = [
                'type' => 'report',
                'title' => ($rep->worker?->name ?? 'Thợ') . ' gửi báo cáo hoàn thành',
                'sub' => 'Công việc: ' . ($rep->task?->code ?? '') . ' - ' . ($rep->task?->title ?? ''),
                'time' => $rep->created_at ? $rep->created_at->diffForHumans() : 'Mới đây',
                'is_fake' => false,
                'icon' => 'assignment_turned_in',
                'color' => 'bg-blue-100 text-blue-600',
            ];
        }

        return $activities;
    }
}

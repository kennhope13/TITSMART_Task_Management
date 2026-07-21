<?php

namespace App\Filament\Widgets;

use App\Domain\Tasks\Task;
use Filament\Widgets\ChartWidget;

class TaskStatusChartWidget extends ChartWidget
{
    protected static ?string $heading = '📈 Xu hướng tiến độ công việc 7 ngày gần nhất';

    protected static ?int $sort = 4;

    protected int|string|array $columnSpan = [
        'default' => 'full',
        'lg' => 1,
    ];

    protected static ?string $maxHeight = '200px';

    protected function getData(): array
    {
        $days = collect(range(6, 0))->map(fn ($i) => now()->subDays($i));
        
        $labels = $days->map(fn ($date) => $date->format('d/m'))->toArray();
        
        $completedData = $days->map(fn ($date) => 
            Task::where('status', 'completed')
                ->whereDate('updated_at', $date->toDateString())
                ->count()
        )->toArray();

        $inProgressData = $days->map(fn ($date) => 
            Task::whereIn('status', ['in_progress', 'assigned_worker', 'pending_approval'])
                ->whereDate('updated_at', '<=', $date->toDateString())
                ->count()
        )->toArray();

        return [
            'datasets' => [
                [
                    'label' => 'Đã hoàn thành',
                    'data' => $completedData,
                    'borderColor' => '#16A34A',
                    'backgroundColor' => 'rgba(22, 163, 74, 0.1)',
                    'fill' => true,
                    'tension' => 0.4,
                ],
                [
                    'label' => 'Đang triển khai',
                    'data' => $inProgressData,
                    'borderColor' => '#0058BE',
                    'backgroundColor' => 'rgba(0, 88, 190, 0.1)',
                    'fill' => true,
                    'tension' => 0.4,
                ],
            ],
            'labels' => $labels,
        ];
    }

    protected function getType(): string
    {
        return 'line';
    }

    protected function getOptions(): array
    {
        return [
            'maintainAspectRatio' => false,
            'plugins' => [
                'legend' => [
                    'display' => true,
                    'position' => 'top',
                ],
            ],
            'scales' => [
                'y' => [
                    'beginAtZero' => true,
                    'ticks' => [
                        'stepSize' => 1,
                    ],
                ],
            ],
        ];
    }
}

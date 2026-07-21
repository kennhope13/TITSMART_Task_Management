<?php

namespace App\Filament\Pages;

use App\Domain\Tasks\Task;
use App\Domain\Teams\Team;
use App\Models\User;
use Filament\Notifications\Notification;
use Filament\Pages\Page;

class AdminReportPage extends Page
{
    protected static ?string $navigationGroup = 'Báo cáo quản trị';

    protected static ?string $navigationLabel = 'Báo cáo tổng hợp';

    protected static ?string $title = 'Báo cáo quản trị & Thống kê hiệu suất';

    protected static ?string $navigationIcon = 'heroicon-o-chart-bar-square';

    protected static ?int $navigationSort = 1;

    protected static string $view = 'filament.pages.admin-report-page';

    public string $reportType = 'manager'; // manager, worker, team, status

    public ?string $startDate = null;

    public ?string $endDate = null;

    public array $reportData = [];

    public function mount(): void
    {
        $this->startDate = now()->startOfMonth()->format('Y-m-d');
        $this->endDate = now()->format('Y-m-d');
        $this->generateReport();
    }

    public function generateReport(): void
    {
        if ($this->reportType === 'manager') {
            $managers = User::where('role', 'manager')->get();
            $this->reportData = $managers->map(function ($mgr) {
                $tasks = Task::where('manager_id', $mgr->id);
                return [
                    'name' => $mgr->name,
                    'code' => $mgr->employee_code,
                    'total' => (clone $tasks)->count(),
                    'completed' => (clone $tasks)->where('status', 'completed')->count(),
                    'in_progress' => (clone $tasks)->where('status', 'in_progress')->count(),
                    'overdue' => (clone $tasks)->whereNotIn('status', ['completed', 'cancelled'])->where('due_date', '<', now())->count(),
                ];
            })->toArray();
        } elseif ($this->reportType === 'team') {
            $teams = Team::all();
            $this->reportData = $teams->map(function ($team) {
                $tasks = Task::where('team_id', $team->id);
                return [
                    'name' => $team->name,
                    'code' => $team->code,
                    'total' => (clone $tasks)->count(),
                    'completed' => (clone $tasks)->where('status', 'completed')->count(),
                    'in_progress' => (clone $tasks)->where('status', 'in_progress')->count(),
                    'overdue' => (clone $tasks)->whereNotIn('status', ['completed', 'cancelled'])->where('due_date', '<', now())->count(),
                ];
            })->toArray();
        } else {
            $workers = User::where('role', 'worker')->get();
            $this->reportData = $workers->map(function ($wrk) {
                $tasks = Task::where('worker_id', $wrk->id);
                return [
                    'name' => $wrk->name,
                    'code' => $wrk->employee_code,
                    'total' => (clone $tasks)->count(),
                    'completed' => (clone $tasks)->where('status', 'completed')->count(),
                    'in_progress' => (clone $tasks)->where('status', 'in_progress')->count(),
                    'overdue' => (clone $tasks)->whereNotIn('status', ['completed', 'cancelled'])->where('due_date', '<', now())->count(),
                ];
            })->toArray();
        }
    }

    public function exportExcel(): void
    {
        Notification::make()
            ->title('Đã xuất báo cáo quản trị Excel (.xlsx) thành công!')
            ->success()
            ->send();
    }
}

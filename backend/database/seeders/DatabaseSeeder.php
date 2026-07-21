<?php

namespace Database\Seeders;

use App\Domain\Attendance\Attendance;
use App\Domain\Reports\CompletionReport;
use App\Domain\Reports\ReportPhoto;
use App\Domain\Tasks\Task;
use App\Domain\Tasks\TaskHistory;
use App\Domain\Teams\Team;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        $director = User::create([
            'employee_code' => 'DIR-001',
            'name' => 'Nguyễn Văn Sếp',
            'email' => 'director@titsmart.com',
            'phone' => '0901234567',
            'password' => Hash::make('password'),
            'role' => 'director',
            'status' => 'active',
        ]);

        $manager = User::create([
            'employee_code' => 'MGR-001',
            'name' => 'Trần Văn Quản Lý',
            'email' => 'manager1@titsmart.com',
            'phone' => '0912345678',
            'password' => Hash::make('password'),
            'role' => 'manager',
            'status' => 'active',
            'manager_id' => $director->id,
        ]);

        $worker1 = User::create([
            'employee_code' => 'WRK-001',
            'name' => 'Phạm Văn Thợ',
            'email' => 'worker1@titsmart.com',
            'phone' => '0934567890',
            'password' => Hash::make('password'),
            'role' => 'worker',
            'status' => 'active',
            'manager_id' => $manager->id,
        ]);

        $worker2 = User::create([
            'employee_code' => 'WRK-002',
            'name' => 'Hoàng Văn Thợ',
            'email' => 'worker2@titsmart.com',
            'phone' => '0945678901',
            'password' => Hash::make('password'),
            'role' => 'worker',
            'status' => 'active',
            'manager_id' => $manager->id,
        ]);

        $team = Team::create([
            'code' => 'TEAM-ELEC',
            'name' => 'Đội Thi Công Điện',
            'description' => 'Chuyên lắp đặt và sửa chữa điện công nghiệp.',
            'leader_id' => $manager->id,
        ]);

        $team->members()->attach([$worker1->id, $worker2->id]);

        $task1 = Task::create([
            'code' => 'TASK-2026-001',
            'title' => 'Bảo trì hệ thống điện tầng 3',
            'description' => 'Kiểm tra dây cáp, thay mới aptomat hỏng.',
            'location' => 'Tòa nhà Landmark 81, Bình Thạnh, TP.HCM',
            'latitude' => 10.7951,
            'longitude' => 106.7218,
            'status' => 'assigned_worker',
            'team_id' => $team->id,
            'manager_id' => $manager->id,
            'worker_id' => $worker1->id,
            'created_by' => $director->id,
            'due_date' => now()->addDay(),
        ]);

        $task2 = Task::create([
            'code' => 'TASK-2026-002',
            'title' => 'Sửa chữa máy phát điện dự phòng',
            'description' => 'Thay dầu nhớt và kiểm tra củ đề máy phát.',
            'location' => 'Khu Công Nghiệp Tân Bình',
            'latitude' => 10.8089,
            'longitude' => 106.6341,
            'status' => 'in_progress',
            'team_id' => $team->id,
            'manager_id' => $manager->id,
            'worker_id' => $worker2->id,
            'created_by' => $manager->id,
            'due_date' => now()->subHours(2),
        ]);

        TaskHistory::create([
            'task_id' => $task1->id,
            'user_id' => $manager->id,
            'action' => 'assigned_worker',
            'old_status' => 'assigned_manager',
            'new_status' => 'assigned_worker',
            'notes' => 'Quản lý giao việc cho Thợ.',
        ]);

        Attendance::create([
            'user_id' => $worker1->id,
            'team_id' => $team->id,
            'check_in_at' => now()->subHours(4),
            'latitude' => 10.7951,
            'longitude' => 106.7218,
            'address' => 'Landmark 81, Phường 22, Bình Thạnh, TP.HCM',
            'selfie_photo_path' => 'selfies/worker1_selfie.jpg',
            'is_valid' => true,
            'is_fake_gps' => false,
        ]);

        $report = CompletionReport::create([
            'task_id' => $task2->id,
            'worker_id' => $worker2->id,
            'notes' => 'Đã thay dầu nhớt và kiểm tra máy phát.',
            'status' => 'pending',
        ]);

        ReportPhoto::create([
            'completion_report_id' => $report->id,
            'photo_path' => 'reports/may_phat_after.jpg',
            'caption' => 'Ảnh máy phát sau khi hoàn thành sửa chữa.',
        ]);
    }
}

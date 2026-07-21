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
        // 1. Create Sếp / Director
        $director = User::create([
            'employee_code' => 'DIR-001',
            'name' => 'Nguyễn Văn Sếp (Director)',
            'email' => 'director@titsmart.com',
            'phone' => '0901234567',
            'password' => Hash::make('password'),
            'role' => 'director',
            'status' => 'active',
        ]);

        // 2. Create Managers
        $manager1 = User::create([
            'employee_code' => 'MGR-001',
            'name' => 'Trần Văn Quản Lý 1',
            'email' => 'manager1@titsmart.com',
            'phone' => '0912345678',
            'password' => Hash::make('password'),
            'role' => 'manager',
            'status' => 'active',
            'manager_id' => $director->id,
        ]);

        $manager2 = User::create([
            'employee_code' => 'MGR-002',
            'name' => 'Lê Thị Leader 2',
            'email' => 'manager2@titsmart.com',
            'phone' => '0923456789',
            'password' => Hash::make('password'),
            'role' => 'manager',
            'status' => 'active',
            'manager_id' => $director->id,
        ]);

        // 3. Create Workers
        $worker1 = User::create([
            'employee_code' => 'WRK-001',
            'name' => 'Phạm Văn Thợ 1',
            'email' => 'worker1@titsmart.com',
            'phone' => '0934567890',
            'password' => Hash::make('password'),
            'role' => 'worker',
            'status' => 'active',
            'manager_id' => $manager1->id,
        ]);

        $worker2 = User::create([
            'employee_code' => 'WRK-002',
            'name' => 'Hoàng Văn Thợ 2',
            'email' => 'worker2@titsmart.com',
            'phone' => '0945678901',
            'password' => Hash::make('password'),
            'role' => 'worker',
            'status' => 'active',
            'manager_id' => $manager1->id,
        ]);

        // 4. Create Teams
        $team1 = Team::create([
            'code' => 'TEAM-ELEC',
            'name' => 'Đội Thi Công Điện',
            'description' => 'Chuyên lắp đặt và sửa chữa điện công nghiệp',
            'leader_id' => $manager1->id,
        ]);

        $team1->members()->attach([$worker1->id, $worker2->id]);

        // 5. Create Tasks with status variety
        $task1 = Task::create([
            'code' => 'TASK-2026-001',
            'title' => 'Bảo trì hệ thống điện tầng 3',
            'description' => 'Kiểm tra đường dây cáp, thay mới aptomat hỏng',
            'location' => 'Tòa nhà Landmark 81, Bình Thạnh, TP.HCM',
            'latitude' => 10.7951,
            'longitude' => 106.7218,
            'status' => 'pending_approval',
            'team_id' => $team1->id,
            'manager_id' => $manager1->id,
            'worker_id' => $worker1->id,
            'created_by' => $director->id,
            'due_date' => now()->addDays(1),
        ]);

        $task2 = Task::create([
            'code' => 'TASK-2026-002',
            'title' => 'Sửa chữa máy phát điện dự phòng',
            'description' => 'Thay dầu nhớt và kiểm tra củ đè máy phát',
            'location' => 'Khu Công Nghiệp Tân Bình',
            'latitude' => 10.8089,
            'longitude' => 106.6341,
            'status' => 'in_progress',
            'team_id' => $team1->id,
            'manager_id' => $manager1->id,
            'worker_id' => $worker2->id,
            'created_by' => $manager1->id,
            'due_date' => now()->subHours(2), // Overdue
        ]);

        // 6. Create Attendance entries
        Attendance::create([
            'user_id' => $worker1->id,
            'team_id' => $team1->id,
            'check_in_at' => now()->subHours(4),
            'latitude' => 10.7951,
            'longitude' => 106.7218,
            'address' => 'Landmark 81, Phường 22, Bình Thạnh, TP.HCM',
            'selfie_photo_path' => 'selfies/worker1_selfie.jpg',
            'is_valid' => true,
            'is_fake_gps' => false,
        ]);

        Attendance::create([
            'user_id' => $worker2->id,
            'team_id' => $team1->id,
            'check_in_at' => now()->subHours(5),
            'latitude' => 10.8089,
            'longitude' => 106.6341,
            'address' => 'Vị trí nghi vấn (Fake GPS)',
            'selfie_photo_path' => 'selfies/worker2_selfie.jpg',
            'is_valid' => false,
            'is_fake_gps' => true,
        ]);

        // 7. Create Completion Report pending approval
        $report = CompletionReport::create([
            'task_id' => $task1->id,
            'worker_id' => $worker1->id,
            'notes' => 'Đã thay mới 4 aptomat 32A và gia cố lại tủ điện tầng 3.',
            'status' => 'pending',
        ]);

        ReportPhoto::create([
            'completion_report_id' => $report->id,
            'photo_path' => 'reports/tu_dien_after.jpg',
            'caption' => 'Ảnh tủ điện sau khi hoàn thành sửa chữa',
        ]);
    }
}

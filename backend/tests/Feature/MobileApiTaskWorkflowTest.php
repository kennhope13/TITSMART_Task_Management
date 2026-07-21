<?php

namespace Tests\Feature;

use App\Domain\Reports\CompletionReport;
use App\Domain\Tasks\Task;
use App\Domain\Tasks\TaskHistory;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class MobileApiTaskWorkflowTest extends TestCase
{
    use RefreshDatabase;

    public function test_worker_can_view_and_start_assigned_task(): void
    {
        $worker = $this->createUser('WRK-001', 'worker');
        $task = $this->createTask($worker, 'assigned_worker');

        Sanctum::actingAs($worker);

        $this->getJson('/api/v1/tasks')
            ->assertOk()
            ->assertJsonPath('data.0.id', $task->id)
            ->assertJsonPath('data.0.status', 'assigned_worker');

        $this->postJson("/api/v1/tasks/{$task->id}/start")
            ->assertOk()
            ->assertJsonPath('task.status', 'in_progress');

        $this->assertDatabaseHas('tasks', [
            'id' => $task->id,
            'status' => 'in_progress',
        ]);

        $this->assertDatabaseHas('task_histories', [
            'task_id' => $task->id,
            'action' => 'worker_started_task',
        ]);
    }

    public function test_manager_cannot_submit_worker_completion_report(): void
    {
        $worker = $this->createUser('WRK-002', 'worker');
        $manager = $this->createUser('MNG-001', 'manager');
        $task = $this->createTask($worker, 'in_progress', $manager);

        Sanctum::actingAs($manager);

        $this->postJson("/api/v1/tasks/{$task->id}/completion-reports", [
            'notes' => 'Đã hoàn thành.',
            'photos' => [UploadedFile::fake()->image('proof.jpg')],
        ])->assertForbidden();
    }

    public function test_worker_can_submit_completion_report_with_photos(): void
    {
        Storage::fake('public');

        $worker = $this->createUser('WRK-003', 'worker');
        $task = $this->createTask($worker, 'in_progress');

        Sanctum::actingAs($worker);

        $this->postJson("/api/v1/tasks/{$task->id}/completion-reports", [
            'notes' => 'Đã hoàn thành công việc.',
            'photos' => [UploadedFile::fake()->image('proof.jpg')],
        ])
            ->assertCreated()
            ->assertJsonPath('report.status', 'pending')
            ->assertJsonCount(1, 'report.photos');

        $this->assertDatabaseHas('tasks', [
            'id' => $task->id,
            'status' => 'pending_approval',
        ]);

        $this->assertDatabaseCount((new CompletionReport())->getTable(), 1);
        $this->assertDatabaseHas((new TaskHistory())->getTable(), [
            'task_id' => $task->id,
            'action' => 'worker_submitted_completion_report',
        ]);
    }

    private function createUser(string $employeeCode, string $role): User
    {
        return User::create([
            'employee_code' => $employeeCode,
            'name' => "{$role} Test",
            'email' => strtolower($employeeCode).'@example.com',
            'password' => Hash::make('password'),
            'role' => $role,
            'status' => 'active',
        ]);
    }

    private function createTask(User $worker, string $status, ?User $manager = null): Task
    {
        return Task::create([
            'code' => 'TASK-'.uniqid(),
            'title' => 'Kiểm tra tủ điện',
            'description' => 'Kiểm tra và cập nhật tình trạng.',
            'location' => 'Nhà máy A',
            'latitude' => 10.762622,
            'longitude' => 106.660172,
            'status' => $status,
            'manager_id' => $manager?->id,
            'worker_id' => $worker->id,
            'created_by' => $manager?->id,
            'due_date' => now()->addDay(),
        ]);
    }
}

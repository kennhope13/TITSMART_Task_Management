<?php

namespace App\Http\Controllers\Api\V1;

use App\Domain\Tasks\Task;
use App\Domain\Tasks\TaskHistory;
use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class TaskController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();

        $tasks = Task::query()
            ->with(['team:id,name', 'manager:id,name,employee_code', 'worker:id,name,employee_code'])
            ->when($user->isWorker(), fn ($query) => $query->where('worker_id', $user->id))
            ->when($user->isManager(), fn ($query) => $query->where('manager_id', $user->id))
            ->when($request->filled('status'), fn ($query) => $query->where('status', $request->string('status')))
            ->when($request->filled('search'), function ($query) use ($request) {
                $search = $request->string('search');
                $query->where(function ($q) use ($search) {
                    $q->where('title', 'like', "%{$search}%")
                        ->orWhere('code', 'like', "%{$search}%")
                        ->orWhere('location', 'like', "%{$search}%");
                });
            })
            ->latest()
            ->paginate($request->integer('per_page', 20));

        return response()->json($tasks->through(fn (Task $task) => $this->taskPayload($task)));
    }

    public function store(Request $request): JsonResponse
    {
        $user = $request->user();
        abort_unless($user->isDirector() || $user->isManager(), 403, 'Chỉ Sếp hoặc Quản lý mới được phép giao việc mới.');

        $data = $request->validate([
            'code' => ['required', 'string', 'max:50', 'unique:tasks,code'],
            'title' => ['required', 'string', 'max:255'],
            'description' => ['nullable', 'string'],
            'location' => ['required', 'string', 'max:255'],
            'latitude' => ['nullable', 'numeric'],
            'longitude' => ['nullable', 'numeric'],
            'team_id' => ['nullable', 'exists:teams,id'],
            'manager_id' => ['nullable', 'exists:users,id'],
            'worker_id' => ['nullable', 'exists:users,id'],
            'due_date' => ['required', 'date'],
        ]);

        $status = 'pending_assignment';
        if (!empty($data['worker_id'])) {
            $status = 'assigned_worker';
        } elseif (!empty($data['manager_id'])) {
            $status = 'assigned_manager';
        }

        $task = Task::create(array_merge($data, [
            'status' => $status,
            'created_by' => $user->id,
        ]));

        TaskHistory::create([
            'task_id' => $task->id,
            'user_id' => $user->id,
            'action' => 'created_task',
            'new_status' => $status,
            'notes' => 'Tạo công việc mới từ ứng dụng Mobile.',
        ]);

        return response()->json([
            'message' => 'Tạo công việc mới thành công.',
            'task' => $this->taskPayload($task->fresh(['team', 'manager', 'worker'])),
        ], 201);
    }

    public function show(Request $request, Task $task): JsonResponse
    {
        $this->authorizeTaskAccess($request, $task);

        $task->load([
            'team:id,name',
            'manager:id,name,employee_code',
            'worker:id,name,employee_code',
            'histories.user:id,name,employee_code',
            'latestCompletionReport.photos',
        ]);

        return response()->json(['task' => $this->taskPayload($task, true)]);
    }

    public function assignWorker(Request $request, Task $task): JsonResponse
    {
        $user = $request->user();
        abort_unless($user->isDirector() || $user->isManager(), 403, 'Bạn không có quyền giao việc cho nhân viên.');

        $data = $request->validate([
            'worker_id' => ['required', 'exists:users,id'],
        ]);

        $oldStatus = $task->status;
        $task->update([
            'worker_id' => $data['worker_id'],
            'status' => 'assigned_worker',
        ]);

        TaskHistory::create([
            'task_id' => $task->id,
            'user_id' => $user->id,
            'action' => 'assigned_worker',
            'old_status' => $oldStatus,
            'new_status' => 'assigned_worker',
            'notes' => 'Giao việc cho thợ thực hiện.',
        ]);

        return response()->json([
            'message' => 'Đã giao việc cho thợ thành công.',
            'task' => $this->taskPayload($task->refresh()),
        ]);
    }

    public function start(Request $request, Task $task): JsonResponse
    {
        $this->authorizeTaskAccess($request, $task);

        abort_unless(
            $request->user()->isWorker() && $task->worker_id === $request->user()->id,
            403,
            'Chỉ thợ được giao việc mới có quyền bắt đầu công việc này.'
        );

        if (! in_array($task->status, ['assigned_worker', 'needs_revision'], true)) {
            return response()->json(['message' => 'Công việc không ở trạng thái có thể bắt đầu.'], 422);
        }

        $oldStatus = $task->status;
        $task->update(['status' => 'in_progress']);

        TaskHistory::create([
            'task_id' => $task->id,
            'user_id' => $request->user()->id,
            'action' => 'worker_started_task',
            'old_status' => $oldStatus,
            'new_status' => 'in_progress',
            'notes' => 'Thợ bắt đầu thực hiện công việc từ mobile app.',
        ]);

        return response()->json([
            'message' => 'Đã chuyển công việc sang trạng thái Đang làm.',
            'task' => $this->taskPayload($task->refresh()),
        ]);
    }

    public function pause(Request $request, Task $task): JsonResponse
    {
        $this->authorizeTaskAccess($request, $task);
        $data = $request->validate(['notes' => ['required', 'string', 'max:1000']]);

        $oldStatus = $task->status;
        $task->update(['status' => 'paused']);

        TaskHistory::create([
            'task_id' => $task->id,
            'user_id' => $request->user()->id,
            'action' => 'paused_task',
            'old_status' => $oldStatus,
            'new_status' => 'paused',
            'notes' => $data['notes'],
        ]);

        return response()->json([
            'message' => 'Đã tạm dừng công việc.',
            'task' => $this->taskPayload($task->refresh()),
        ]);
    }

    public function cancel(Request $request, Task $task): JsonResponse
    {
        abort_unless($request->user()->isDirector() || $request->user()->isManager(), 403, 'Bạn không có quyền hủy công việc.');
        $data = $request->validate(['notes' => ['required', 'string', 'max:1000']]);

        $oldStatus = $task->status;
        $task->update(['status' => 'cancelled']);

        TaskHistory::create([
            'task_id' => $task->id,
            'user_id' => $request->user()->id,
            'action' => 'cancelled_task',
            'old_status' => $oldStatus,
            'new_status' => 'cancelled',
            'notes' => 'Hủy việc: ' . $data['notes'],
        ]);

        return response()->json([
            'message' => 'Đã hủy công việc.',
            'task' => $this->taskPayload($task->refresh()),
        ]);
    }

    public function reopen(Request $request, Task $task): JsonResponse
    {
        abort_unless($request->user()->isDirector(), 403, 'Chỉ Sếp mới có quyền mở lại công việc.');
        $data = $request->validate(['notes' => ['required', 'string', 'max:1000']]);

        $oldStatus = $task->status;
        $task->update(['status' => 'in_progress']);

        TaskHistory::create([
            'task_id' => $task->id,
            'user_id' => $request->user()->id,
            'action' => 'reopened_task',
            'old_status' => $oldStatus,
            'new_status' => 'in_progress',
            'notes' => 'Mở lại công việc: ' . $data['notes'],
        ]);

        return response()->json([
            'message' => 'Đã mở lại công việc.',
            'task' => $this->taskPayload($task->refresh()),
        ]);
    }

    private function authorizeTaskAccess(Request $request, Task $task): void
    {
        $user = $request->user();

        if ($user->isDirector()) return;
        abort_if($user->isWorker() && $task->worker_id !== $user->id, 403, 'Bạn không có quyền xem công việc này.');
        abort_if($user->isManager() && $task->manager_id !== $user->id, 403, 'Bạn không có quyền xem công việc này.');
    }

    private function taskPayload(Task $task, bool $includeDetails = false): array
    {
        $payload = [
            'id' => $task->id,
            'code' => $task->code,
            'title' => $task->title,
            'description' => $task->description,
            'location' => $task->location,
            'latitude' => $task->latitude,
            'longitude' => $task->longitude,
            'status' => $task->status,
            'status_label' => Task::getStatusLabel($task->status),
            'team' => $task->team,
            'manager' => $task->manager,
            'worker' => $task->worker,
            'due_date' => $task->due_date?->toISOString(),
            'completed_at' => $task->completed_at?->toISOString(),
            'created_at' => $task->created_at?->toISOString(),
            'updated_at' => $task->updated_at?->toISOString(),
        ];

        if ($includeDetails) {
            $payload['histories'] = $task->histories;
            $payload['latest_completion_report'] = $task->latestCompletionReport;
        }

        return $payload;
    }
}

<?php

namespace App\Http\Controllers\Api\V1;

use App\Domain\Tasks\Task;
use App\Domain\Tasks\TaskHistory;
use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

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
            ->latest()
            ->paginate($request->integer('per_page', 15));

        return response()->json($tasks->through(fn (Task $task) => $this->taskPayload($task)));
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

    private function authorizeTaskAccess(Request $request, Task $task): void
    {
        $user = $request->user();

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

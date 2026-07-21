<?php

namespace App\Http\Controllers\Api\V1;

use App\Domain\Reports\CompletionReport;
use App\Domain\Reports\ReportPhoto;
use App\Domain\Tasks\Task;
use App\Domain\Tasks\TaskHistory;
use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CompletionReportController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();

        $query = CompletionReport::query()
            ->with(['task:id,code,title,location', 'worker:id,name,employee_code', 'photos'])
            ->when($user->isManager(), function ($q) use ($user) {
                $q->whereHas('task', fn ($sub) => $sub->where('manager_id', $user->id));
            })
            ->when($user->isWorker(), function ($q) use ($user) {
                $q->where('worker_id', $user->id);
            })
            ->when($request->filled('status'), fn ($q) => $q->where('status', $request->string('status')));

        return response()->json($query->latest()->paginate($request->integer('per_page', 20)));
    }

    public function store(Request $request, Task $task): JsonResponse
    {
        $user = $request->user();

        abort_unless($user->isWorker(), 403, 'Chỉ thợ được phép gửi báo cáo hoàn thành từ mobile app.');
        abort_if($task->worker_id !== $user->id, 403, 'Bạn không có quyền báo cáo công việc này.');
        abort_if(! in_array($task->status, ['in_progress', 'needs_revision'], true), 422, 'Công việc chưa ở trạng thái có thể gửi báo cáo.');

        $data = $request->validate([
            'notes' => ['nullable', 'string', 'max:3000'],
            'photos' => ['required', 'array', 'min:1', 'max:10'],
            'photos.*' => ['required', 'image', 'max:8192'],
        ]);

        $report = CompletionReport::create([
            'task_id' => $task->id,
            'worker_id' => $user->id,
            'notes' => $data['notes'] ?? null,
            'status' => 'pending',
        ]);

        foreach ($request->file('photos') as $photo) {
            ReportPhoto::create([
                'completion_report_id' => $report->id,
                'photo_path' => $photo->store('reports/evidence', 'public'),
            ]);
        }

        $oldStatus = $task->status;
        $task->update(['status' => 'pending_approval']);

        TaskHistory::create([
            'task_id' => $task->id,
            'user_id' => $user->id,
            'action' => 'worker_submitted_completion_report',
            'old_status' => $oldStatus,
            'new_status' => 'pending_approval',
            'notes' => 'Thợ gửi báo cáo hoàn thành từ mobile app.',
        ]);

        return response()->json([
            'message' => 'Đã gửi báo cáo hoàn thành. Công việc chuyển sang Chờ duyệt.',
            'report' => $report->load('photos'),
        ], 201);
    }

    public function approve(Request $request, CompletionReport $report): JsonResponse
    {
        $user = $request->user();
        abort_unless($user->isDirector() || $user->isManager(), 403, 'Bạn không có quyền nghiệm thu báo cáo này.');

        $task = $report->task;
        $report->update(['status' => 'approved', 'approved_at' => now(), 'approved_by' => $user->id]);

        $oldStatus = $task->status;
        $task->update(['status' => 'completed', 'completed_at' => now()]);

        TaskHistory::create([
            'task_id' => $task->id,
            'user_id' => $user->id,
            'action' => 'manager_approved_report',
            'old_status' => $oldStatus,
            'new_status' => 'completed',
            'notes' => 'Duyệt nghiệm thu báo cáo công việc.',
        ]);

        return response()->json([
            'message' => 'Đã duyệt nghiệm thu báo cáo công việc thành công.',
            'report' => $report->fresh(),
        ]);
    }

    public function reject(Request $request, CompletionReport $report): JsonResponse
    {
        $user = $request->user();
        abort_unless($user->isDirector() || $user->isManager(), 403, 'Bạn không có quyền từ chối báo cáo này.');

        $data = $request->validate([
            'rejection_reason' => ['required', 'string', 'max:1000'],
        ]);

        $task = $report->task;
        $report->update([
            'status' => 'rejected',
            'rejection_reason' => $data['rejection_reason'],
            'rejected_at' => now(),
            'rejected_by' => $user->id,
        ]);

        $oldStatus = $task->status;
        $task->update(['status' => 'needs_revision']);

        TaskHistory::create([
            'task_id' => $task->id,
            'user_id' => $user->id,
            'action' => 'manager_rejected_report',
            'old_status' => $oldStatus,
            'new_status' => 'needs_revision',
            'notes' => 'Từ chối báo cáo: ' . $data['rejection_reason'],
        ]);

        return response()->json([
            'message' => 'Đã yêu cầu thợ sửa đổi lại báo cáo.',
            'report' => $report->fresh(),
        ]);
    }
}

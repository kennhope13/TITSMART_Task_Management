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
}

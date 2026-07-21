<?php

namespace App\Http\Controllers\Api\V1;

use App\Domain\Attendance\Attendance;
use App\Domain\Reports\CompletionReport;
use App\Domain\Tasks\Task;
use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class DashboardController extends Controller
{
    public function summary(Request $request): JsonResponse
    {
        $user = $request->user();

        if ($user->isDirector()) {
            return response()->json([
                'role' => 'director',
                'total_tasks' => Task::count(),
                'pending_assignment' => Task::where('status', 'pending_assignment')->count(),
                'assigned_manager' => Task::where('status', 'assigned_manager')->count(),
                'assigned_worker' => Task::where('status', 'assigned_worker')->count(),
                'in_progress' => Task::where('status', 'in_progress')->count(),
                'pending_approval' => Task::where('status', 'pending_approval')->count(),
                'needs_revision' => Task::where('status', 'needs_revision')->count(),
                'completed' => Task::where('status', 'completed')->count(),
                'overdue' => Task::where('status', 'overdue')->orWhere(function ($q) {
                    $q->whereNotIn('status', ['completed', 'cancelled', 'closed'])
                        ->where('due_date', '<', now());
                })->count(),
                'active_staff' => User::where('status', 'active')->count(),
                'attended_today' => Attendance::whereDate('check_in_at', now()->today())->distinct('user_id')->count('user_id'),
                'pending_reports' => CompletionReport::where('status', 'pending')->count(),
            ]);
        }

        if ($user->isManager()) {
            $managedTaskIds = Task::where('manager_id', $user->id)->pluck('id');

            return response()->json([
                'role' => 'manager',
                'total_tasks' => $managedTaskIds->count(),
                'pending_worker_assignment' => Task::where('manager_id', $user->id)->where('status', 'assigned_manager')->count(),
                'in_progress' => Task::where('manager_id', $user->id)->where('status', 'in_progress')->count(),
                'pending_approval' => Task::where('manager_id', $user->id)->where('status', 'pending_approval')->count(),
                'needs_revision' => Task::where('manager_id', $user->id)->where('status', 'needs_revision')->count(),
                'overdue' => Task::where('manager_id', $user->id)
                    ->whereNotIn('status', ['completed', 'cancelled', 'closed'])
                    ->where('due_date', '<', now())
                    ->count(),
                'team_attended_today' => Attendance::whereDate('check_in_at', now()->today())
                    ->whereIn('user_id', User::where('manager_id', $user->id)->pluck('id'))
                    ->distinct('user_id')
                    ->count('user_id'),
            ]);
        }

        // Worker
        return response()->json([
            'role' => 'worker',
            'assigned_today' => Task::where('worker_id', $user->id)->whereDate('created_at', now()->today())->count(),
            'in_progress' => Task::where('worker_id', $user->id)->where('status', 'in_progress')->count(),
            'pending_approval' => Task::where('worker_id', $user->id)->where('status', 'pending_approval')->count(),
            'needs_revision' => Task::where('worker_id', $user->id)->where('status', 'needs_revision')->count(),
            'attended_today' => Attendance::where('user_id', $user->id)->whereDate('check_in_at', now()->today())->exists(),
        ]);
    }
}

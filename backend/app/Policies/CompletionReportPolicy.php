<?php

namespace App\Policies;

use App\Domain\Reports\CompletionReport;
use App\Models\User;

class CompletionReportPolicy
{
    public function viewAny(User $user): bool
    {
        return $user->isDirector() || $user->isManager();
    }

    public function view(User $user, CompletionReport $report): bool
    {
        if ($user->isDirector()) {
            return true;
        }

        if ($user->isManager()) {
            return $report->task->manager_id === $user->id;
        }

        return false;
    }

    public function approve(User $user, CompletionReport $report): bool
    {
        if ($user->isDirector()) {
            return true;
        }

        return $user->isManager() && $report->task->manager_id === $user->id;
    }

    public function reject(User $user, CompletionReport $report): bool
    {
        if ($user->isDirector()) {
            return true;
        }

        return $user->isManager() && $report->task->manager_id === $user->id;
    }
}

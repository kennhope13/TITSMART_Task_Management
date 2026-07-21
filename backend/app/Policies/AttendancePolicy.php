<?php

namespace App\Policies;

use App\Domain\Attendance\Attendance;
use App\Models\User;

class AttendancePolicy
{
    public function viewAny(User $user): bool
    {
        return $user->isDirector() || $user->isManager();
    }

    public function view(User $user, Attendance $attendance): bool
    {
        if ($user->isDirector()) {
            return true;
        }

        if ($user->isManager()) {
            return $user->ledTeams()->where('id', $attendance->team_id)->exists()
                || $attendance->user->manager_id === $user->id;
        }

        return false;
    }
}

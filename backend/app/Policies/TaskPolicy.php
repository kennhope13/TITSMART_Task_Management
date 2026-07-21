<?php

namespace App\Policies;

use App\Domain\Tasks\Task;
use App\Models\User;

class TaskPolicy
{
    public function viewAny(User $user): bool
    {
        return $user->isDirector() || $user->isManager();
    }

    public function view(User $user, Task $task): bool
    {
        if ($user->isDirector()) {
            return true;
        }

        if ($user->isManager()) {
            return $task->manager_id === $user->id || $user->ledTeams()->where('id', $task->team_id)->exists();
        }

        return false;
    }

    public function create(User $user): bool
    {
        return $user->isDirector() || $user->isManager();
    }

    public function update(User $user, Task $task): bool
    {
        if ($user->isDirector()) {
            return true;
        }

        if ($user->isManager()) {
            return $task->manager_id === $user->id;
        }

        return false;
    }

    public function delete(User $user, Task $task): bool
    {
        return $user->isDirector();
    }

    public function assignManager(User $user): bool
    {
        return $user->isDirector();
    }

    public function assignWorker(User $user, Task $task): bool
    {
        if ($user->isDirector()) {
            return true;
        }

        return $user->isManager() && $task->manager_id === $user->id;
    }
}

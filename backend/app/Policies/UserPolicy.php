<?php

namespace App\Policies;

use App\Models\User;

class UserPolicy
{
    public function viewAny(User $user): bool
    {
        return $user->isDirector() || $user->isManager();
    }

    public function view(User $user, User $model): bool
    {
        if ($user->isDirector()) {
            return true;
        }

        if ($user->isManager()) {
            return $model->manager_id === $user->id || $model->id === $user->id;
        }

        return false;
    }

    public function create(User $user): bool
    {
        return $user->isDirector();
    }

    public function update(User $user, User $model): bool
    {
        if ($user->isDirector()) {
            return true;
        }

        if ($user->isManager()) {
            return $model->manager_id === $user->id && $model->role === 'worker';
        }

        return false;
    }

    public function delete(User $user, User $model): bool
    {
        return $user->isDirector();
    }

    public function toggleLock(User $user, User $model): bool
    {
        if ($user->isDirector()) {
            return $user->id !== $model->id; // cannot lock self
        }

        return false;
    }
}

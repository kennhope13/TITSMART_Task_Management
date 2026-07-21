<?php

namespace App\Policies;

use App\Domain\Teams\Team;
use App\Models\User;

class TeamPolicy
{
    public function viewAny(User $user): bool
    {
        return $user->isDirector() || $user->isManager();
    }

    public function view(User $user, Team $team): bool
    {
        if ($user->isDirector()) {
            return true;
        }

        return $team->leader_id === $user->id;
    }

    public function create(User $user): bool
    {
        return $user->isDirector();
    }

    public function update(User $user, Team $team): bool
    {
        if ($user->isDirector()) {
            return true;
        }

        return $team->leader_id === $user->id;
    }

    public function delete(User $user, Team $team): bool
    {
        return $user->isDirector();
    }
}

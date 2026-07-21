<?php

namespace App\Http\Controllers\Api\V1;

use App\Domain\Teams\Team;
use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class TeamController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();

        $query = Team::query()
            ->with(['leader:id,name,employee_code', 'members:id,name,employee_code,role'])
            ->withCount('members');

        if ($user->isManager()) {
            $query->where(function ($q) use ($user) {
                $q->where('leader_id', $user->id)
                    ->orWhereHas('members', fn ($sub) => $sub->where('users.id', $user->id));
            });
        }

        return response()->json($query->get());
    }

    public function store(Request $request): JsonResponse
    {
        abort_unless($request->user()->isDirector(), 403, 'Chỉ Sếp mới có quyền tạo Đội/Nhóm mới.');

        $data = $request->validate([
            'name' => ['required', 'string', 'max:255', 'unique:teams,name'],
            'description' => ['nullable', 'string', 'max:1000'],
            'leader_id' => ['nullable', 'exists:users,id'],
        ]);

        $team = Team::create($data);

        return response()->json([
            'message' => 'Tạo Đội/Nhóm thành công.',
            'team' => $team->load('leader'),
        ], 201);
    }

    public function update(Request $request, Team $team): JsonResponse
    {
        abort_unless($request->user()->isDirector(), 403, 'Chỉ Sếp mới có quyền cập nhật Đội/Nhóm.');

        $data = $request->validate([
            'name' => ['sometimes', 'string', 'max:255'],
            'description' => ['nullable', 'string', 'max:1000'],
            'leader_id' => ['nullable', 'exists:users,id'],
        ]);

        $team->update($data);

        return response()->json([
            'message' => 'Cập nhật Đội/Nhóm thành công.',
            'team' => $team->refresh()->load('leader'),
        ]);
    }

    public function addMember(Request $request, Team $team): JsonResponse
    {
        abort_unless($request->user()->isDirector() || $team->leader_id === $request->user()->id, 403, 'Bạn không có quyền thêm thành viên vào đội này.');

        $data = $request->validate([
            'user_id' => ['required', 'exists:users,id'],
        ]);

        $team->members()->syncWithoutDetaching([$data['user_id']]);

        return response()->json([
            'message' => 'Đã thêm thành viên vào Đội.',
            'team' => $team->load('members'),
        ]);
    }

    public function removeMember(Request $request, Team $team, int $userId): JsonResponse
    {
        abort_unless($request->user()->isDirector() || $team->leader_id === $request->user()->id, 403, 'Bạn không có quyền xóa thành viên khỏi đội này.');

        $team->members()->detach($userId);

        return response()->json([
            'message' => 'Đã xóa thành viên khỏi Đội.',
            'team' => $team->load('members'),
        ]);
    }
}

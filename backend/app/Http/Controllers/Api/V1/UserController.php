<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rule;

class UserController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();

        $query = User::query()
            ->with(['manager:id,name,employee_code', 'teams:id,name'])
            ->when($user->isManager(), function ($q) use ($user) {
                $q->where('manager_id', $user->id)->orWhere('id', $user->id);
            })
            ->when($user->isWorker(), function ($q) use ($user) {
                $q->where('id', $user->id);
            })
            ->when($request->filled('role'), fn ($q) => $q->where('role', $request->string('role')))
            ->when($request->filled('status'), fn ($q) => $q->where('status', $request->string('status')))
            ->when($request->filled('search'), function ($q) use ($request) {
                $search = $request->string('search');
                $q->where(function ($sub) use ($search) {
                    $sub->where('name', 'like', "%{$search}%")
                        ->orWhere('employee_code', 'like', "%{$search}%")
                        ->orWhere('email', 'like', "%{$search}%")
                        ->orWhere('phone', 'like', "%{$search}%");
                });
            });

        $users = $query->latest()->paginate($request->integer('per_page', 20));

        return response()->json($users);
    }

    public function store(Request $request): JsonResponse
    {
        abort_unless($request->user()->isDirector(), 403, 'Chỉ Sếp / Tổng quản lý mới được phép thêm nhân sự mới.');

        $data = $request->validate([
            'employee_code' => ['required', 'string', 'max:50', 'unique:users,employee_code'],
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'email', 'max:255', 'unique:users,email'],
            'phone' => ['nullable', 'string', 'max:20'],
            'role' => ['required', Rule::in(['director', 'manager', 'worker'])],
            'status' => ['required', Rule::in(['active', 'inactive'])],
            'manager_id' => ['nullable', 'exists:users,id'],
            'password' => ['required', 'string', 'min:6'],
        ]);

        $data['password'] = Hash::make($data['password']);
        $user = User::create($data);

        return response()->json([
            'message' => 'Tạo tài khoản nhân sự thành công.',
            'user' => $user,
        ], 201);
    }

    public function show(Request $request, User $targetUser): JsonResponse
    {
        $user = $request->user();
        if ($user->isWorker() && $user->id !== $targetUser->id) {
            abort(403, 'Bạn không có quyền xem thông tin nhân sự này.');
        }
        if ($user->isManager() && $targetUser->manager_id !== $user->id && $targetUser->id !== $user->id) {
            abort(403, 'Bạn chỉ được xem nhân sự trong đội của mình.');
        }

        return response()->json(['user' => $targetUser->load(['manager', 'teams'])]);
    }

    public function update(Request $request, User $targetUser): JsonResponse
    {
        abort_unless($request->user()->isDirector(), 403, 'Chỉ Sếp mới có quyền cập nhật thông tin nhân sự.');

        $data = $request->validate([
            'name' => ['sometimes', 'string', 'max:255'],
            'email' => ['sometimes', 'email', 'max:255', Rule::unique('users')->ignore($targetUser->id)],
            'phone' => ['nullable', 'string', 'max:20'],
            'role' => ['sometimes', Rule::in(['director', 'manager', 'worker'])],
            'status' => ['sometimes', Rule::in(['active', 'inactive'])],
            'manager_id' => ['nullable', 'exists:users,id'],
            'password' => ['nullable', 'string', 'min:6'],
        ]);

        if (!empty($data['password'])) {
            $data['password'] = Hash::make($data['password']);
        } else {
            unset($data['password']);
        }

        $targetUser->update($data);

        return response()->json([
            'message' => 'Cập nhật thông tin nhân sự thành công.',
            'user' => $targetUser->refresh(),
        ]);
    }

    public function lock(Request $request, User $targetUser): JsonResponse
    {
        abort_unless($request->user()->isDirector(), 403, 'Chỉ Sếp mới được phép khóa tài khoản.');
        $targetUser->update(['status' => 'inactive']);

        return response()->json([
            'message' => 'Đã khóa tài khoản nhân sự ' . $targetUser->name,
            'user' => $targetUser,
        ]);
    }

    public function unlock(Request $request, User $targetUser): JsonResponse
    {
        abort_unless($request->user()->isDirector(), 403, 'Chỉ Sếp mới được phép mở khóa tài khoản.');
        $targetUser->update(['status' => 'active']);

        return response()->json([
            'message' => 'Đã mở khóa tài khoản nhân sự ' . $targetUser->name,
            'user' => $targetUser,
        ]);
    }
}

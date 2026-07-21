<?php

namespace App\Http\Controllers\Api\V1;

use App\Domain\Attendance\Attendance;
use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AttendanceController extends Controller
{
    public function checkIn(Request $request): JsonResponse
    {
        $data = $request->validate([
            'latitude' => ['required', 'numeric', 'between:-90,90'],
            'longitude' => ['required', 'numeric', 'between:-180,180'],
            'address' => ['nullable', 'string', 'max:500'],
            'selfie_photo' => ['required', 'image', 'max:5120'],
            'is_fake_gps' => ['nullable', 'boolean'],
            'notes' => ['nullable', 'string', 'max:1000'],
        ]);

        $user = $request->user();
        abort_unless($user->isWorker() || $user->isManager(), 403, 'Vai trò này không được điểm danh bằng mobile.');

        $attendance = Attendance::create([
            'user_id' => $user->id,
            'team_id' => $user->teams()->value('teams.id'),
            'check_in_at' => now(),
            'latitude' => $data['latitude'],
            'longitude' => $data['longitude'],
            'address' => $data['address'] ?? null,
            'selfie_photo_path' => $request->file('selfie_photo')->store('attendance/selfies', 'public'),
            'is_valid' => ! (bool) ($data['is_fake_gps'] ?? false),
            'is_fake_gps' => (bool) ($data['is_fake_gps'] ?? false),
            'notes' => $data['notes'] ?? null,
        ]);

        return response()->json([
            'message' => 'Điểm danh thành công.',
            'attendance' => $attendance,
        ], 201);
    }
}

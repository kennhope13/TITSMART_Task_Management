<?php

namespace App\Http\Controllers\Api\V1;

use App\Domain\Notifications\Notification;
use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        return response()->json(
            Notification::query()
                ->where('user_id', $request->user()->id)
                ->latest()
                ->paginate($request->integer('per_page', 20))
        );
    }

    public function markAsRead(Request $request, Notification $notification): JsonResponse
    {
        abort_if($notification->user_id !== $request->user()->id, 403, 'Bạn không có quyền cập nhật thông báo này.');

        $notification->update([
            'is_read' => true,
            'read_at' => now(),
        ]);

        return response()->json([
            'message' => 'Đã đánh dấu thông báo là đã đọc.',
            'notification' => $notification,
        ]);
    }
}

<?php

namespace App\Filament\Resources\TaskResource\Pages;

use App\Domain\Tasks\TaskHistory;
use App\Filament\Resources\TaskResource;
use Filament\Resources\Pages\CreateRecord;

class CreateTask extends CreateRecord
{
    protected static string $resource = TaskResource::class;

    protected function afterCreate(): void
    {
        TaskHistory::create([
            'task_id' => $this->record->id,
            'user_id' => auth()->id(),
            'action' => 'Tạo mới công việc',
            'old_status' => null,
            'new_status' => $this->record->status,
            'notes' => 'Công việc được khởi tạo trên hệ thống Web Admin.',
        ]);
    }
}

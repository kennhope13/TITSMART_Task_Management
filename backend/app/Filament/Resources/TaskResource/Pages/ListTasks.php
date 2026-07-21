<?php

namespace App\Filament\Resources\TaskResource\Pages;

use App\Filament\Resources\TaskResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListTasks extends ListRecords
{
    protected static string $resource = TaskResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make()->label('Tạo công việc mới'),
            Actions\Action::make('importExcel')
                ->label('Import từ Excel')
                ->icon('heroicon-o-arrow-up-tray')
                ->color('success')
                ->url(route('filament.admin.pages.import-task-page')),
        ];
    }
}

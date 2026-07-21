<?php

namespace App\Filament\Resources\CompletionReportResource\Pages;

use App\Filament\Resources\CompletionReportResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListCompletionReports extends ListRecords
{
    protected static string $resource = CompletionReportResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make()->label('Tạo báo cáo thủ công'),
        ];
    }
}

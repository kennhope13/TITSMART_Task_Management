<?php

namespace App\Filament\Resources\CompletionReportResource\Pages;

use App\Filament\Resources\CompletionReportResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditCompletionReport extends EditRecord
{
    protected static string $resource = CompletionReportResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\DeleteAction::make(),
        ];
    }
}

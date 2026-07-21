<?php

namespace App\Filament\Widgets;

use App\Domain\Tasks\Task;
use App\Filament\Resources\TaskResource;
use Filament\Tables;
use Filament\Tables\Table;
use Filament\Widgets\TableWidget as BaseWidget;

class UrgentTasksTableWidget extends BaseWidget
{
    protected static ?int $sort = 2;

    protected int|string|array $columnSpan = 'full';

    protected static ?string $heading = '⚡ Công việc cần xử lý gấp (Chờ duyệt, Trễ hạn, Cần sửa đổi)';

    public function table(Table $table): Table
    {
        return $table
            ->query(
                Task::query()
                    ->whereIn('status', ['pending_approval', 'needs_revision'])
                    ->orWhere(function ($query) {
                        $query->whereNotIn('status', ['completed', 'cancelled'])
                            ->where('due_date', '<', now());
                    })
                    ->latest()
            )
            ->columns([
                Tables\Columns\TextColumn::make('code')
                    ->label('ID')
                    ->weight('bold')
                    ->copyable()
                    ->fontFamily(\Filament\Support\Enums\FontFamily::Mono)
                    ->color('primary'),

                Tables\Columns\TextColumn::make('title')
                    ->label('Tên công việc')
                    ->weight('semibold')
                    ->description(fn (Task $record): string => $record->location ?? ''),

                Tables\Columns\TextColumn::make('status')
                    ->label('Trạng thái')
                    ->badge()
                    ->formatStateUsing(fn (string $state): string => Task::getStatusLabel($state))
                    ->color(fn (string $state): string => Task::getStatusColor($state)),

                Tables\Columns\TextColumn::make('due_date')
                    ->label('Hạn xử lý')
                    ->dateTime('d/m/Y H:i')
                    ->color(fn (Task $record): string => $record->due_date && $record->due_date->isPast() ? 'danger' : 'gray')
                    ->weight(fn (Task $record): string => ($record->due_date && $record->due_date->isPast()) ? 'bold' : 'normal'),

                Tables\Columns\TextColumn::make('manager.name')
                    ->label('Quản lý')
                    ->default('Chưa giao'),

                Tables\Columns\TextColumn::make('worker.name')
                    ->label('Thợ thi công')
                    ->default('Chưa giao'),
            ])
            ->actions([
                Tables\Actions\Action::make('viewDetail')
                    ->label('Chi tiết')
                    ->icon('heroicon-o-eye')
                    ->url(fn (Task $record): string => TaskResource::getUrl('edit', ['record' => $record])),
            ]);
    }
}

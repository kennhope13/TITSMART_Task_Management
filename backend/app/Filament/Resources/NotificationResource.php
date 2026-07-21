<?php

namespace App\Filament\Resources;

use App\Domain\Notifications\Notification;
use App\Filament\Resources\NotificationResource\Pages;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

class NotificationResource extends Resource
{
    protected static ?string $model = Notification::class;

    protected static ?string $navigationGroup = 'Thông báo';

    protected static ?string $navigationLabel = 'Thông báo hệ thống';

    protected static ?string $modelLabel = 'Thông báo';

    protected static ?string $pluralModelLabel = 'Danh sách thông báo';

    protected static ?string $navigationIcon = 'heroicon-o-bell';

    protected static ?int $navigationSort = 1;

    public static function getEloquentQuery(): Builder
    {
        return parent::getEloquentQuery()->where('user_id', auth()->id());
    }

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\TextInput::make('title')
                    ->label('Tiêu đề thông báo')
                    ->required(),

                Forms\Components\Select::make('type')
                    ->label('Loại thông báo')
                    ->options([
                        'task_assigned' => 'Công việc mới',
                        'pending_approval' => 'Báo cáo chờ duyệt',
                        'report_rejected' => 'Báo cáo bị từ chối',
                        'system' => 'Thông báo hệ thống',
                    ])
                    ->required(),

                Forms\Components\Textarea::make('content')
                    ->label('Nội dung thông báo')
                    ->rows(3)
                    ->columnSpanFull(),

                Forms\Components\Toggle::make('is_read')
                    ->label('Đã đọc'),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('title')
                    ->label('Tiêu đề')
                    ->weight('bold')
                    ->searchable(),

                Tables\Columns\TextColumn::make('type')
                    ->label('Loại')
                    ->badge()
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        'task_assigned' => 'Công việc mới',
                        'pending_approval' => 'Chờ duyệt',
                        'report_rejected' => 'Bị từ chối',
                        default => 'Hệ thống',
                    })
                    ->color(fn (string $state): string => match ($state) {
                        'task_assigned' => 'info',
                        'pending_approval' => 'warning',
                        'report_rejected' => 'danger',
                        default => 'secondary',
                    }),

                Tables\Columns\TextColumn::make('content')
                    ->label('Nội dung')
                    ->limit(40),

                Tables\Columns\IconColumn::make('is_read')
                    ->label('Đã đọc')
                    ->boolean()
                    ->trueIcon('heroicon-o-check-circle')
                    ->falseIcon('heroicon-o-envelope')
                    ->trueColor('gray')
                    ->falseColor('primary'),

                Tables\Columns\TextColumn::make('created_at')
                    ->label('Thời gian')
                    ->dateTime('d/m/Y H:i')
                    ->sortable(),
            ])
            ->filters([
                Tables\Filters\TernaryFilter::make('is_read')
                    ->label('Bộ lọc Đã đọc / Chưa đọc')
                    ->boolean(),
            ])
            ->actions([
                Tables\Actions\Action::make('markRead')
                    ->label('Đánh dấu đã đọc')
                    ->icon('heroicon-o-check')
                    ->color('success')
                    ->hidden(fn (Notification $record): bool => $record->is_read)
                    ->action(function (Notification $record) {
                        $record->is_read = true;
                        $record->read_at = now();
                        $record->save();
                    }),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\BulkAction::make('bulkMarkRead')
                        ->label('Đánh dấu đã đọc hàng loạt')
                        ->icon('heroicon-o-check-circle')
                        ->action(function (\Illuminate\Database\Eloquent\Collection $records) {
                            foreach ($records as $record) {
                                $record->is_read = true;
                                $record->read_at = now();
                                $record->save();
                            }
                        }),
                ]),
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListNotifications::route('/'),
            'create' => Pages\CreateNotification::route('/create'),
            'edit' => Pages\EditNotification::route('/{record}/edit'),
        ];
    }
}

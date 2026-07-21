<?php

namespace App\Filament\Resources;

use App\Domain\Reports\CompletionReport;
use App\Domain\Tasks\TaskHistory;
use App\Filament\Resources\CompletionReportResource\Pages;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Notifications\Notification;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

class CompletionReportResource extends Resource
{
    protected static ?string $model = CompletionReport::class;

    protected static ?string $navigationGroup = 'Báo cáo & nghiệm thu';

    protected static ?string $navigationLabel = 'Báo cáo hoàn thành';

    protected static ?string $modelLabel = 'Báo cáo nghiệm thu';

    protected static ?string $pluralModelLabel = 'Báo cáo hoàn thành';

    protected static ?string $navigationIcon = 'heroicon-o-check-badge';

    protected static ?int $navigationSort = 1;

    public static function getEloquentQuery(): Builder
    {
        $query = parent::getEloquentQuery();
        $user = auth()->user();

        if ($user && $user->isManager()) {
            $query->whereHas('task', fn ($q) => $q->where('manager_id', $user->id));
        }

        return $query;
    }

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Thông tin báo cáo nghiệm thu')
                    ->schema([
                        Forms\Components\Select::make('task_id')
                            ->label('Công việc liên quan')
                            ->relationship('task', 'title')
                            ->required(),

                        Forms\Components\Select::make('worker_id')
                            ->label('Thợ gửi báo cáo')
                            ->relationship('worker', 'name')
                            ->required(),

                        Forms\Components\Select::make('status')
                            ->label('Trạng thái duyệt')
                            ->options([
                                'pending' => 'Chờ duyệt',
                                'approved' => 'Đã duyệt (Hoàn thành)',
                                'rejected' => 'Bị từ chối (Cần sửa)',
                            ])
                            ->default('pending')
                            ->required(),

                        Forms\Components\Textarea::make('notes')
                            ->label('Ghi chú từ Thợ thi công')
                            ->columnSpanFull(),

                        Forms\Components\Textarea::make('rejection_reason')
                            ->label('Lý do từ chối (nếu có)')
                            ->columnSpanFull(),
                    ])->columns(2),

                Forms\Components\Section::make('Ảnh minh chứng nghiệm thu')
                    ->schema([
                        Forms\Components\Repeater::make('photos')
                            ->relationship('photos')
                            ->schema([
                                Forms\Components\FileUpload::make('photo_path')
                                    ->label('Ảnh chụp thực tế')
                                    ->image()
                                    ->disk('public')
                                    ->directory('reports')
                                    ->required(),
                                Forms\Components\TextInput::make('caption')
                                    ->label('Ghi chú ảnh'),
                            ])->columns(2),
                    ]),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('task.code')
                    ->label('Mã CV')
                    ->weight('bold')
                    ->searchable()
                    ->sortable(),

                Tables\Columns\TextColumn::make('task.title')
                    ->label('Tên công việc')
                    ->searchable()
                    ->limit(25),

                Tables\Columns\TextColumn::make('worker.name')
                    ->label('Thợ thi công')
                    ->searchable(),

                Tables\Columns\TextColumn::make('status')
                    ->label('Trạng thái duyệt')
                    ->badge()
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        'pending' => 'Chờ duyệt',
                        'approved' => 'Đã nghiệm thu',
                        'rejected' => 'Từ chối nghiệm thu',
                        default => $state,
                    })
                    ->color(fn (string $state): string => match ($state) {
                        'pending' => 'warning',
                        'approved' => 'success',
                        'rejected' => 'danger',
                        default => 'secondary',
                    }),

                Tables\Columns\TextColumn::make('notes')
                    ->label('Ghi chú thợ')
                    ->limit(20),

                Tables\Columns\TextColumn::make('rejection_reason')
                    ->label('Lý do từ chối')
                    ->limit(20)
                    ->color('danger')
                    ->default('—'),

                Tables\Columns\TextColumn::make('created_at')
                    ->label('Thời gian gửi')
                    ->dateTime('d/m/Y H:i')
                    ->sortable(),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('status')
                    ->label('Bộ lọc Trạng thái')
                    ->options([
                        'pending' => 'Chờ duyệt',
                        'approved' => 'Đã duyệt',
                        'rejected' => 'Bị từ chối',
                    ]),
            ])
            ->actions([
                // Action Duyệt Báo Cáo
                Tables\Actions\Action::make('approve')
                    ->label('Duyệt')
                    ->icon('heroicon-o-check-circle')
                    ->color('success')
                    ->requiresConfirmation()
                    ->modalHeading('Xác nhận nghiệm thu công việc')
                    ->modalDescription('Sau khi duyệt, công việc sẽ chuyển sang trạng thái Hoàn thành.')
                    ->visible(fn (CompletionReport $record): bool => $record->status === 'pending')
                    ->action(function (CompletionReport $record) {
                        $record->status = 'approved';
                        $record->reviewed_by = auth()->id();
                        $record->reviewed_at = now();
                        $record->save();

                        if ($record->task) {
                            $oldStatus = $record->task->status;
                            $record->task->status = 'completed';
                            $record->task->completed_at = now();
                            $record->task->save();

                            TaskHistory::create([
                                'task_id' => $record->task->id,
                                'user_id' => auth()->id(),
                                'action' => 'Nghệ thu & Duyệt báo cáo',
                                'old_status' => $oldStatus,
                                'new_status' => 'completed',
                                'notes' => 'Báo cáo hoàn thành đã được chấp thuận.',
                            ]);
                        }

                        Notification::make()
                            ->title('Đã duyệt báo cáo hoàn thành công việc!')
                            ->success()
                            ->send();
                    }),

                // Action Từ chối Báo Cáo (Modal bắt buộc nhập lý do)
                Tables\Actions\Action::make('reject')
                    ->label('Từ chối')
                    ->icon('heroicon-o-x-circle')
                    ->color('danger')
                    ->visible(fn (CompletionReport $record): bool => $record->status === 'pending')
                    ->form([
                        Forms\Components\Textarea::make('rejection_reason')
                            ->label('Lý do từ chối nghiệm thu (Bắt buộc)')
                            ->placeholder('Nhập chi tiết lỗi hoặc các mục cần sửa đổi...')
                            ->required()
                            ->rows(3),
                    ])
                    ->action(function (CompletionReport $record, array $data) {
                        $record->status = 'rejected';
                        $record->rejection_reason = $data['rejection_reason'];
                        $record->reviewed_by = auth()->id();
                        $record->reviewed_at = now();
                        $record->save();

                        if ($record->task) {
                            $oldStatus = $record->task->status;
                            $record->task->status = 'needs_revision';
                            $record->task->save();

                            TaskHistory::create([
                                'task_id' => $record->task->id,
                                'user_id' => auth()->id(),
                                'action' => 'Từ chối nghiệm thu',
                                'old_status' => $oldStatus,
                                'new_status' => 'needs_revision',
                                'notes' => "Lý do từ chối: {$data['rejection_reason']}",
                            ]);
                        }

                        Notification::make()
                            ->title('Đã từ chối báo cáo. Yêu cầu thợ sửa đổi.')
                            ->warning()
                            ->send();
                    }),

                Tables\Actions\EditAction::make(),
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListCompletionReports::route('/'),
            'create' => Pages\CreateCompletionReport::route('/create'),
            'edit' => Pages\EditCompletionReport::route('/{record}/edit'),
        ];
    }
}

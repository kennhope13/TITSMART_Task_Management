<?php

namespace App\Filament\Resources;

use App\Domain\Tasks\Task;
use App\Domain\Tasks\TaskHistory;
use App\Domain\Teams\Team;
use App\Filament\Resources\TaskResource\Pages;
use App\Models\User;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

class TaskResource extends Resource
{
    protected static ?string $model = Task::class;

    protected static ?string $navigationGroup = 'Công việc';

    protected static ?string $navigationLabel = 'Danh sách công việc';

    protected static ?string $modelLabel = 'Công việc';

    protected static ?string $pluralModelLabel = 'Danh sách công việc';

    protected static ?string $navigationIcon = 'heroicon-o-clipboard-document-list';

    protected static ?int $navigationSort = 1;

    public static function getEloquentQuery(): Builder
    {
        $query = parent::getEloquentQuery();
        $user = auth()->user();

        if ($user && $user->isManager()) {
            $query->where(function ($q) use ($user) {
                $q->where('manager_id', $user->id)
                  ->orWhereIn('team_id', $user->ledTeams()->pluck('id'));
            });
        }

        return $query;
    }

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Thông tin chính công việc')
                    ->schema([
                        Forms\Components\TextInput::make('code')
                            ->label('Mã công việc')
                            ->required()
                            ->unique(ignoreRecord: true)
                            ->default(fn () => 'TASK-' . strtoupper(substr(md5(uniqid()), 0, 6))),

                        Forms\Components\TextInput::make('title')
                            ->label('Tên công việc')
                            ->required()
                            ->placeholder('Sửa chữa hệ thống điện tầng 3'),

                        Forms\Components\Select::make('status')
                            ->label('Trạng thái')
                            ->options(Task::getStatusOptions())
                            ->default('draft')
                            ->required(),

                        Forms\Components\DateTimePicker::make('due_date')
                            ->label('Hạn hoàn thành (Deadline)')
                            ->required(),

                        Forms\Components\TextInput::make('location')
                            ->label('Địa điểm thi công')
                            ->placeholder('Tòa nhà A, Số 123 Nguyễn Trãi, Thanh Xuân'),

                        Forms\Components\Grid::make(2)
                            ->schema([
                                Forms\Components\TextInput::make('latitude')
                                    ->label('Vĩ độ (Latitude)')
                                    ->numeric()
                                    ->placeholder('21.028511'),

                                Forms\Components\TextInput::make('longitude')
                                    ->label('Kinh độ (Longitude)')
                                    ->numeric()
                                    ->placeholder('105.804817'),
                            ]),

                        Forms\Components\Textarea::make('description')
                            ->label('Mô tả công việc & Yêu cầu kỹ thuật')
                            ->rows(4)
                            ->columnSpanFull(),
                    ])->columns(2),

                Forms\Components\Section::make('Phân công & Đội nhóm')
                    ->schema([
                        Forms\Components\Select::make('team_id')
                            ->label('Đội nhóm đảm nhận')
                            ->options(Team::pluck('name', 'id'))
                            ->searchable()
                            ->nullable()
                            ->reactive()
                            ->afterStateUpdated(fn (callable $set) => $set('worker_id', null)),

                        Forms\Components\Select::make('manager_id')
                            ->label('Quản lý phụ trách')
                            ->options(User::where('role', 'manager')->pluck('name', 'id'))
                            ->searchable()
                            ->nullable(),

                        Forms\Components\Select::make('worker_id')
                            ->label('Thợ thi công')
                            ->options(function (callable $get) {
                                $teamId = $get('team_id');
                                if ($teamId) {
                                    $team = Team::find($teamId);
                                    if ($team) {
                                        return $team->members()->pluck('name', 'users.id');
                                    }
                                }
                                return User::where('role', 'worker')->pluck('name', 'id');
                            })
                            ->searchable()
                            ->nullable(),
                    ])->columns(3),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('code')
                    ->label('Mã CV')
                    ->weight('bold')
                    ->searchable()
                    ->sortable(),

                Tables\Columns\TextColumn::make('title')
                    ->label('Tên công việc')
                    ->searchable()
                    ->limit(25),

                Tables\Columns\TextColumn::make('location')
                    ->label('Địa điểm')
                    ->searchable()
                    ->limit(20)
                    ->toggleable(),

                Tables\Columns\TextColumn::make('status')
                    ->label('Trạng thái')
                    ->badge()
                    ->formatStateUsing(fn (string $state): string => Task::getStatusOptions()[$state] ?? $state)
                    ->color(fn (string $state): string => Task::getStatusColor($state))
                    ->sortable(),

                Tables\Columns\TextColumn::make('team.name')
                    ->label('Đội nhóm')
                    ->default('—'),

                Tables\Columns\TextColumn::make('manager.name')
                    ->label('Quản lý')
                    ->default('Chưa giao'),

                Tables\Columns\TextColumn::make('worker.name')
                    ->label('Thợ')
                    ->default('Chưa giao'),

                Tables\Columns\TextColumn::make('due_date')
                    ->label('Hạn xử lý')
                    ->dateTime('d/m/Y H:i')
                    ->color(fn ($record) => $record->due_date && $record->due_date->isPast() && !in_array($record->status, ['completed', 'cancelled']) ? 'danger' : 'gray')
                    ->sortable(),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('status')
                    ->label('Trạng thái')
                    ->options(Task::getStatusOptions()),

                Tables\Filters\SelectFilter::make('manager_id')
                    ->label('Quản lý')
                    ->options(User::where('role', 'manager')->pluck('name', 'id')),

                Tables\Filters\SelectFilter::make('worker_id')
                    ->label('Thợ thi công')
                    ->options(User::where('role', 'worker')->pluck('name', 'id')),

                Tables\Filters\SelectFilter::make('team_id')
                    ->label('Đội nhóm')
                    ->options(Team::pluck('name', 'id')),
            ])
            ->actions([
                Tables\Actions\EditAction::make(),

                // Action Phân bổ Quản lý dành cho Sếp
                Tables\Actions\Action::make('assignManager')
                    ->label('Phân bổ Quản lý')
                    ->icon('heroicon-o-user-plus')
                    ->color('info')
                    ->visible(fn (): bool => auth()->user()?->isDirector() ?? false)
                    ->form([
                        Forms\Components\Select::make('manager_id')
                            ->label('Chọn Quản lý/Leader')
                            ->options(User::where('role', 'manager')->pluck('name', 'id'))
                            ->required(),
                        Forms\Components\Select::make('team_id')
                            ->label('Chọn Đội nhóm (Tùy chọn)')
                            ->options(Team::pluck('name', 'id')),
                    ])
                    ->action(function (Task $record, array $data) {
                        $oldStatus = $record->status;
                        $record->manager_id = $data['manager_id'];
                        if (!empty($data['team_id'])) {
                            $record->team_id = $data['team_id'];
                        }
                        $record->status = 'assigned_manager';
                        $record->save();

                        TaskHistory::create([
                            'task_id' => $record->id,
                            'user_id' => auth()->id(),
                            'action' => 'Phân bổ Quản lý',
                            'old_status' => $oldStatus,
                            'new_status' => 'assigned_manager',
                            'notes' => "Sếp đã phân bổ cho Quản lý ID: {$data['manager_id']}",
                        ]);
                    }),

                // Action Giao việc dành cho Quản lý
                Tables\Actions\Action::make('assignWorker')
                    ->label('Giao cho Thợ')
                    ->icon('heroicon-o-paper-airplane')
                    ->color('primary')
                    ->visible(fn (Task $record): bool => (auth()->user()?->isDirector() || (auth()->user()?->isManager() && $record->manager_id === auth()->id())))
                    ->form([
                        Forms\Components\Select::make('worker_id')
                            ->label('Chọn Thợ thuộc đội')
                            ->options(function (Task $record) {
                                if ($record->team_id) {
                                    $team = Team::find($record->team_id);
                                    if ($team) {
                                        return $team->members()->pluck('name', 'users.id');
                                    }
                                }
                                return User::where('role', 'worker')->pluck('name', 'id');
                            })
                            ->required(),
                    ])
                    ->action(function (Task $record, array $data) {
                        $oldStatus = $record->status;
                        $record->worker_id = $data['worker_id'];
                        $record->status = 'assigned_worker';
                        $record->save();

                        TaskHistory::create([
                            'task_id' => $record->id,
                            'user_id' => auth()->id(),
                            'action' => 'Giao việc cho Thợ',
                            'old_status' => $oldStatus,
                            'new_status' => 'assigned_worker',
                            'notes' => "Giao việc thành công cho Thợ ID: {$data['worker_id']}",
                        ]);
                    }),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    // Bulk Action dành cho Sếp phân bổ hàng loạt
                    Tables\Actions\BulkAction::make('bulkAssignManager')
                        ->label('Phân bổ Quản lý cho các CV đã chọn')
                        ->icon('heroicon-o-user-plus')
                        ->color('info')
                        ->visible(fn (): bool => auth()->user()?->isDirector() ?? false)
                        ->form([
                            Forms\Components\Select::make('manager_id')
                                ->label('Chọn Quản lý nhận việc')
                                ->options(User::where('role', 'manager')->pluck('name', 'id'))
                                ->required(),
                        ])
                        ->action(function (\Illuminate\Database\Eloquent\Collection $records, array $data) {
                            foreach ($records as $record) {
                                $oldStatus = $record->status;
                                $record->manager_id = $data['manager_id'];
                                $record->status = 'assigned_manager';
                                $record->save();

                                TaskHistory::create([
                                    'task_id' => $record->id,
                                    'user_id' => auth()->id(),
                                    'action' => 'Phân bổ Quản lý (Hàng loạt)',
                                    'old_status' => $oldStatus,
                                    'new_status' => 'assigned_manager',
                                ]);
                            }
                        }),

                    // Bulk Action dành cho Quản lý giao Thợ hàng loạt
                    Tables\Actions\BulkAction::make('bulkAssignWorker')
                        ->label('Giao việc cho Thợ hàng loạt')
                        ->icon('heroicon-o-paper-airplane')
                        ->color('primary')
                        ->visible(fn (): bool => auth()->user()?->isDirector() || auth()->user()?->isManager())
                        ->form([
                            Forms\Components\Select::make('worker_id')
                                ->label('Chọn Thợ nhận việc')
                                ->options(User::where('role', 'worker')->pluck('name', 'id'))
                                ->required(),
                        ])
                        ->action(function (\Illuminate\Database\Eloquent\Collection $records, array $data) {
                            foreach ($records as $record) {
                                $oldStatus = $record->status;
                                $record->worker_id = $data['worker_id'];
                                $record->status = 'assigned_worker';
                                $record->save();

                                TaskHistory::create([
                                    'task_id' => $record->id,
                                    'user_id' => auth()->id(),
                                    'action' => 'Giao Thợ (Hàng loạt)',
                                    'old_status' => $oldStatus,
                                    'new_status' => 'assigned_worker',
                                ]);
                            }
                        }),
                ]),
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListTasks::route('/'),
            'create' => Pages\CreateTask::route('/create'),
            'edit' => Pages\EditTask::route('/{record}/edit'),
        ];
    }
}

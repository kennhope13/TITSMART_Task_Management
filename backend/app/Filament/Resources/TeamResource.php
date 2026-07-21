<?php

namespace App\Filament\Resources;

use App\Domain\Teams\Team;
use App\Filament\Resources\TeamResource\Pages;
use App\Models\User;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class TeamResource extends Resource
{
    protected static ?string $model = Team::class;

    protected static ?string $navigationGroup = 'Nhân sự & đội nhóm';

    protected static ?string $navigationLabel = 'Quản lý đội nhóm';

    protected static ?string $modelLabel = 'Đội nhóm';

    protected static ?string $pluralModelLabel = 'Danh sách đội nhóm';

    protected static ?string $navigationIcon = 'heroicon-o-user-group';

    protected static ?int $navigationSort = 2;

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Thông tin đội nhóm')
                    ->schema([
                        Forms\Components\TextInput::make('name')
                            ->label('Tên đội nhóm')
                            ->required()
                            ->placeholder('Đội thi công 1'),

                        Forms\Components\TextInput::make('code')
                            ->label('Mã đội')
                            ->required()
                            ->unique(ignoreRecord: true)
                            ->placeholder('TEAM-01'),

                        Forms\Components\Select::make('leader_id')
                            ->label('Quản lý phụ trách đội (Leader)')
                            ->options(
                                User::where('role', 'manager')->pluck('name', 'id')
                            )
                            ->searchable()
                            ->nullable()
                            ->placeholder('Chọn quản lý phụ trách'),

                        Forms\Components\Textarea::make('description')
                            ->label('Mô tả ghi chú')
                            ->columnSpanFull(),
                    ])->columns(2),

                Forms\Components\Section::make('Thành viên đội (Thợ thi công)')
                    ->schema([
                        Forms\Components\Select::make('members')
                            ->label('Danh sách Thợ thuộc đội')
                            ->relationship('members', 'name', fn ($query) => $query->where('role', 'worker'))
                            ->multiple()
                            ->preload()
                            ->searchable(),
                    ]),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('code')
                    ->label('Mã đội')
                    ->weight('bold')
                    ->searchable()
                    ->sortable(),

                Tables\Columns\TextColumn::make('name')
                    ->label('Tên đội nhóm')
                    ->searchable()
                    ->sortable(),

                Tables\Columns\TextColumn::make('leader.name')
                    ->label('Quản lý phụ trách')
                    ->default('Chưa phân bổ')
                    ->searchable(),

                Tables\Columns\TextColumn::make('members_count')
                    ->label('Số lượng Thợ')
                    ->counts('members')
                    ->badge()
                    ->color('info'),

                Tables\Columns\TextColumn::make('tasks_count')
                    ->label('Số công việc đảm nhận')
                    ->counts('tasks')
                    ->badge()
                    ->color('primary'),

                Tables\Columns\TextColumn::make('created_at')
                    ->label('Ngày thành lập')
                    ->dateTime('d/m/Y'),
            ])
            ->actions([
                Tables\Actions\EditAction::make(),
                Tables\Actions\DeleteAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListTeams::route('/'),
            'create' => Pages\CreateTeam::route('/create'),
            'edit' => Pages\EditTeam::route('/{record}/edit'),
        ];
    }
}

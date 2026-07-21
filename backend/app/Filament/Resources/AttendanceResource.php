<?php

namespace App\Filament\Resources;

use App\Domain\Attendance\Attendance;
use App\Domain\Teams\Team;
use App\Filament\Resources\AttendanceResource\Pages;
use App\Models\User;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

class AttendanceResource extends Resource
{
    protected static ?string $model = Attendance::class;

    protected static ?string $navigationGroup = 'Điểm danh';

    protected static ?string $navigationLabel = 'Nhật ký điểm danh';

    protected static ?string $modelLabel = 'Điểm danh';

    protected static ?string $pluralModelLabel = 'Nhật ký điểm danh';

    protected static ?string $navigationIcon = 'heroicon-o-map-pin';

    protected static ?int $navigationSort = 1;

    public static function getEloquentQuery(): Builder
    {
        $query = parent::getEloquentQuery();
        $user = auth()->user();

        if ($user && $user->isManager()) {
            $query->where(function ($q) use ($user) {
                $q->whereIn('team_id', $user->ledTeams()->pluck('id'))
                  ->orWhereHas('user', fn ($sub) => $sub->where('manager_id', $user->id));
            });
        }

        return $query;
    }

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Chi tiết thông tin điểm danh')
                    ->schema([
                        Forms\Components\Select::make('user_id')
                            ->label('Thợ thi công')
                            ->relationship('user', 'name')
                            ->required(),

                        Forms\Components\Select::make('team_id')
                            ->label('Đội nhóm')
                            ->relationship('team', 'name'),

                        Forms\Components\DateTimePicker::make('check_in_at')
                            ->label('Thời gian Check-in')
                            ->required(),

                        Forms\Components\TextInput::make('address')
                            ->label('Địa chỉ ghi nhận từ GPS')
                            ->columnSpanFull(),

                        Forms\Components\TextInput::make('latitude')
                            ->label('Vĩ độ (Latitude)')
                            ->numeric(),

                        Forms\Components\TextInput::make('longitude')
                            ->label('Kinh độ (Longitude)')
                            ->numeric(),

                        Forms\Components\Toggle::make('is_valid')
                            ->label('Hợp lệ')
                            ->default(true),

                        Forms\Components\Toggle::make('is_fake_gps')
                            ->label('Cảnh báo Fake GPS')
                            ->default(false),

                        Forms\Components\FileUpload::make('selfie_photo_path')
                            ->label('Ảnh Selfie điểm danh')
                            ->image()
                            ->disk('public')
                            ->directory('selfies')
                            ->columnSpanFull(),
                    ])->columns(2),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\ImageColumn::make('selfie_photo_path')
                    ->label('Ảnh Selfie')
                    ->circular()
                    ->defaultImageUrl('https://ui-avatars.com/api/?name=Selfie&background=0D8ABC&color=fff'),

                Tables\Columns\TextColumn::make('user.name')
                    ->label('Thợ thi công')
                    ->weight('bold')
                    ->searchable()
                    ->sortable(),

                Tables\Columns\TextColumn::make('user.employee_code')
                    ->label('Mã NV')
                    ->searchable(),

                Tables\Columns\TextColumn::make('team.name')
                    ->label('Đội nhóm')
                    ->default('—'),

                Tables\Columns\TextColumn::make('check_in_at')
                    ->label('Thời gian điểm danh')
                    ->dateTime('d/m/Y H:i:s')
                    ->sortable(),

                Tables\Columns\TextColumn::make('address')
                    ->label('Địa điểm GPS')
                    ->limit(25)
                    ->searchable(),

                Tables\Columns\TextColumn::make('is_fake_gps')
                    ->label('Cảnh báo Fake GPS')
                    ->badge()
                    ->formatStateUsing(fn (bool $state): string => $state ? '🚨 FAKE GPS' : '✅ Bình thường')
                    ->color(fn (bool $state): string => $state ? 'danger' : 'success'),

                Tables\Columns\TextColumn::make('is_valid')
                    ->label('Trạng thái')
                    ->badge()
                    ->formatStateUsing(fn (bool $state): string => $state ? 'Hợp lệ' : 'Không hợp lệ')
                    ->color(fn (bool $state): string => $state ? 'success' : 'warning'),

                Tables\Columns\TextColumn::make('google_map_link')
                    ->label('Bản đồ')
                    ->state(fn (Attendance $record): string => "📍 Mở Google Maps")
                    ->url(fn (Attendance $record): string => "https://www.google.com/maps/search/?api=1&query={$record->latitude},{$record->longitude}", shouldOpenInNewTab: true)
                    ->color('primary'),
            ])
            ->filters([
                Tables\Filters\Filter::make('check_in_at')
                    ->form([
                        Forms\Components\DatePicker::make('date')->label('Điểm danh theo ngày'),
                    ])
                    ->query(function (Builder $query, array $data): Builder {
                        return $query->when(
                            $data['date'],
                            fn (Builder $query, $date): Builder => $query->whereDate('check_in_at', $date),
                        );
                    }),

                Tables\Filters\SelectFilter::make('team_id')
                    ->label('Bộ lọc theo Đội nhóm')
                    ->options(Team::pluck('name', 'id')),

                Tables\Filters\SelectFilter::make('user_id')
                    ->label('Bộ lọc theo Thợ')
                    ->options(User::where('role', 'worker')->pluck('name', 'id')),

                Tables\Filters\TernaryFilter::make('is_valid')
                    ->label('Bộ lọc Trạng thái Hợp lệ')
                    ->boolean(),

                Tables\Filters\TernaryFilter::make('is_fake_gps')
                    ->label('Bộ lọc Cảnh báo Fake GPS')
                    ->boolean(),
            ])
            ->actions([
                Tables\Actions\ViewAction::make(),
                Tables\Actions\EditAction::make(),
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
            'index' => Pages\ListAttendances::route('/'),
            'create' => Pages\CreateAttendance::route('/create'),
            'edit' => Pages\EditAttendance::route('/{record}/edit'),
        ];
    }
}

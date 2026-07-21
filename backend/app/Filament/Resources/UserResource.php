<?php

namespace App\Filament\Resources;

use App\Filament\Resources\UserResource\Pages;
use App\Models\User;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Support\Facades\Hash;

class UserResource extends Resource
{
    protected static ?string $model = User::class;

    protected static ?string $navigationGroup = 'Nhân sự & đội nhóm';

    protected static ?string $navigationLabel = 'Quản lý người dùng';

    protected static ?string $modelLabel = 'Người dùng';

    protected static ?string $pluralModelLabel = 'Danh sách người dùng';

    protected static ?string $navigationIcon = 'heroicon-o-users';

    protected static ?int $navigationSort = 1;

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Thông tin cá nhân & tài khoản')
                    ->schema([
                        Forms\Components\TextInput::make('employee_code')
                            ->label('Mã nhân viên')
                            ->required()
                            ->unique(ignoreRecord: true)
                            ->placeholder('NV-001'),

                        Forms\Components\TextInput::make('name')
                            ->label('Họ và tên')
                            ->required()
                            ->placeholder('Nguyễn Văn A'),

                        Forms\Components\TextInput::make('email')
                            ->label('Email')
                            ->email()
                            ->required()
                            ->unique(ignoreRecord: true),

                        Forms\Components\TextInput::make('phone')
                            ->label('Số điện thoại')
                            ->tel()
                            ->required(),

                        Forms\Components\TextInput::make('password')
                            ->label('Mật khẩu')
                            ->password()
                            ->dehydrateStateUsing(fn ($state) => Hash::make($state))
                            ->dehydrated(fn ($state) => filled($state))
                            ->required(fn (string $context): bool => $context === 'create'),

                        Forms\Components\Select::make('role')
                            ->label('Vai trò')
                            ->options([
                                'director' => 'Sếp / Tổng quản lý',
                                'manager' => 'Quản lý / Leader',
                                'worker' => 'Thợ thi công',
                            ])
                            ->required()
                            ->reactive(),

                        Forms\Components\Select::make('status')
                            ->label('Trạng thái tài khoản')
                            ->options([
                                'active' => 'Hoạt động',
                                'locked' => 'Đã khóa',
                            ])
                            ->default('active')
                            ->required(),

                        Forms\Components\Select::make('manager_id')
                            ->label('Quản lý trực tiếp')
                            ->options(
                                User::where('role', 'manager')->pluck('name', 'id')
                            )
                            ->nullable()
                            ->searchable()
                            ->placeholder('Chọn quản lý trực tiếp'),
                    ])->columns(2),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('employee_code')
                    ->label('Mã NV')
                    ->weight('bold')
                    ->searchable()
                    ->sortable(),

                Tables\Columns\TextColumn::make('name')
                    ->label('Họ và tên')
                    ->searchable()
                    ->sortable(),

                Tables\Columns\TextColumn::make('phone')
                    ->label('Số điện thoại')
                    ->searchable(),

                Tables\Columns\TextColumn::make('email')
                    ->label('Email')
                    ->searchable(),

                Tables\Columns\TextColumn::make('role')
                    ->label('Vai trò')
                    ->badge()
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        'director' => 'Sếp / Tổng QL',
                        'manager' => 'Quản lý / Leader',
                        'worker' => 'Thợ',
                        default => $state,
                    })
                    ->color(fn (string $state): string => match ($state) {
                        'director' => 'danger',
                        'manager' => 'primary',
                        'worker' => 'gray',
                        default => 'secondary',
                    }),

                Tables\Columns\TextColumn::make('status')
                    ->label('Trạng thái')
                    ->badge()
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        'active' => 'Hoạt động',
                        'locked' => 'Đã khóa',
                        default => $state,
                    })
                    ->color(fn (string $state): string => match ($state) {
                        'active' => 'success',
                        'locked' => 'danger',
                        default => 'secondary',
                    }),

                Tables\Columns\TextColumn::make('manager.name')
                    ->label('Quản lý trực tiếp')
                    ->default('—'),

                Tables\Columns\TextColumn::make('created_at')
                    ->label('Ngày tạo')
                    ->dateTime('d/m/Y')
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('role')
                    ->label('Bộ lọc theo Vai trò')
                    ->options([
                        'director' => 'Sếp / Tổng quản lý',
                        'manager' => 'Quản lý / Leader',
                        'worker' => 'Thợ',
                    ]),

                Tables\Filters\SelectFilter::make('status')
                    ->label('Bộ lọc theo Trạng thái')
                    ->options([
                        'active' => 'Hoạt động',
                        'locked' => 'Đã khóa',
                    ]),
            ])
            ->actions([
                Tables\Actions\EditAction::make(),

                Tables\Actions\Action::make('toggleLock')
                    ->label(fn (User $record): string => $record->status === 'active' ? 'Khóa tài khoản' : 'Mở khóa tài khoản')
                    ->icon(fn (User $record): string => $record->status === 'active' ? 'heroicon-o-lock-closed' : 'heroicon-o-lock-open')
                    ->color(fn (User $record): string => $record->status === 'active' ? 'danger' : 'success')
                    ->requiresConfirmation()
                    ->modalHeading(fn (User $record): string => $record->status === 'active' ? "Xác nhận khóa tài khoản [{$record->name}]?" : "Xác nhận mở khóa tài khoản [{$record->name}]?")
                    ->modalDescription('Thao tác này sẽ thay đổi quyền truy cập của người dùng.')
                    ->action(function (User $record) {
                        $record->status = $record->status === 'active' ? 'locked' : 'active';
                        $record->save();
                    }),
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
            'index' => Pages\ListUsers::route('/'),
            'create' => Pages\CreateUser::route('/create'),
            'edit' => Pages\EditUser::route('/{record}/edit'),
        ];
    }
}

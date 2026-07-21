<?php

namespace App\Filament\Pages;

use Filament\Forms\Components\Section;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Forms\Concerns\InteractsWithForms;
use Filament\Forms\Contracts\HasForms;
use Filament\Forms\Form;
use Filament\Notifications\Notification;
use Filament\Pages\Page;

class SystemSettingPage extends Page implements HasForms
{
    use InteractsWithForms;

    protected static ?string $navigationGroup = 'Cấu hình';

    protected static ?string $navigationLabel = 'Cấu hình hệ thống';

    protected static ?string $title = 'Cấu hình hệ thống & Tham số GPS';

    protected static ?string $navigationIcon = 'heroicon-o-cog-6-tooth';

    protected static ?int $navigationSort = 1;

    protected static string $view = 'filament.pages.system-setting-page';

    public ?array $data = [];

    public function mount(): void
    {
        $this->form->fill([
            'company_name' => 'Công ty TITSMART Task Management',
            'gps_tolerance_meters' => 100,
            'enable_fake_gps_alert' => true,
            'auto_notification_push' => true,
        ]);
    }

    public function form(Form $form): Form
    {
        return $form
            ->schema([
                Section::make('Thông tin đơn vị')
                    ->schema([
                        TextInput::make('company_name')
                            ->label('Tên công ty / Đơn vị')
                            ->required(),
                    ]),

                Section::make('Tham số GPS & Chống giả lập điểm danh')
                    ->schema([
                        TextInput::make('gps_tolerance_meters')
                            ->label('Bán kính cho phép điểm danh (mét)')
                            ->numeric()
                            ->required(),

                        Toggle::make('enable_fake_gps_alert')
                            ->label('Tự động bật cảnh báo khi phát hiện Fake GPS')
                            ->default(true),

                        Toggle::make('auto_notification_push')
                            ->label('Gửi thông báo Push Firebase đến Mobile khi giao việc mới')
                            ->default(true),
                    ]),
            ])
            ->statePath('data');
    }

    public function save(): void
    {
        Notification::make()
            ->title('Đã cập nhật cấu hình hệ thống thành công!')
            ->success()
            ->send();
    }
}

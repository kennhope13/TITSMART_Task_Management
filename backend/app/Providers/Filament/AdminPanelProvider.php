<?php

namespace App\Providers\Filament;

use Filament\Http\Middleware\Authenticate;
use Filament\Http\Middleware\DisableBladeIconComponents;
use Filament\Http\Middleware\DispatchServingFilamentEvent;
use Filament\Pages;
use Filament\Panel;
use Filament\PanelProvider;
use Filament\Support\Colors\Color;
use Filament\Support\Facades\FilamentView;
use Filament\Widgets;
use Illuminate\Cookie\Middleware\AddQueuedCookiesToResponse;
use Illuminate\Cookie\Middleware\EncryptCookies;
use Illuminate\Foundation\Http\Middleware\VerifyCsrfToken;
use Illuminate\Routing\Middleware\SubstituteBindings;
use Illuminate\Session\Middleware\AuthenticateSession;
use Illuminate\Session\Middleware\StartSession;
use Illuminate\Support\HtmlString;
use Illuminate\View\Middleware\ShareErrorsFromSession;

class AdminPanelProvider extends PanelProvider
{
    public function panel(Panel $panel): Panel
    {
        return $panel
            ->default()
            ->id('admin')
            ->path('admin')
            ->login()
            ->brandName('TaskMaster Admin')
            ->font('Inter')
            ->colors([
                'primary' => [
                    50 => '#f0f6ff',
                    100 => '#d8e2ff',
                    200 => '#adc6ff',
                    300 => '#709eff',
                    400 => '#3878ff',
                    500 => '#2170e4',
                    600 => '#0058be',
                    700 => '#004395',
                    800 => '#002f6c',
                    900 => '#001a42',
                ],
                'secondary' => [
                    50 => '#f4f6f8',
                    100 => '#d3e4fe',
                    200 => '#b7c8e1',
                    300 => '#8fa4c3',
                    400 => '#6b81a1',
                    500 => '#505f76',
                    600 => '#38485d',
                    700 => '#243245',
                    800 => '#121d2d',
                    900 => '#0b1c30',
                ],
                'success' => Color::Emerald,
                'warning' => Color::Amber,
                'danger' => [
                    50 => '#fff1f0',
                    100 => '#ffdad6',
                    200 => '#ffb4ab',
                    300 => '#ff897d',
                    400 => '#f85649',
                    500 => '#ba1a1a',
                    600 => '#93000a',
                    700 => '#680003',
                    800 => '#410002',
                    900 => '#2c0001',
                ],
                'info' => Color::Sky,
                'purple' => Color::Purple,
                'orange' => Color::Orange,
            ])
            ->navigationGroups([
                'Nhân sự & đội nhóm',
                'Công việc',
                'Điểm danh',
                'Báo cáo & nghiệm thu',
                'Thông báo',
                'Báo cáo quản trị',
                'Cấu hình',
            ])
            ->discoverResources(in: app_path('Filament/Resources'), for: 'App\\Filament\\Resources')
            ->discoverPages(in: app_path('Filament/Pages'), for: 'App\\Filament\\Pages')
            ->pages([
                \App\Filament\Pages\Dashboard::class,
            ])
            ->discoverWidgets(in: app_path('Filament/Widgets'), for: 'App\\Filament\\Widgets')
            ->widgets([
            ])
            ->renderHook(
                'panels::head.done',
                fn (): string => new HtmlString('
                    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&family=Courier+Prime&display=swap" rel="stylesheet" />
                    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet" />
                    <style>
                        :root {
                            --bg-background: #f9f9ff;
                            --bg-surface: #f9f9ff;
                            --border-outline-variant: #c2c6d6;
                            --color-primary: #0058be;
                            --color-primary-container: #2170e4;
                            --color-on-surface: #191b23;
                            --color-on-surface-variant: #424754;
                        }
                        body {
                            font-family: "Inter", sans-serif !important;
                            background-color: var(--bg-background) !important;
                            color: var(--color-on-surface) !important;
                        }
                        .material-symbols-outlined {
                            font-variation-settings: "FILL" 0, "wght" 400, "GRAD" 0, "opsz" 24;
                            vertical-align: middle;
                        }
                        .fi-sidebar {
                            background-color: #ffffff !important;
                            border-right: 1px solid var(--border-outline-variant) !important;
                        }
                        .fi-topbar {
                            background-color: #ffffff !important;
                            border-bottom: 1px solid var(--border-outline-variant) !important;
                        }
                        .fi-sidebar-item-active .fi-sidebar-item-button {
                            background-color: #2170e4 !important;
                            color: #ffffff !important;
                            border-radius: 0.5rem !important;
                        }
                        .fi-sidebar-header {
                            padding: 1.5rem 1rem !important;
                        }
                        .fi-sidebar-header .text-xl {
                            font-weight: 800 !important;
                            color: #0058be !important;
                        }
                        .fi-section, .fi-ta-content, .fi-card {
                            background-color: #ffffff !important;
                            border: 1px solid #c2c6d6 !important;
                            border-radius: 0.75rem !important;
                            box-shadow: 0px 1px 3px rgba(0,0,0,0.05) !important;
                        }
                        .fi-badge {
                            font-weight: 700 !important;
                            border-radius: 9999px !important;
                            padding: 0.25rem 0.625rem !important;
                        }
                        /* Custom scrollbars */
                        ::-webkit-scrollbar {
                            width: 6px;
                            height: 6px;
                        }
                        ::-webkit-scrollbar-track {
                            background: transparent;
                        }
                        ::-webkit-scrollbar-thumb {
                            background: #c2c6d6;
                            border-radius: 10px;
                        }
                        ::-webkit-scrollbar-thumb:hover {
                            background: #727785;
                        }
                    </style>
                ')
            )
            ->middleware([
                EncryptCookies::class,
                AddQueuedCookiesToResponse::class,
                StartSession::class,
                AuthenticateSession::class,
                ShareErrorsFromSession::class,
                VerifyCsrfToken::class,
                SubstituteBindings::class,
                DisableBladeIconComponents::class,
                DispatchServingFilamentEvent::class,
            ])
            ->authMiddleware([
                Authenticate::class,
            ]);
    }
}

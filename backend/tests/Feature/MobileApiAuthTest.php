<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class MobileApiAuthTest extends TestCase
{
    use RefreshDatabase;

    public function test_worker_can_login_and_receive_mobile_token(): void
    {
        User::create([
            'employee_code' => 'WRK-TEST',
            'name' => 'Thợ Test',
            'email' => 'worker.test@example.com',
            'password' => Hash::make('password'),
            'role' => 'worker',
            'status' => 'active',
        ]);

        $this->postJson('/api/v1/auth/login', [
            'email' => 'worker.test@example.com',
            'password' => 'password',
            'device_name' => 'flutter-test',
        ])
            ->assertOk()
            ->assertJsonPath('token_type', 'Bearer')
            ->assertJsonPath('user.role', 'worker')
            ->assertJsonStructure(['access_token']);
    }
}

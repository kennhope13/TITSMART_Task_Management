<?php

namespace Tests\Feature;

use Tests\TestCase;

class MobileApiHealthTest extends TestCase
{
    public function test_mobile_api_health_endpoint_is_available(): void
    {
        $this->getJson('/api/v1/health')
            ->assertOk()
            ->assertJson(['status' => 'ok']);
    }
}

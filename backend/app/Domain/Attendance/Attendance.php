<?php

namespace App\Domain\Attendance;

use App\Domain\Teams\Team;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Attendance extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'team_id',
        'check_in_at',
        'latitude',
        'longitude',
        'address',
        'selfie_photo_path',
        'is_valid',
        'is_fake_gps',
        'notes',
    ];

    protected $casts = [
        'check_in_at' => 'datetime',
        'is_valid' => 'boolean',
        'is_fake_gps' => 'boolean',
        'latitude' => 'float',
        'longitude' => 'float',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    public function team(): BelongsTo
    {
        return $this->belongsTo(Team::class, 'team_id');
    }
}

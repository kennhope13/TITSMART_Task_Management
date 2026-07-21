<?php

namespace App\Domain\Imports;

use App\Models\User;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class BulkImport extends Model
{
    use HasFactory;

    protected $fillable = [
        'filename',
        'total_rows',
        'valid_rows',
        'error_rows',
        'status',
        'error_file_path',
        'imported_by',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class, 'imported_by');
    }
}

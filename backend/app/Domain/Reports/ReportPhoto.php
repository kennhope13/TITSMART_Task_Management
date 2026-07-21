<?php

namespace App\Domain\Reports;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ReportPhoto extends Model
{
    use HasFactory;

    protected $fillable = [
        'completion_report_id',
        'photo_path',
        'caption',
    ];

    public function report(): BelongsTo
    {
        return $this->belongsTo(CompletionReport::class, 'completion_report_id');
    }
}

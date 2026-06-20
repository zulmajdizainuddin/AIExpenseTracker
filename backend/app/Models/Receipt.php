<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Receipt extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'expense_id',
        'file_path',
        'merchant_name',
        'amount',
        'receipt_date',
        'category_suggestion',
        'raw_ai_response',
        'processing_status',
    ];

    protected $hidden = [
        'raw_ai_response',
    ];

    protected function casts(): array
    {
        return [
            'amount'       => 'decimal:2',
            'receipt_date' => 'date',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function expense(): BelongsTo
    {
        return $this->belongsTo(Expense::class);
    }
}

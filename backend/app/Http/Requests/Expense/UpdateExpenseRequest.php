<?php

namespace App\Http\Requests\Expense;

use Illuminate\Foundation\Http\FormRequest;

class UpdateExpenseRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'category_id'      => ['sometimes', 'integer', 'exists:categories,id'],
            'title'            => ['sometimes', 'string', 'max:200'],
            'amount'           => ['sometimes', 'numeric', 'min:0.01', 'max:9999999.99'],
            'note'             => ['nullable', 'string', 'max:500'],
            'transaction_date' => ['sometimes', 'date', 'before_or_equal:today'],
        ];
    }
}

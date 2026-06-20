<?php

namespace App\Http\Requests\Expense;

use Illuminate\Foundation\Http\FormRequest;

class StoreExpenseRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'category_id'      => ['required', 'integer', 'exists:categories,id'],
            'title'            => ['required', 'string', 'max:200'],
            'amount'           => ['required', 'numeric', 'min:0.01', 'max:9999999.99'],
            'note'             => ['nullable', 'string', 'max:500'],
            'transaction_date' => ['required', 'date', 'before_or_equal:today'],
        ];
    }
}

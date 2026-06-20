<?php

namespace App\Http\Requests\Budget;

use Illuminate\Foundation\Http\FormRequest;

class StoreBudgetRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'category_id' => ['required', 'integer', 'exists:categories,id'],
            'amount'      => ['required', 'numeric', 'min:1', 'max:9999999.99'],
            'month'       => ['required', 'integer', 'min:1', 'max:12'],
            'year'        => ['required', 'integer', 'min:2020', 'max:2099'],
        ];
    }
}

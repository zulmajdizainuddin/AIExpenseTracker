<?php

namespace App\Http\Requests\Receipt;

use Illuminate\Foundation\Http\FormRequest;

class ScanReceiptRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'image' => [
                'required',
                'file',
                'mimes:jpeg,jpg,png,webp',
                'max:5120', // 5MB
            ],
        ];
    }

    public function messages(): array
    {
        return [
            'image.max'   => 'Receipt image must not exceed 5MB.',
            'image.mimes' => 'Receipt must be a JPEG, PNG, or WebP image.',
        ];
    }
}

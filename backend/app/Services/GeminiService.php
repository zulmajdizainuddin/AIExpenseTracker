<?php

namespace App\Services;

use Illuminate\Http\Client\ConnectionException;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use RuntimeException;

class GeminiService
{
    private const API_URL = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';

    private const RECEIPT_PROMPT = <<<'PROMPT'
        You are a receipt parser. Extract the following fields from the receipt image:
        - merchant_name (string)
        - amount (float, total amount only)
        - date (string in YYYY-MM-DD format, or null)
        - category (one of: Food & Dining, Transportation, Shopping, Healthcare, Entertainment, Utilities, Other)

        Respond ONLY with a valid JSON object. No explanation, no markdown.
        Example: {"merchant_name":"ABC Store","amount":25.50,"date":"2024-01-15","category":"Shopping"}
        PROMPT;

    public function __construct(
        private readonly string $apiKey = ''
    ) {
        $this->apiKey = config('services.gemini.key');
    }

    public function extractReceiptData(string $base64Image, string $mimeType): array
    {
        $response = $this->callApi([
            'contents' => [[
                'parts' => [
                    ['text' => self::RECEIPT_PROMPT],
                    [
                        'inline_data' => [
                            'mime_type' => $mimeType,
                            'data'      => $base64Image,
                        ],
                    ],
                ],
            ]],
            'generationConfig' => [
                'temperature'     => 0.1,
                'maxOutputTokens' => 256,
            ],
        ]);

        return $this->parseResponse($response);
    }

    private function callApi(array $payload): array
    {
        try {
            $response = Http::withQueryParameters(['key' => $this->apiKey])
                ->timeout(30)
                ->post(self::API_URL, $payload);

            if ($response->failed()) {
                Log::error('Gemini API error', ['status' => $response->status(), 'body' => $response->body()]);
                throw new RuntimeException('AI service unavailable.');
            }

            return $response->json();
        } catch (ConnectionException $e) {
            Log::error('Gemini connection failed', ['message' => $e->getMessage()]);
            throw new RuntimeException('AI service connection failed.');
        }
    }

    private function parseResponse(array $response): array
    {
        $text = $response['candidates'][0]['content']['parts'][0]['text'] ?? null;

        if (! $text) {
            throw new RuntimeException('Empty response from AI service.');
        }

        $cleaned = preg_replace('/```json|```/', '', $text);
        $data    = json_decode(trim($cleaned), true);

        if (json_last_error() !== JSON_ERROR_NONE) {
            Log::warning('Gemini returned non-JSON', ['raw' => $text]);
            throw new RuntimeException('Could not parse AI response.');
        }

        return [
            'merchant_name'       => $data['merchant_name'] ?? null,
            'amount'              => isset($data['amount']) ? (float) $data['amount'] : null,
            'date'                => $data['date'] ?? null,
            'category_suggestion' => $data['category'] ?? 'Other',
        ];
    }
}

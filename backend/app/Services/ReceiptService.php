<?php

namespace App\Services;

use App\Models\Receipt;
use App\Models\User;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use RuntimeException;

class ReceiptService
{
    private const ALLOWED_MIME_TYPES = ['image/jpeg', 'image/png', 'image/webp'];
    private const MAX_FILE_SIZE_BYTES = 5 * 1024 * 1024; // 5MB

    public function __construct(
        private readonly GeminiService $geminiService
    ) {}

    public function scan(User $user, UploadedFile $file): array
    {
        $this->validateFile($file);

        $path     = $this->storeSecurely($user, $file);
        $mimeType = $file->getMimeType();

        try {
            $base64   = base64_encode(file_get_contents($file->getRealPath()));
            $aiResult = $this->geminiService->extractReceiptData($base64, $mimeType);
        } catch (\Throwable $e) {
            Storage::disk('private')->delete($path);
            throw $e;
        }

        $receipt = Receipt::create([
            'user_id'             => $user->id,
            'file_path'           => $path,
            'merchant_name'       => $aiResult['merchant_name'],
            'amount'              => $aiResult['amount'],
            'receipt_date'        => $aiResult['date'],
            'category_suggestion' => $aiResult['category_suggestion'],
            'processing_status'   => 'completed',
        ]);

        return [
            'receipt'  => $receipt,
            'ai_data'  => $aiResult,
        ];
    }

    public function attachToExpense(Receipt $receipt, int $expenseId): Receipt
    {
        $receipt->update(['expense_id' => $expenseId]);
        return $receipt->fresh();
    }

    private function validateFile(UploadedFile $file): void
    {
        if (! in_array($file->getMimeType(), self::ALLOWED_MIME_TYPES, true)) {
            throw new RuntimeException('Invalid file type. Only JPEG, PNG, and WebP are allowed.');
        }

        if ($file->getSize() > self::MAX_FILE_SIZE_BYTES) {
            throw new RuntimeException('File exceeds maximum allowed size of 5MB.');
        }
    }

    private function storeSecurely(User $user, UploadedFile $file): string
    {
        $filename = sprintf(
            'receipts/user_%d/%s_%s.%s',
            $user->id,
            now()->format('Ymd_His'),
            bin2hex(random_bytes(8)),
            $file->extension()
        );

        Storage::disk('private')->put($filename, file_get_contents($file->getRealPath()));

        return $filename;
    }
}

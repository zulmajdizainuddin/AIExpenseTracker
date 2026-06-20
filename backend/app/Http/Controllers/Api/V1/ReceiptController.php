<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Receipt\ScanReceiptRequest;
use App\Services\ReceiptService;
use App\Traits\ApiResponse;
use Illuminate\Http\JsonResponse;

class ReceiptController extends Controller
{
    use ApiResponse;

    public function __construct(private readonly ReceiptService $receiptService) {}

    public function scan(ScanReceiptRequest $request): JsonResponse
    {
        $result = $this->receiptService->scan($request->user(), $request->file('image'));

        return $this->created([
            'receipt' => $result['receipt'],
            'ai_data' => $result['ai_data'],
        ], 'Receipt scanned successfully.');
    }
}

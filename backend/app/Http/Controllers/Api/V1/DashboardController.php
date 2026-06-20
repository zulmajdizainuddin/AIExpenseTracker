<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Services\DashboardService;
use App\Traits\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class DashboardController extends Controller
{
    use ApiResponse;

    public function __construct(private readonly DashboardService $dashboardService) {}

    public function index(Request $request): JsonResponse
    {
        $summary = $this->dashboardService->getSummary($request->user());

        return $this->success($summary);
    }
}

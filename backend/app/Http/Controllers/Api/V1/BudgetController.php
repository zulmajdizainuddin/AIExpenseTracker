<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Budget\StoreBudgetRequest;
use App\Services\BudgetService;
use App\Traits\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class BudgetController extends Controller
{
    use ApiResponse;

    public function __construct(private readonly BudgetService $budgetService) {}

    public function index(Request $request): JsonResponse
    {
        $year  = (int) $request->query('year', now()->year);
        $month = (int) $request->query('month', now()->month);

        $summary = $this->budgetService->getSummary($request->user(), $year, $month);

        return $this->success($summary);
    }

    public function store(StoreBudgetRequest $request): JsonResponse
    {
        $budget = $this->budgetService->createOrUpdate($request->user(), $request->validated());

        return $this->created($budget->load('category'), 'Budget saved.');
    }

    public function destroy(Request $request, int $id): JsonResponse
    {
        $this->budgetService->delete($request->user(), $id);

        return $this->success(null, 'Budget deleted.');
    }
}

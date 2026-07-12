<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Expense\StoreExpenseRequest;
use App\Http\Requests\Expense\UpdateExpenseRequest;
use App\Models\Expense;
use App\Services\ExpenseService;
use App\Traits\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ExpenseController extends Controller
{
    use ApiResponse;

    public function __construct(private readonly ExpenseService $expenseService) {}

    public function index(Request $request): JsonResponse
    {
        $expenses = $this->expenseService->listForUser($request->user(), $request->only([
            'category_id', 'from', 'to', 'search', 'per_page',
        ]));

        return $this->success($expenses);
    }

    public function store(StoreExpenseRequest $request): JsonResponse
    {
        $expense = $this->expenseService->create($request->user(), $request->validated());

        return $this->created($expense->load('category'), 'Expense created.');
    }

    public function show(Request $request, int $id): JsonResponse
    {
        $expense = Expense::findOrFail($id);
        $this->authorize('view', $expense);

        return $this->success($this->expenseService->show($expense));
    }

    public function update(UpdateExpenseRequest $request, int $id): JsonResponse
    {
        $expense = Expense::findOrFail($id);
        $this->authorize('update', $expense);

        $expense = $this->expenseService->update($expense, $request->validated());

        return $this->success($expense, 'Expense updated.');
    }

    public function destroy(Request $request, int $id): JsonResponse
    {
        $expense = Expense::findOrFail($id);
        $this->authorize('delete', $expense);

        $this->expenseService->delete($expense);

        return $this->success(null, 'Expense deleted.');
    }
}

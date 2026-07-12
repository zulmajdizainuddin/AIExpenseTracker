<?php

namespace App\Services;

use App\Models\Expense;
use App\Models\User;
use App\Repositories\Contracts\ExpenseRepositoryInterface;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Support\Facades\Cache;

class ExpenseService
{
    public function __construct(
        private readonly ExpenseRepositoryInterface $expenseRepository
    ) {}

    public function listForUser(User $user, array $filters = []): LengthAwarePaginator
    {
        return $this->expenseRepository->paginateForUser($user->id, $filters);
    }

    public function create(User $user, array $data): Expense
    {
        $expense = $this->expenseRepository->create([
            'user_id'          => $user->id,
            'category_id'      => $data['category_id'],
            'title'            => $data['title'],
            'amount'           => $data['amount'],
            'note'             => $data['note'] ?? null,
            'transaction_date' => $data['transaction_date'],
        ]);

        Cache::forget(DashboardService::cacheKey($user->id));

        return $expense;
    }

    public function update(Expense $expense, array $data): Expense
    {
        $this->expenseRepository->update($expense, array_filter([
            'category_id'      => $data['category_id'] ?? null,
            'title'            => $data['title'] ?? null,
            'amount'           => $data['amount'] ?? null,
            'note'             => $data['note'] ?? null,
            'transaction_date' => $data['transaction_date'] ?? null,
        ], fn ($v) => $v !== null));

        Cache::forget(DashboardService::cacheKey($expense->user_id));

        return $expense->fresh(['category']);
    }

    public function delete(Expense $expense): void
    {
        $this->expenseRepository->delete($expense);

        Cache::forget(DashboardService::cacheKey($expense->user_id));
    }

    public function show(Expense $expense): Expense
    {
        return $expense->load('category', 'receipt');
    }
}

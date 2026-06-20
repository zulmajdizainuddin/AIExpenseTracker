<?php

namespace App\Repositories;

use App\Models\Expense;
use App\Repositories\Contracts\ExpenseRepositoryInterface;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

class ExpenseRepository implements ExpenseRepositoryInterface
{
    public function paginateForUser(int $userId, array $filters = []): LengthAwarePaginator
    {
        $query = Expense::with('category')
            ->forUser($userId)
            ->orderByDesc('transaction_date')
            ->orderByDesc('created_at');

        if (! empty($filters['category_id'])) {
            $query->where('category_id', $filters['category_id']);
        }

        if (! empty($filters['from']) && ! empty($filters['to'])) {
            $query->forDateRange($filters['from'], $filters['to']);
        }

        if (! empty($filters['search'])) {
            $query->where('title', 'like', '%' . $filters['search'] . '%');
        }

        return $query->paginate($filters['per_page'] ?? 15);
    }

    public function findById(int $id): ?Expense
    {
        return Expense::with('category', 'receipt')->find($id);
    }

    public function create(array $data): Expense
    {
        return Expense::create($data);
    }

    public function update(Expense $expense, array $data): Expense
    {
        $expense->update($data);
        return $expense;
    }

    public function delete(Expense $expense): void
    {
        $expense->delete();
    }
}

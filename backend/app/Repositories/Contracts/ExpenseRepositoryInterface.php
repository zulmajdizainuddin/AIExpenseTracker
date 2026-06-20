<?php

namespace App\Repositories\Contracts;

use App\Models\Expense;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

interface ExpenseRepositoryInterface
{
    public function paginateForUser(int $userId, array $filters = []): LengthAwarePaginator;

    public function findById(int $id): ?Expense;

    public function create(array $data): Expense;

    public function update(Expense $expense, array $data): Expense;

    public function delete(Expense $expense): void;
}

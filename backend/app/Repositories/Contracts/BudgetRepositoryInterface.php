<?php

namespace App\Repositories\Contracts;

use App\Models\Budget;
use Illuminate\Database\Eloquent\Collection;

interface BudgetRepositoryInterface
{
    public function getForUserAndPeriod(int $userId, int $year, int $month): Collection;

    public function findById(int $id): ?Budget;

    public function upsert(int $userId, array $data): Budget;

    public function delete(Budget $budget): void;
}

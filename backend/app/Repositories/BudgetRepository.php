<?php

namespace App\Repositories;

use App\Models\Budget;
use App\Repositories\Contracts\BudgetRepositoryInterface;
use Illuminate\Database\Eloquent\Collection;

class BudgetRepository implements BudgetRepositoryInterface
{
    public function getForUserAndPeriod(int $userId, int $year, int $month): Collection
    {
        return Budget::with('category')
            ->forUser($userId)
            ->forPeriod($year, $month)
            ->orderBy('category_id')
            ->get();
    }

    public function findById(int $id): ?Budget
    {
        return Budget::with('category')->find($id);
    }

    public function upsert(int $userId, array $data): Budget
    {
        return Budget::updateOrCreate(
            [
                'user_id'     => $userId,
                'category_id' => $data['category_id'],
                'month'       => $data['month'],
                'year'        => $data['year'],
            ],
            ['amount' => $data['amount']]
        );
    }

    public function delete(Budget $budget): void
    {
        $budget->delete();
    }
}

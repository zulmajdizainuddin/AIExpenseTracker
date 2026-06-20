<?php

namespace App\Services;

use App\Models\Budget;
use App\Models\User;
use App\Repositories\Contracts\BudgetRepositoryInterface;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Database\Eloquent\ModelNotFoundException;

class BudgetService
{
    public function __construct(
        private readonly BudgetRepositoryInterface $budgetRepository
    ) {}

    public function listForPeriod(User $user, int $year, int $month): Collection
    {
        return $this->budgetRepository->getForUserAndPeriod($user->id, $year, $month);
    }

    public function createOrUpdate(User $user, array $data): Budget
    {
        return $this->budgetRepository->upsert($user->id, [
            'category_id' => $data['category_id'],
            'amount'      => $data['amount'],
            'month'       => $data['month'],
            'year'        => $data['year'],
        ]);
    }

    public function delete(User $user, int $budgetId): void
    {
        $budget = $this->findOwnedByUser($user, $budgetId);
        $this->budgetRepository->delete($budget);
    }

    public function getSummary(User $user, int $year, int $month): array
    {
        $budgets = $this->budgetRepository->getForUserAndPeriod($user->id, $year, $month);

        return $budgets->map(function (Budget $budget) use ($user, $year, $month) {
            $spent = $user->expenses()
                ->where('category_id', $budget->category_id)
                ->forMonth($year, $month)
                ->sum('amount');

            return [
                'budget'    => $budget,
                'spent'     => round($spent, 2),
                'remaining' => round(max(0, $budget->amount - $spent), 2),
                'percent'   => $budget->amount > 0
                    ? round(($spent / $budget->amount) * 100, 1)
                    : 0,
            ];
        })->toArray();
    }

    private function findOwnedByUser(User $user, int $budgetId): Budget
    {
        $budget = $this->budgetRepository->findById($budgetId);

        if (! $budget || $budget->user_id !== $user->id) {
            throw new ModelNotFoundException('Budget not found.');
        }

        return $budget;
    }
}

<?php

namespace App\Policies;

use App\Models\Expense;
use App\Models\User;
use Illuminate\Auth\Access\Response;

class ExpensePolicy
{
    public function view(User $user, Expense $expense): Response
    {
        return $user->id === $expense->user_id
            ? Response::allow()
            : Response::denyAsNotFound('Expense not found.');
    }

    public function update(User $user, Expense $expense): Response
    {
        return $user->id === $expense->user_id
            ? Response::allow()
            : Response::denyAsNotFound('Expense not found.');
    }

    public function delete(User $user, Expense $expense): Response
    {
        return $user->id === $expense->user_id
            ? Response::allow()
            : Response::denyAsNotFound('Expense not found.');
    }
}

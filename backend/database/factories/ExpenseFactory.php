<?php

namespace Database\Factories;

use App\Models\Expense;
use App\Models\User;
use App\Models\Category;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Expense>
 */
class ExpenseFactory extends Factory
{
    protected $model = Expense::class;

    public function definition(): array
    {
        return [
            'user_id'          => User::factory(),
            'category_id'      => Category::factory(),
            'title'            => $this->faker->sentence(3),
            'amount'           => $this->faker->randomFloat(2, 1, 500),
            'note'             => null,
            'transaction_date' => $this->faker->dateTimeBetween('-1 year')->format('Y-m-d'),
        ];
    }
}

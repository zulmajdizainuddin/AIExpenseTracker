<?php

namespace Database\Factories;

use App\Models\Category;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Category>
 */
class CategoryFactory extends Factory
{
    protected $model = Category::class;

    public function definition(): array
    {
        return [
            'name'       => $this->faker->word(),
            'icon'       => 'shopping_bag',
            'color'      => '#'.str_pad(dechex($this->faker->numberBetween(0, 0xFFFFFF)), 6, '0', STR_PAD_LEFT),
            'is_default' => false,
        ];
    }
}

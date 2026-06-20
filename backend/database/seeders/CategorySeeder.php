<?php

namespace Database\Seeders;

use App\Models\Category;
use Illuminate\Database\Seeder;

class CategorySeeder extends Seeder
{
    public function run(): void
    {
        $categories = [
            ['name' => 'Food & Dining',    'icon' => 'restaurant',    'color' => '#f59e0b', 'is_default' => true],
            ['name' => 'Transportation',   'icon' => 'directions_car', 'color' => '#3b82f6', 'is_default' => true],
            ['name' => 'Shopping',         'icon' => 'shopping_bag',   'color' => '#8b5cf6', 'is_default' => true],
            ['name' => 'Healthcare',       'icon' => 'local_hospital',  'color' => '#ef4444', 'is_default' => true],
            ['name' => 'Entertainment',    'icon' => 'movie',           'color' => '#10b981', 'is_default' => true],
            ['name' => 'Utilities',        'icon' => 'bolt',            'color' => '#f97316', 'is_default' => true],
            ['name' => 'Education',        'icon' => 'school',          'color' => '#06b6d4', 'is_default' => true],
            ['name' => 'Travel',           'icon' => 'flight',          'color' => '#84cc16', 'is_default' => true],
            ['name' => 'Other',            'icon' => 'category',        'color' => '#6b7280', 'is_default' => true],
        ];

        foreach ($categories as $category) {
            Category::firstOrCreate(['name' => $category['name']], $category);
        }
    }
}

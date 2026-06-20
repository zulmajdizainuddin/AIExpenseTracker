<?php

namespace App\Providers;

use App\Repositories\BudgetRepository;
use App\Repositories\Contracts\BudgetRepositoryInterface;
use App\Repositories\Contracts\ExpenseRepositoryInterface;
use App\Repositories\ExpenseRepository;
use App\Services\GeminiService;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        $this->app->bind(ExpenseRepositoryInterface::class, ExpenseRepository::class);
        $this->app->bind(BudgetRepositoryInterface::class, BudgetRepository::class);

        $this->app->singleton(GeminiService::class, function () {
            return new GeminiService(config('services.gemini.key', ''));
        });
    }

    public function boot(): void
    {
        //
    }
}

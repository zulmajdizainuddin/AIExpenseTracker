<?php

use App\Http\Controllers\Api\V1\AuthController;
use App\Http\Controllers\Api\V1\BudgetController;
use App\Http\Controllers\Api\V1\CategoryController;
use App\Http\Controllers\Api\V1\DashboardController;
use App\Http\Controllers\Api\V1\ExpenseController;
use App\Http\Controllers\Api\V1\ReceiptController;
use Illuminate\Support\Facades\Route;

Route::prefix('v1')->group(function () {

    // Public routes
    Route::prefix('auth')->middleware('throttle:10,1')->group(function () {
        Route::post('register', [AuthController::class, 'register']);
        Route::post('login',    [AuthController::class, 'login']);
    });

    // Protected routes
    Route::middleware('auth:sanctum')->group(function () {

        Route::prefix('auth')->middleware('throttle:60,1')->group(function () {
            Route::post('logout',  [AuthController::class, 'logout']);
            Route::get('profile',  [AuthController::class, 'profile']);
        });

        Route::middleware('throttle:30,1')->group(function () {
            Route::get('dashboard',     [DashboardController::class, 'index']);
            Route::get('categories',    [CategoryController::class, 'index']);
            Route::get('expenses',      [ExpenseController::class, 'index']);
            Route::get('expenses/{id}', [ExpenseController::class, 'show']);
            Route::get('budgets',       [BudgetController::class, 'index']);
        });

        Route::middleware('throttle:10,1')->group(function () {
            Route::post('expenses',        [ExpenseController::class, 'store']);
            Route::put('expenses/{id}',    [ExpenseController::class, 'update']);
            Route::patch('expenses/{id}',  [ExpenseController::class, 'update']);
            Route::delete('expenses/{id}', [ExpenseController::class, 'destroy']);
            Route::post('budgets',         [BudgetController::class, 'store']);
            Route::delete('budgets/{id}',  [BudgetController::class, 'destroy']);
        });

        Route::post('receipts/scan',   [ReceiptController::class, 'scan'])
            ->middleware('throttle:5,1');
    });
});

<?php

namespace App\Services;

use App\Models\User;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;

class DashboardService
{
    public function getSummary(User $user): array
    {
        $now   = Carbon::now();
        $year  = $now->year;
        $month = $now->month;

        return [
            'current_month' => $this->getMonthSummary($user, $year, $month),
            'previous_month' => $this->getMonthSummary($user, $now->copy()->subMonth()->year, $now->copy()->subMonth()->month),
            'category_breakdown' => $this->getCategoryBreakdown($user, $year, $month),
            'weekly_trend'       => $this->getWeeklyTrend($user),
            'top_categories'     => $this->getTopCategories($user, $year, $month),
        ];
    }

    private function getMonthSummary(User $user, int $year, int $month): array
    {
        $expenses = $user->expenses()->forMonth($year, $month);

        return [
            'total'        => round($expenses->sum('amount'), 2),
            'count'        => $expenses->count(),
            'average'      => round($expenses->avg('amount') ?? 0, 2),
            'year'         => $year,
            'month'        => $month,
        ];
    }

    private function getCategoryBreakdown(User $user, int $year, int $month): array
    {
        return $user->expenses()
            ->forMonth($year, $month)
            ->select('category_id', DB::raw('SUM(amount) as total'), DB::raw('COUNT(*) as count'))
            ->with('category:id,name,color,icon')
            ->groupBy('category_id')
            ->orderByDesc('total')
            ->get()
            ->map(fn ($row) => [
                'category' => $row->category,
                'total'    => round($row->total, 2),
                'count'    => $row->count,
            ])
            ->toArray();
    }

    private function getWeeklyTrend(User $user): array
    {
        $startOfWeek = Carbon::now()->startOfWeek();
        $endOfWeek   = Carbon::now()->endOfWeek();

        return $user->expenses()
            ->forDateRange($startOfWeek->toDateString(), $endOfWeek->toDateString())
            ->select(DB::raw('DATE(transaction_date) as date'), DB::raw('SUM(amount) as total'))
            ->groupBy('date')
            ->orderBy('date')
            ->get()
            ->map(fn ($row) => [
                'date'  => $row->date,
                'total' => round($row->total, 2),
            ])
            ->toArray();
    }

    private function getTopCategories(User $user, int $year, int $month, int $limit = 5): array
    {
        return $user->expenses()
            ->forMonth($year, $month)
            ->select('category_id', DB::raw('SUM(amount) as total'))
            ->with('category:id,name,color,icon')
            ->groupBy('category_id')
            ->orderByDesc('total')
            ->limit($limit)
            ->get()
            ->map(fn ($row) => [
                'category' => $row->category,
                'total'    => round($row->total, 2),
            ])
            ->toArray();
    }
}

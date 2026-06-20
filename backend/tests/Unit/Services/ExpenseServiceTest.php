<?php

namespace Tests\Unit\Services;

use App\Models\Category;
use App\Models\Expense;
use App\Models\User;
use App\Repositories\Contracts\ExpenseRepositoryInterface;
use App\Services\ExpenseService;
use Illuminate\Database\Eloquent\ModelNotFoundException;
use Mockery;
use Tests\TestCase;

class ExpenseServiceTest extends TestCase
{
    private ExpenseService $service;
    private $repository;

    protected function setUp(): void
    {
        parent::setUp();

        $this->repository = Mockery::mock(ExpenseRepositoryInterface::class);
        $this->service    = new ExpenseService($this->repository);
    }

    public function test_create_expense_for_user(): void
    {
        $user     = User::factory()->make(['id' => 1]);
        $category = Category::factory()->make(['id' => 2]);

        $data = [
            'category_id'      => 2,
            'title'            => 'Lunch',
            'amount'           => 15.50,
            'transaction_date' => '2024-01-15',
        ];

        $expense = Expense::factory()->make([
            'user_id'     => 1,
            'category_id' => 2,
            'title'       => 'Lunch',
            'amount'      => 15.50,
        ]);

        $this->repository
            ->shouldReceive('create')
            ->once()
            ->with(array_merge(['user_id' => 1, 'note' => null], $data))
            ->andReturn($expense);

        $result = $this->service->create($user, $data);

        $this->assertInstanceOf(Expense::class, $result);
        $this->assertEquals('Lunch', $result->title);
    }

    public function test_delete_expense_throws_if_not_owned(): void
    {
        $user = User::factory()->make(['id' => 1]);

        $expense = Expense::factory()->make(['id' => 5, 'user_id' => 99]);

        $this->repository
            ->shouldReceive('findById')
            ->with(5)
            ->andReturn($expense);

        $this->expectException(ModelNotFoundException::class);

        $this->service->delete($user, 5);
    }

    public function test_delete_expense_succeeds_for_owner(): void
    {
        $user = User::factory()->make(['id' => 1]);

        $expense = Expense::factory()->make(['id' => 5, 'user_id' => 1]);

        $this->repository->shouldReceive('findById')->with(5)->andReturn($expense);
        $this->repository->shouldReceive('delete')->with($expense)->once();

        $this->service->delete($user, 5);

        $this->assertTrue(true); // no exception = pass
    }

    protected function tearDown(): void
    {
        Mockery::close();
        parent::tearDown();
    }
}

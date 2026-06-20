<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('receipts', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('expense_id')->nullable()->constrained()->nullOnDelete();
            $table->string('file_path', 500);
            $table->string('merchant_name', 200)->nullable();
            $table->decimal('amount', 12, 2)->nullable();
            $table->date('receipt_date')->nullable();
            $table->string('category_suggestion', 100)->nullable();
            $table->longText('raw_ai_response')->nullable();
            $table->enum('processing_status', ['pending', 'completed', 'failed'])->default('pending');
            $table->timestamps();

            $table->index('user_id');
            $table->index('expense_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('receipts');
    }
};

<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('categories', function (Blueprint $table) {
            $table->id();
            $table->string('name', 100);
            $table->string('icon', 50)->nullable();
            $table->string('color', 7)->default('#6366f1');
            $table->boolean('is_default')->default(false);
            $table->timestamps();

            $table->index('is_default');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('categories');
    }
};

<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('bulk_imports', function (Blueprint $table) {
            $table->id();
            $table->string('filename');
            $table->integer('total_rows')->default(0);
            $table->integer('valid_rows')->default(0);
            $table->integer('error_rows')->default(0);
            $table->enum('status', ['pending', 'completed', 'failed'])->default('pending');
            $table->string('error_file_path')->nullable();
            $table->foreignId('imported_by')->constrained('users')->cascadeOnDelete();
            $table->timestamps();
        });

        Schema::create('attendances', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('team_id')->nullable()->constrained('teams')->nullOnDelete();
            $table->dateTime('check_in_at');
            $table->decimal('latitude', 10, 7);
            $table->decimal('longitude', 10, 7);
            $table->string('address')->nullable();
            $table->string('selfie_photo_path');
            $table->boolean('is_valid')->default(true);
            $table->boolean('is_fake_gps')->default(false);
            $table->text('notes')->nullable();
            $table->timestamps();
        });

        Schema::create('completion_reports', function (Blueprint $table) {
            $table->id();
            $table->foreignId('task_id')->constrained('tasks')->cascadeOnDelete();
            $table->foreignId('worker_id')->constrained('users')->cascadeOnDelete();
            $table->text('notes')->nullable();
            $table->enum('status', ['pending', 'approved', 'rejected'])->default('pending');
            $table->text('rejection_reason')->nullable();
            $table->foreignId('reviewed_by')->nullable()->constrained('users')->nullOnDelete();
            $table->dateTime('reviewed_at')->nullable();
            $table->timestamps();
        });

        Schema::create('report_photos', function (Blueprint $table) {
            $table->id();
            $table->foreignId('completion_report_id')->constrained('completion_reports')->cascadeOnDelete();
            $table->string('photo_path');
            $table->string('caption')->nullable();
            $table->timestamps();
        });

        Schema::create('notifications', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->string('title');
            $table->text('content');
            $table->string('type')->default('system');
            $table->boolean('is_read')->default(false);
            $table->dateTime('read_at')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('notifications');
        Schema::dropIfExists('report_photos');
        Schema::dropIfExists('completion_reports');
        Schema::dropIfExists('attendances');
        Schema::dropIfExists('bulk_imports');
    }
};

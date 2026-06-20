<?php

namespace App\Services;

use App\Models\User;
use Illuminate\Auth\AuthenticationException;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;

class AuthService
{
    public function register(array $data): array
    {
        $user = User::create([
            'name'     => $data['name'],
            'email'    => $data['email'],
            'password' => Hash::make($data['password']),
            'currency' => $data['currency'] ?? 'MYR',
            'timezone' => $data['timezone'] ?? 'Asia/Kuala_Lumpur',
        ]);

        $token = $user->createToken('auth_token')->plainTextToken;

        return [
            'user'  => $user,
            'token' => $token,
        ];
    }

    public function login(array $credentials): array
    {
        if (! Auth::attempt(['email' => $credentials['email'], 'password' => $credentials['password']])) {
            throw new AuthenticationException('Invalid credentials.');
        }

        /** @var User $user */
        $user = Auth::user();
        $user->tokens()->delete();

        $token = $user->createToken('auth_token')->plainTextToken;

        return [
            'user'  => $user,
            'token' => $token,
        ];
    }

    public function logout(User $user): void
    {
        $user->currentAccessToken()->delete();
    }

    public function updateProfile(User $user, array $data): User
    {
        $user->update(array_filter([
            'name'     => $data['name'] ?? null,
            'currency' => $data['currency'] ?? null,
            'timezone' => $data['timezone'] ?? null,
        ]));

        return $user->fresh();
    }

    public function changePassword(User $user, string $currentPassword, string $newPassword): void
    {
        if (! Hash::check($currentPassword, $user->password)) {
            throw new \InvalidArgumentException('Current password is incorrect.');
        }

        $user->update(['password' => Hash::make($newPassword)]);
        $user->tokens()->delete();
    }
}

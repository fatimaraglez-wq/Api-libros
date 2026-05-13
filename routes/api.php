<?php

use App\Http\Controllers\Api\LibroController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::get('/libros', [LibroController::class, 'index' ]);
Route::post('/libros', [LibroController::class, 'store' ]);
Route::get('/libros/{id}', [LibroController::class, 'show' ]);
Route::put('/libros/{id}', [LibroController::class, 'update' ]);
Route::delete('/libros/{id}', [LibroController::class, 'destroy' ]);
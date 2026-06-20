# AI Expense Tracker + Receipt Scanner

A production-grade full-stack mobile application built with Flutter and Laravel 12, designed to demonstrate real-world software engineering practices including AI integration, secure API design, and scalable architecture.

---

# Overview

AI Expense Tracker helps users manage personal finances by:

* Tracking expenses
* Scanning receipts using AI
* Categorizing transactions automatically
* Providing spending analytics and insights

This project is built with production-level architecture, security, and scalability in mind.

---

# Tech Stack

## Frontend

* Flutter
* Riverpod
* Dio
* GoRouter
* fl_chart

## Backend

* Laravel 12
* Laravel Sanctum
* REST API
* Eloquent ORM
* Service Layer Architecture

## Database

* MySQL

## AI

* Google Gemini API

---

# Architecture

## Mobile App

Feature-first structure:

```text id="flutter2"
lib/
├── core
├── config
├── models
├── repositories
├── services
├── providers
├── features
│   ├── auth
│   ├── dashboard
│   ├── expense
│   ├── budget
│   ├── receipt
│   └── profile
└── main.dart
```

---

## Backend

```text id="laravel2"
app/
├── Http/
├── Models/
├── Services/
├── Repositories/
├── Policies/
└── Exceptions/
```

---

# Key Features

## Authentication

* Register
* Login
* Logout
* Profile management

---

## Expense Management

* Create / update / delete expenses
* Search and filter expenses
* Category-based tracking

---

## Budget System

* Monthly budget per category
* Real-time tracking

---

## AI Receipt Scanner

* Upload receipt image
* Extract data using Gemini AI
* Store structured expense data

---

## Dashboard

* Monthly analytics
* Category breakdown
* Visual charts

---

# Security Highlights

* Laravel Sanctum authentication
* Role-based access via Policies
* API rate limiting
* Secure file upload validation
* Environment variable protection
* Backend-only AI integration (secure API key handling)

---

# API Overview

Base URL:

```
/api/v1
```

Endpoints:

* /auth/register
* /auth/login
* /auth/logout
* /expenses
* /budgets
* /dashboard
* /receipts/scan

---

# Testing

* PHPUnit (backend)
* flutter_test (frontend)

---

# CI/CD

* GitHub Actions

  * Run backend tests
  * Run frontend tests
  * Lint checks

---

# Future Improvements

* Docker support
* Offline mode
* Push notifications
* PDF export
* AI spending prediction
* Multi-device sync

---

# Project Philosophy

This project follows real software engineering principles:

* Clean Architecture
* Secure-by-design approach
* Scalable backend structure
* Maintainable frontend architecture
* Production-ready coding standards

This is not a student CRUD project — it is designed to reflect junior software engineer capability.

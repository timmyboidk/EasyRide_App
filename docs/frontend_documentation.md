# EasyRide Frontend Documentation

## Overview
This document serves as the primary reference for the EasyRide iOS frontend application. It details the architecture, backend integration points, and authentication flows.

## 1. Authentication
The application supports the following authentication methods:
- **Phone OTP**: Standard login flow.
- **WeChat Login**: Integrated via WeChat SDK (placeholder logic currently).

### Debug Login
For internal testing, use the following credentials to bypass SMS/WeChat verification:
- **Phone**: `99999999999`
- **OTP**: `000000`

## 2. Backend Integration
The app connects to a Dockerized backend environment.

- **Base URL**: `http://localhost:8080` (Configurable in `EasyRide/Services/Configuration.swift`)
- **API Models**: JSON Request/Response models are defined in `EasyRide/Models/`.

### Key Endpoints
| Feature | Endpoint | Method | Description |
|---|---|---|---|
| Login (OTP) | `/api/user/auth/login/otp` | POST | Login with Phone/OTP |
| Login (WeChat)| `/api/user/auth/login/wechat`| POST | Login with WeChat Code |
| Register | `/api/user/auth/register` | POST | Register with Phone/OTP |
| Order History | `/api/order/history` | GET | List past orders |
| Wallet | `/api/payment/wallet` | GET | Get wallet balance |
| Transactions | `/api/payment/transactions` | GET | Get payment history |

## 3. Architecture
The app follows the **MVVM (Model-View-ViewModel)** pattern.
- **Views**: SwiftUI views responsible for UI layout.
- **ViewModels**: Handle business logic, API calls, and state management (`@Observable` or `ObservableObject`).
- **Services**: `APIService` handles low-level networking and token management.

## 4. Theme & Localization
- **Theme**: Supports System Light/Dark modes. Custom colors should be avoiding; use Semantic colors (e.g. `.systemBackground`, `.primary`) instead.
- **Localization**: Supports English (`en`) and Simplified Chinese (`zh-Hans`).

## 5. Development Guidelines
- Do not use hardcoded strings; use `NSLocalizedString` or `Text("key", bundle: nil)`.
- Do not use hardcoded colors; use system semantic colors.
- Ensure all new Views are added to `ContentView` navigation stack or relevant parent views.

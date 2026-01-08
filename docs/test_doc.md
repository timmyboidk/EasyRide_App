# Internal Testing Documentation

## Debug Login Mechanism
To facilitate internal testing without consuming SMS credits or requiring a WeChat account, a "Magic Credential" bypass has been implemented.

### Bypass Credentials
- **Phone Number**: `99999999999`
- **OTP Code**: `000000`

### How to use
1. Launch the app.
2. Enter the phone number `99999999999`.
3. Tap "Get OTP". The field will auto-fill or you can enter `000000`.
4. Tap "Login".
5. The app will bypass network authentication and log you in as a **Debug User**.

## Environment Setup
Ensure your local backend is running:
- **Base URL**: `http://localhost:8080` (Configured in `AppConfiguration.swift`)
- **Docker**: Ensure all containers (`easyride-backend`, `mysql`, `redis`, `rocketmq`) are up.

## Feature Testing
- **Orders**: Go to "Orders" tab. It fetches from `/api/order/history`.
- **Wallet**: Go to "Profile" -> "Wallet". It fetches from `/api/payment/wallet`.
- **Profile**: Go to "Profile". It uses the cached User object.

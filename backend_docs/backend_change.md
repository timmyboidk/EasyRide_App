# Backend API Assumptions and Proposed Changes

## Assumptions
The following assumptions are made based on the requirement to support "WeChat and Phone OTP sign up ONLY".

### 1. Registration via OTP
The current `POST /api/user/auth/register` endpoint requires `password`.
**Assumption:** We need a new endpoint or a modification to the existing one to support registration using only a Phone Number and OTP (verified before calling this, or sent with it).
**Proposed Change:**
- New Endpoint: `POST /api/user/auth/register/otp`
- Request Body:
```json
{
  "phoneNumber": "13912345678",
  "otp": "123456", // OTP code to verify ownership
  "nickname": "New User",
  "role": "PASSENGER" // Default to PASSENGER?
}
```
- A password will be auto-generated or the user will obtain a token directly without setting a password initially (password-less flow).

### 2. Login via WeChat
**Assumption:** The backend needs to verify a WeChat Auth Token or Code.
**Proposed Change:**
- New Endpoint: `POST /api/user/auth/login/wechat`
- Request Body:
```json
{
  "code": "WECHAT_AUTH_CODE", // Code returned from WeChat SDK
  "phoneNumber": "13912345678" // Optional: if binding is required
}
```

### 3. API Path Corrections
The following discrepancies were found between `APIEndpoint.swift` and `API_REFERENCE.md`. We will assume `API_REFERENCE.md` is the source of truth, but we need these specific paths for the app:

| Action | Current `APIEndpoint.swift` | `API_REFERENCE.md` | Assumption/Correction |
| :--- | :--- | :--- | :--- |
| Login (Password) | `/api/user/login` | `/api/user/auth/login/password` | Use `/api/user/auth/login/password` |
| Login (OTP) | `/api/user/login/otp` | `/api/user/auth/login/otp` | Use `/api/user/auth/login/otp` |
| Register | `/api/user/register` | `/api/user/auth/register` | Use `/api/user/auth/register` (Note: we want OTP version) |
| Refresh Token | `/api/user/refresh` | (Not explicitly listed in snippet but implied) | Keeping `/api/user/refresh` or `/api/user/auth/refresh`? Assumption: `/api/user/auth/refresh` to be consistent. |
| Logout | `/api/user/logout` | (Not explicitly listed in snippet) | Assumption: `/api/user/auth/logout` |

## Summary of Frontend Requirements
1.  **Remove Password Login**: Frontend will remove the password login UI.
2.  **Remove Password Registration**: Frontend will remove password fields in registration.
3.  **Add WeChat Login**: Frontend calls `POST /api/user/auth/login/wechat`.
4.  **Add OTP Login**: Frontend calls `POST /api/user/auth/login/otp`.
5.  **OTP Request**: Frontend calls `POST /api/user/auth/otp/request` (implied from `/api/user/otp/request` in doc, let's stick to doc: `/api/user/otp/request`).

# Frontend Authentication Integration

## Overview
The frontend now integrates with the Django backend authentication system using JWT tokens.

## Setup Requirements

### Backend Server
Make sure the Django backend is running on the correct URL. The default configuration uses:
- Android Emulator: `http://10.0.2.2:8000/api`
- iOS Simulator: `http://localhost:8000/api`
- Physical Device: Replace with your computer's IP address

### Dependencies
The following packages are already included in `pubspec.yaml`:
- `http: ^1.2.0` - For API calls
- `flutter_secure_storage: ^9.0.0` - For secure token storage

## Authentication Flow

### Registration
1. User fills registration form (name, email, phone, user type, password)
2. Frontend calls `AuthService.register()` with user data
3. Backend creates user and returns success/error
4. On success, user is redirected to login screen

### Login
1. User enters email and password
2. Frontend calls `AuthService.login()` with credentials
3. Backend validates credentials and returns JWT tokens
4. Tokens are stored securely using `flutter_secure_storage`
5. User data is fetched and stored
6. User is redirected to appropriate home screen based on user type

### Session Management
- JWT access token is used for API authentication
- Refresh token is stored for token renewal
- User data is cached locally
- App checks authentication status on startup

### Logout
- Tokens and user data are cleared from secure storage
- User is redirected to welcome screen

## User Types and Navigation
- **Customer**: Redirected to `/home` (HomeScreen)
- **Vendor**: Redirected to `/vendor-home` (VendorHomeScreen)
- **Security**: Redirected to `/security-home` (SecurityHomeScreen)
- **Admin**: Redirected to `/admin-home` (AdminHomeScreen)

## API Endpoints Used
- `POST /api/auth/register/` - User registration
- `POST /api/auth/token/` - User login (get tokens)
- `POST /api/auth/token/refresh/` - Refresh access token
- `GET /api/users/profile/` - Get user profile data

## Error Handling
- Network errors are caught and displayed as snackbars
- Validation errors from backend are parsed and shown to user
- Token expiration triggers automatic logout

## Security Features
- JWT tokens stored securely
- Passwords never stored in plain text
- HTTPS recommended for production
- Token refresh mechanism implemented

## Testing the Integration

1. Start the Django backend server
2. Run the Flutter app
3. Register a new user
4. Login with the registered credentials
5. Verify correct redirection based on user type
6. Test logout functionality

## Troubleshooting

### Connection Issues
- Verify backend server is running
- Check the API base URL in `AuthService`
- Ensure firewall allows connections

### Authentication Issues
- Check backend logs for errors
- Verify user credentials
- Check token expiration

### Storage Issues
- Clear app data if tokens become corrupted
- Check secure storage permissions
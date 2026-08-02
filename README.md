# OpsBoard - Enterprise Incident & Task Manager

### 📝 OpsBoard Progress Report: Module 1 (Auth Refactoring)
* **Current State:** Architecture refactored into feature-first layout. Auth logic successfully extracted into `AuthService`. `LoginScreen` UI updated to use the service layer.
* **Completed Files:**
    * `lib/services/auth_service.dart`
    * `lib/screens/login_screen.dart`
    * `lib/screens/dashboard_screen.dart`
    * `lib/screens/signup_screen.dart`
* **Packages Added:** `firebase_auth`, `cloud_firestore`
* **Next Immediate Step:** Create the `TaskModel` data class to structure our incident data (severity, status, timestamps).
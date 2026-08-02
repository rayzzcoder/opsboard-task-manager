# OpsBoard - Enterprise Incident & Task Manager

A professional, feature-driven Flutter application designed to track operational incidents and tasks with enterprise-grade architecture, severity levels, and real-time cloud synchronization.

---

## Project Progress & Changelog

### 📝 OpsBoard Progress Report: Module 3 (Firestore Service Layer)
* **Current State:** Decoupled database operations from the UI. Created `FirestoreService` to handle secure, authenticated CRUD operations (Real-time stream, Add, Update, Delete) targeted to the user's specific subcollection.
* **Completed Files:**
    * `lib/services/auth_service.dart`
    * `lib/services/firestore_service.dart`
    * `lib/screens/login_screen.dart`
    * `lib/screens/dashboard_screen.dart`
    * `lib/screens/signup_screen.dart`
    * `lib/models/task_model.dart`
    * `README.md` (Cumulative Tracker)
* **Packages Added:** `firebase_auth`, `cloud_firestore`
* **Next Immediate Step:** Build the state management layer (Provider) to connect our `FirestoreService` data streams to the UI screens.

---

---

## Project Progress & Changelog

### 📝 OpsBoard Progress Report: Module 2 (Data Modeling)
* **Current State:** Architecture refactored. Authentication isolated into service layer. Incident data schema (`TaskModel`) created with robust serialization/deserialization for Firestore.
* **Completed Files:**
    * `lib/services/auth_service.dart`
    * `lib/screens/login_screen.dart`
    * `lib/screens/dashboard_screen.dart`
    * `lib/screens/signup_screen.dart`
    * `lib/models/task_model.dart`
    * `README.md` (Cumulative Tracker)
* **Packages Added:** `firebase_auth`, `cloud_firestore`
* **Next Immediate Step:** Create the `FirestoreService` to handle CRUD operations for our new `TaskModel`.

---

### 📝 OpsBoard Progress Report: Module 1 (Auth Refactoring)
* **Current State:** Architecture refactored into feature-first layout. Auth logic successfully extracted into `AuthService`. `LoginScreen` UI updated to use the service layer.
* **Completed Files:**
    * `lib/services/auth_service.dart`
    * `lib/screens/login_screen.dart`
    * `lib/screens/dashboard_screen.dart`
    * `lib/screens/signup_screen.dart`
* **Packages Added:** `firebase_auth`, `cloud_firestore`
* **Status:** Completed & Successfully Pushed to GitHub.
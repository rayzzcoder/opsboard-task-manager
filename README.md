# OpsBoard - Enterprise Incident & Task Manager

A professional, feature-driven Flutter application designed to track operational incidents and tasks with enterprise-grade architecture, severity levels, and real-time cloud synchronization.

---

## Project Progress & Changelog

### 📝 OpsBoard Progress Report: Module 5 (Command Center UI & Auth Polish)
* **Current State:** Built the enterprise-grade `DashboardScreen` UI and integrated real-time data streams via `TaskProvider`. Refined authentication layout with perfectly symmetrical, branded UI elements for both `LoginScreen` and `SignupScreen`.
* **Completed Files:**
    * `lib/services/auth_service.dart`
    * `lib/services/firestore_service.dart`
    * `lib/providers/task_provider.dart`
    * `lib/main.dart`
    * `lib/screens/login_screen.dart`
    * `lib/screens/signup_screen.dart`
    * `lib/screens/dashboard_screen.dart`
    * `lib/models/task_model.dart`
    * `README.md` (Cumulative Tracker)
* **Packages Added:** `firebase_auth`, `cloud_firestore`, `provider`
* **Status:** Fully Functional & Production-Ready Architecture.

---

---

## Project Progress & Changelog

### 📝 OpsBoard Progress Report: Module 4 (State Management Layer)
* **Current State:** Integrated the `provider` package. Created `TaskProvider` (extending `ChangeNotifier`) to handle local state and manage Firestore data mutations cleanly. Registered the provider globally in `main.dart` using `ChangeNotifierProvider`.
* **Completed Files:**
    * `lib/services/auth_service.dart`
    * `lib/services/firestore_service.dart`
    * `lib/providers/task_provider.dart`
    * `lib/main.dart`
    * `lib/screens/login_screen.dart`
    * `lib/screens/dashboard_screen.dart`
    * `lib/screens/signup_screen.dart`
    * `lib/models/task_model.dart`
    * `README.md` (Cumulative Tracker)
* **Packages Added:** `firebase_auth`, `cloud_firestore`, `provider`
* **Next Immediate Step:** Build the Dashboard Command Center UI to consume live data streams from the `TaskProvider`.

---

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
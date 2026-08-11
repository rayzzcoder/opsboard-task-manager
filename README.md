# OpsBoard - Enterprise Incident & Task Manager

A professional, feature-driven Flutter application designed to track operational incidents and tasks with enterprise-grade architecture, severity levels, and real-time cloud synchronization.

---

## Project Progress & Changelog

### 📝 OpsBoard Progress Report: Module 13 (Infinite Scrolling & Pagination)
* **Current State:** Engineered stream-based pagination to handle enterprise-scale ticket volumes without performance degradation or excessive database reads. Integrated a `ScrollController` in `DashboardScreen` to detect scroll boundaries, and dynamically manage a `StreamSubscription` in `TaskProvider` that scales the Firestore document limit seamlessly.
* **Completed Files:**
    * `lib/services/firestore_service.dart`
    * `lib/providers/task_provider.dart`
    * `lib/screens/dashboard_screen.dart`
    * `README.md` (Cumulative Tracker)
* **Status:** Completed & Successfully Pushed.

### 📝 OpsBoard Progress Report: Module 12 (Internal Routing & Navigation)
* **Current State:** Transformed the application from a single-screen view into a multi-page enterprise scaffolding. Implemented a persistent `BottomNavigationBar` with stateful indexed routing. Segmented UI into `Incidents`, `Teams`, and `Profile` tabs. Engineered dynamic AppBar titles and context-aware Floating Action Buttons that respond to the active navigation state.
* **Completed Files:**
    * `lib/screens/dashboard_screen.dart`
    * `README.md` (Cumulative Tracker)
* **Status:** Completed & Successfully Pushed.

### 📝 OpsBoard Progress Report: Module 11 (Full CRUD & Edit Engine)
* **Current State:** Implemented the final missing 'U' in CRUD operations. Added `editTaskDetails` to `TaskProvider` for full document updates. Designed and integrated `_showEditTaskModal` in `DashboardScreen`, allowing Admins to modify incident titles, descriptions, severities, and team assignments dynamically. Restricted edit UI access strictly to Admin roles.
* **Completed Files:**
    * `lib/providers/task_provider.dart`
    * `lib/screens/dashboard_screen.dart`
    * `README.md` (Cumulative Tracker)
* **Status:** Completed & Successfully Pushed.

### 📝 OpsBoard Progress Report: Module 10 (Role-Based Access Control & Security)
* **Current State:** Implemented strict Role-Based Access Control (RBAC) distinguishing between Admin and Agent roles. Updated the `SignupScreen` to assign Roles and Teams. Modified `FirestoreService` to point to a global organization board. Locked down the `DashboardScreen` UI so Agents cannot create/delete tasks, and can only update the status of tickets assigned to their specific team.
* **Completed Files:**
  * `lib/services/firestore_service.dart`
  * `lib/providers/task_provider.dart`
  * `lib/screens/signup_screen.dart`
  * `lib/screens/dashboard_screen.dart`
  * `README.md` (Cumulative Tracker)
* **Status:** Completed & Successfully Pushed.

### 📝 OpsBoard Progress Report: Module 9 (Team Routing & Assignment)
* **Current State:** Expanded `TaskModel` and `TaskProvider` to include an `assignee` field for team routing. Enhanced the Dashboard UI with a dual-dropdown layout for Severity and Team Assignment, and added dynamic visual Assignment Badges to the incident cards.
* **Completed Files:**
  * `lib/models/task_model.dart`
  * `lib/providers/task_provider.dart`
  * `lib/screens/dashboard_screen.dart`
  * `README.md` (Cumulative Tracker)
* **Status:** Completed & Successfully Pushed.

### 📝 OpsBoard Progress Report: Module 8 (Dynamic Theme Engine)
* **Current State:** Implemented a global `ThemeProvider` utilizing `MultiProvider` to allow dynamic state switching. Integrated modern Material 3 `ThemeData` auto-theming, successfully removing SDK deprecation warnings. Added a seamless Light/Dark mode toggle to the Dashboard app bar.
* **Completed Files:**
  * `lib/providers/theme_provider.dart`
  * `lib/main.dart`
  * `lib/screens/dashboard_screen.dart`
  * `README.md` (Cumulative Tracker)
* **Status:** Completed & Successfully Pushed.

### 📝 OpsBoard Progress Report: Module 7 (Dynamic Filtering Engine)
* **Current State:** Implemented state-based filtering within `TaskProvider` to sort incidents in memory, eliminating redundant database reads. Added an interactive `ChoiceChip` row to the Dashboard UI, allowing users to instantly filter tasks by 'All', 'Critical', 'Open', 'In Progress', and 'Resolved'.
* **Completed Files:**
  * `lib/providers/task_provider.dart`
  * `lib/screens/dashboard_screen.dart`
  * `README.md` (Cumulative Tracker)
* **Status:** Completed & Successfully Pushed.

### 📝 OpsBoard Progress Report: Module 6 (Operations Analytics Banner)
* **Current State:** Integrated real-time statistical aggregations into `TaskProvider` (computed getters for Active, Critical alerts, and Resolved tickets). Enhanced `DashboardScreen` with a sleek, dark analytics header displaying live operational metrics at a glance.
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
* **Status:** Tested & Fully Functional.

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
* **Status:** Completed & Successfully Pushed.

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
* **Status:** Completed & Successfully Pushed.

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
* **Status:** Completed & Successfully Pushed.

### 📝 OpsBoard Progress Report: Module 1 (Auth Refactoring)
* **Current State:** Architecture refactored into feature-first layout. Auth logic successfully extracted into `AuthService`. `LoginScreen` UI updated to use the service layer.
* **Completed Files:**
  * `lib/services/auth_service.dart`
  * `lib/screens/login_screen.dart`
  * `lib/screens/dashboard_screen.dart`
  * `lib/screens/signup_screen.dart`
* **Packages Added:** `firebase_auth`, `cloud_firestore`
* **Status:** Completed & Successfully Pushed to GitHub.
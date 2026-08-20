# OpsBoard - Enterprise Incident & Task Manager

A professional, feature-driven Flutter application designed to track operational incidents and tasks with enterprise-grade architecture, severity levels, and real-time cloud synchronization.

---

## Project Progress & Changelog

### 📝 OpsBoard Progress Report: Module 21 (Monetization & Test Suite)
* **Current State:** Finalized the capstone application for production release. Engineered a seamless monetization layer by integrating Google AdMob `BannerAd` components directly into the main stateful scaffold without disrupting UX or team command center workflows. Developed a robust Unit Testing suite using `flutter_test` to validate `TaskModel` JSON parsing, default fallbacks, and DateTime formatting logic. Configured native Android (`AndroidManifest.xml`) and iOS (`Info.plist`) properties for secure AdMob initialization.
* **Completed Files:**
  * `lib/main.dart`
  * `lib/screens/dashboard_screen.dart`
  * `lib/widgets/ad_banner_widget.dart` (NEW)
  * `test/task_model_test.dart` (NEW)
  * `android/app/src/main/AndroidManifest.xml`
  * `ios/Runner/Info.plist`
  * `README.md` (Cumulative Tracker)
* **Packages Added:** `google_mobile_ads`, `flutter_test`
* **Status:** Completed, Tested, & Production-Ready.

### 📝 OpsBoard Progress Report: Module 20 (Visual Analytics Engine)
* **Current State:** Engineered a dedicated `AnalyticsTab` using the `fl_chart` package to render real-time, interactive data visualizations. Developed dynamic data processing logic to compute active incident severity breakdowns (Donut Chart) and live team workload distribution (Bar Chart) directly from the `TaskProvider` state. Upgraded the main `DashboardScreen` routing and `BottomNavigationBar` to support a 4-tab fixed layout without visual clipping.
* **Completed Files:**
  * `lib/screens/analytics_tab.dart` (NEW)
  * `lib/screens/dashboard_screen.dart`
  * `README.md` (Cumulative Tracker)
* **Packages Added:** `fl_chart`
* **Status:** Completed & Successfully Pushed.

### 📝 OpsBoard Progress Report: Module 19 (PDF Export Engine)
* **Current State:** Engineered a dedicated `PdfService` utilizing the `pdf` and `printing` packages to generate professional, enterprise-grade Incident Reports. The engine parses real-time Firestore document data—including color-coded severity badges, metadata, descriptions, and the complete Activity Log—into a dynamically drawn A4 document. Implemented character sanitization (swapping UI bullets for PDF-safe hyphens) to ensure flawless cross-platform rendering. Wired the export trigger directly into the Activity Log modal, utilizing the native OS share sheet for saving, printing, and emailing.
* **Completed Files:**
  * `lib/services/pdf_service.dart` (NEW)
  * `lib/screens/dashboard_screen.dart`
  * `lib/screens/team_dashboard_screen.dart`
  * `README.md` (Cumulative Tracker)
* **Packages Added:** `pdf`, `printing`
* **Status:** Completed & Successfully Pushed.

### 📝 OpsBoard Progress Report: Module 18 (Dedicated Workspaces & Real-Time Data Streaming)
* **Current State:** Engineered dedicated Team Command Centers featuring dynamic visual routing, unique headers, and isolated Firestore streams. Upgraded the Incident Activity Log from a static form to a live, real-time chat interface utilizing Firebase `StreamBuilder` for instant message delivery without closing the UI. Implemented a custom `PopScope` navigation interceptor to provide sequential, intuitive swipe-back routing (Profile ➔ Teams ➔ Incidents) preventing accidental app closures. Redesigned the global dashboard analytics banner to display 4 distinct states, paired with instant visual color-coding for all ticket statuses (Open, In Progress, Resolved).
* **Completed Files:**
  * `lib/providers/task_provider.dart`
  * `lib/screens/dashboard_screen.dart`
  * `lib/screens/team_dashboard_screen.dart` (NEW)
  * `README.md` (Cumulative Tracker)
* **Status:** Completed & Successfully Pushed.

### 📝 OpsBoard Progress Report: Module 17 (Collaborative Activity Logs & Smart Notifications)
* **Current State:** Engineered an in-app Activity Log allowing authenticated users to post real-time updates to individual incidents. Implemented strict Role-Based Access Control (RBAC) preventing unauthorized teams from viewing restricted incident chat logs. Designed a lightweight 'Read Receipt' engine using Firestore arrays to dynamically render 'NEW' notification badges on incident cards, which instantly dismiss upon user engagement. Added robust null-safety handling to the `ListView.builder` to gracefully manage corrupted or manually deleted database arrays.
* **Completed Files:**
  * `lib/models/task_model.dart`
  * `lib/providers/task_provider.dart`
  * `lib/screens/dashboard_screen.dart`
  * `README.md` (Cumulative Tracker)
* **Status:** Completed & Successfully Pushed.

### 📝 OpsBoard Progress Report: Module 16 (Real-Time Search Engine)
* **Current State:** Engineered a real-time local search engine inside `TaskProvider`. Added a responsive Search Bar to the dashboard UI that instantly filters the active task stream by comparing user input against incident titles and descriptions. This approach eliminates redundant Firestore reads while providing zero-latency search results.
* **Completed Files:**
  * `lib/providers/task_provider.dart`
  * `lib/screens/dashboard_screen.dart`
  * `README.md` (Cumulative Tracker)
* **Status:** Completed & Successfully Pushed.

### 📝 OpsBoard Progress Report: Module 15 (Team Directory, Profile Engine & UX Polish)
* **Current State:** Fully populated the `Teams` and `Profile` tabs within the stateful bottom navigation scaffold. Engineered an interactive Team Directory displaying operational units and responsive snackbars. Built a dynamic User Profile card displaying live Firebase Auth credentials, role-specific badge styling, and custom clearance logic ("Global Command" for Admins). Fixed async context guardrail warnings across authentication flows.
* **Completed Files:**
  * `lib/screens/dashboard_screen.dart`
  * `README.md` (Cumulative Tracker)
* **Status:** Completed & Successfully Pushed.

### 📝 OpsBoard Progress Report: Module 14 (Chronological Ordering & Data Safeguards)
* **Current State:** Upgraded the database schema and UI to support precise chronological incident tracking. Integrated a `createdAt` timestamp in `TaskModel` with 12-hour AM/PM formatting. Updated `FirestoreService` to enforce `.orderBy()` sorting, ensuring the newest incidents always render at the top of the global board. Implemented a robust `AlertDialog` guardrail in the UI to prevent accidental deletions by Admins.
* **Completed Files:**
  * `lib/models/task_model.dart`
  * `lib/services/firestore_service.dart`
  * `lib/providers/task_provider.dart`
  * `lib/screens/dashboard_screen.dart`
  * `README.md` (Cumulative Tracker)
* **Status:** Completed & Successfully Pushed.

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

---

## ⚠️ Important Configuration Note: Firebase Security Rules
OpsBoard is currently operating under Firebase "Test Mode" security rules with a hardcoded expiration date.
* **Current Expiration Date:** September 14, 2026.
* **Symptom of Expiration:** If the application suddenly fails to load data, hides features, or automatically downgrades all users to the default `Agent` & `Unassigned` roles, the security rules have expired.
* **How to Fix:** Navigate to **Firebase Console ➔ Firestore Database ➔ Rules** and update the `timestamp.date(YYYY, MM, DD)` to a future date.
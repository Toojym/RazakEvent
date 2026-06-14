# RazakEvent - Kolej Tun Razak Event Management Hub

A cross-platform mobile application for centralizing event discovery, QR attendance tracking, crew recruitment, and sponsorship management at Kolej Tun Razak, UTM.

---

## Project Overview

RazakEvent solves the problem of event information being scattered across WhatsApp groups by providing one central app for Kolej Tun Razak (KTR) students and staff.

### Main Features

- **Event Discovery** - Browse and filter upcoming events by category
- **QR Attendance** - Scan QR codes to check-in at events and auto-track merit points
- **Crew Recruitment** - Apply for event volunteer positions directly in the app
- **Sponsorship Management** - Track fundraising goals and progress
- **Leaderboard** - View merit point rankings across KTR students
- **Organizer Tools** - Create/edit events, generate QR codes, view registered participants, and upload reports
- **Profile Management** - Track personal participation stats, merits collected, and volunteer history

---

## Screenshots

### Login Screen
Students authenticate using their UTM email and password. New users can sign up directly from the app.

### Home Screen (Student)
Browse events filtered by category. The "What's Happening This Week?" and "Coming Soon!" sections keep students informed.

### QR Attendance Scanner
Scan event QR codes to check-in. Successful scans automatically award merit points.

### Profile Screen
View your leaderboard ranking, total merits collected, events participated, and events volunteered.

---

## Technology Stack

| Component | Technology |
|-----------|------------|
| Frontend | Flutter + Dart (v1.0.0+1) |
| Backend | Firebase (Firestore, Auth, Storage) |
| QR Scanning | mobile_scanner |
| QR Generation | qr_flutter |
| Image Save | image_gallery_saver |
| State Management | Provider |
| UUID | uuid |
| Version Control | Git + GitHub |
| Project Management | Jira (Agile/Scrum) |

---

## Project Structure

```
RazakEvent/
├── android/                          # Android native configuration
├── ios/                              # iOS native configuration
├── assets/
│   └── images/                       # Background textures and images
├── lib/
│   ├── main.dart                     # App entry point with Firebase init
│   ├── firebase_options.dart         # Firebase configuration
│   ├── models/                       # Data models
│   │   ├── attendance_model.dart     # Attendance/check-in records
│   │   ├── date_filter.dart          # Date filtering helper
│   │   ├── event_model.dart          # Event data structure
│   │   ├── registration_model.dart   # Event registration records
│   │   ├── report_model.dart         # Sponsorship report model
│   │   └── user_model.dart           # User profile and roles
│   ├── repositories/                 # Firebase data access layer
│   │   ├── attendance_repository.dart
│   │   ├── event_repository.dart
│   │   ├── registration_repository.dart
│   │   ├── report_repository.dart
│   │   └── user_repository.dart
│   ├── utils/
│   │   └── app_theme.dart            # Global theme and color constants
│   ├── viewmodels/                   # Business logic (MVVM pattern)
│   │   ├── auth_viewmodel.dart
│   │   ├── create_event_viewmodel.dart
│   │   ├── edit_event_viewmodel.dart
│   │   ├── event_detail_viewmodel.dart
│   │   ├── event_qr_viewmodel.dart
│   │   ├── event_viewmodel.dart
│   │   ├── home_viewmodel.dart
│   │   ├── leaderboard_viewmodel.dart
│   │   ├── organizer_profile_viewmodel.dart
│   │   ├── profile_viewmodel.dart
│   │   ├── scan_viewmodel.dart
│   │   ├── upload_report_viewmodel.dart
│   │   ├── view_registered_participants_viewmodel.dart
│   │   └── view_reports_viewmodel.dart
│   └── views/                        # UI screens
│       ├── active_events_list_view.dart
│       ├── auth_view.dart
│       ├── create_event_view.dart
│       ├── edit_event_view.dart
│       ├── event_detail_view.dart
│       ├── event_list_view.dart
│       ├── event_qr_view.dart
│       ├── home_view.dart
│       ├── leaderboard_view.dart
│       ├── logo_view.dart
│       ├── main_view.dart
│       ├── organizer_home_view.dart
│       ├── organizer_profile_view.dart
│       ├── profile_view.dart
│       ├── root_view.dart
│       ├── scan_view.dart
│       ├── upload_report_view.dart
│       ├── verify_email_view.dart
│       ├── view_registered_participants_view.dart
│       └── view_reports_view.dart
├── test/                             # Unit and widget tests
├── web/                              # Web platform support
├── firebase.json                     # Firebase project configuration
├── firestore.rules                   # Firestore security rules
├── pubspec.yaml                      # Dependencies and assets
├── BRANCH_WORKFLOW.md                # Git branching guidelines
├── CHANGELOG.md                      # Sprint-by-sprint changelog
└── README.md                         # This file
```

---

## Getting Started

### Prerequisites

| Tool | Version | Download |
|------|---------|----------|
| Flutter SDK | 3.x | https://docs.flutter.dev/get-started/install |
| Android Studio | Latest | https://developer.android.com/studio |
| VS Code (optional) | Latest | https://code.visualstudio.com/ |
| Git | Latest | https://git-scm.com/downloads |

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Toojym/RazakEvent.git
   cd RazakEvent
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up Firebase**
   - The `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) files are included in the repository.
   - If setting up from scratch, connect to the Firebase project via `flutterfire configure`.

4. **Run the app**
   - Connect a physical device or start an Android emulator
   ```bash
   flutter run
   ```

---

## Architecture

The app follows the **MVVM (Model-View-ViewModel)** architecture pattern:

- **Models** (`lib/models/`) - Plain Dart objects representing data structures
- **Repositories** (`lib/repositories/`) - Handle all Firebase Firestore/Storage operations
- **ViewModels** (`lib/viewmodels/`) - Contain business logic, extend `ChangeNotifier`, used with `Provider`
- **Views** (`lib/views/`) - Stateless/stateful Flutter widgets, consume ViewModels via `context.watch<T>()`

### Navigation Flow

```
LogoView → AuthView (Login/Signup) → VerifyEmailView
                                       ↓
                                  RootView (auth check)
                                       ↓
                                  MainView (bottom nav)
                                    ├── HomeView (student)
                                    │     └── EventDetailView
                                    ├── ScanView (QR scanner)
                                    └── ProfileView
                                          └── LeaderboardView

Organizer flow:
MainView → CreateEventView, EditEventView, OrganizerHomeView,
           EventQRView, ViewRegisteredParticipantsView,
           UploadReportView, ViewReportsView
```

---

## User Roles

| Role | Access |
|------|--------|
| **Student** | Browse events, scan QR to check-in, view profile, view leaderboard, apply for crew |
| **Organizer** | All student access + create/edit events, generate QR codes, view participants, upload reports |

---

## Team

| Member | Role |
|--------|------|
| Toojym (MR) | Project Manager & Backend Developer |
| Mohamed-M-M-Ramadan (R) | Lead Developer (UI, Scanner, Recruitment, Sponsorship) |
| Khalid (K) | Support Developer (Dialogs, Testing, Documentation, Release) |
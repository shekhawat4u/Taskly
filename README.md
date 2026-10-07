# Taskly

Taskly is a Flutter mobile app for assigning, tracking, and discussing team
tasks. It targets Android and iOS and provides a shared workspace for task
ownership, progress, due dates, team coordination, and notifications.

## Features

- Dashboard with task summaries and activity
- Create, assign, search, filter, start, and complete tasks
- Priorities, due dates, subtasks, comments, activity history, and attachments
- Calendar view and completed-task history
- Team member and organization administration
- Analytics and an internal design-system showcase
- Light and dark themes
- Firebase-backed live synchronization through Cloud Firestore
- Push and local notification support

## Technology

- Flutter and Dart
- Riverpod for application state
- GoRouter for navigation
- Firebase Core, Cloud Firestore, and Firebase Messaging
- Supabase migrations and edge functions for a separate backend design
- `fl_chart` and `table_calendar` for analytics and calendar views

## Project Structure

```text
lib/
  app/       Application theme, routing, and app shell
  core/      Services, utilities, extensions, and errors
  features/  Feature screens, providers, and repositories
  shared/    Domain models and reusable widgets
supabase/    Database migrations, seed data, and edge functions
android/     Android platform project
ios/         iOS platform project
test/        Flutter tests
```

## Requirements

- Flutter SDK with Dart `^3.13.1`
- Android Studio or Xcode for device builds
- A configured Firebase project for live Firestore synchronization

## Setup

1. Install Flutter and verify the installation:

	```bash
	flutter doctor
	```

2. Install dependencies:

	```bash
	flutter pub get
	```

3. Configure Firebase for the target platforms. The project expects the
	generated Firebase options and the platform configuration files to be
	present; do not commit private service-account credentials.

4. Run the application on a connected device or emulator:

	```bash
	flutter run
	```

## Development Commands

```bash
# Format Dart code
dart format .

# Analyze the project
flutter analyze

# Run tests
flutter test

# Build an Android APK
flutter build apk
```

## Architecture Notes

The current mobile data path is:

```text
Flutter screens -> Riverpod providers -> repositories -> MockDataStore -> Firestore
```

`MockDataStore` is an in-memory projection that also listens to and writes to
Cloud Firestore. The Supabase schema, migrations, and edge functions under
`supabase/` describe a parallel backend target; the current feature
repositories are Firebase-oriented and do not use Supabase as their runtime
source of truth.

Authentication and some seeded data are currently demo-oriented. Before a
production release, choose one backend, replace demo authentication, remove
raw-password persistence, verify security rules and secrets, and add coverage
for task lifecycle and notification flows.

## Routes

The main navigation includes `/home`, `/tasks`, `/calendar`,
`/notifications`, and `/profile`. Additional workflows include task creation
and details, completed tasks, team management, administration, analytics, and
the design system. The app starts at `/login`.

## License

This is an internal project and is not published to pub.dev.

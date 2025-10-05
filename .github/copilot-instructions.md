<!--
Guidance for AI coding agents working on the attendance_app Flutter project.
Keep this short and specific: reference files, patterns, conventions, build/test/debug commands,
and integration points so an AI agent can be immediately productive.
-->

# copilot-instructions for attendance_app

This file contains focused, actionable guidance for automated coding agents and reviewers
working on the attendance_app Flutter repository. Prefer concrete, discoverable rules
over generic advice.

Overview
- Flutter app (Dart) using Provider for state, Firebase for backend init, and several
  platform services for geolocation, face verification (mocked), and attendance submission.
- Entry point: `lib/main.dart` (initializes Firebase, SharedPreferences and MultiProvider).
- UI and app-specific logic live under `lib/ux/` and platform integrations under `lib/platform/`.

Key architecture notes (what to read first)
- `lib/main.dart` — app startup, Firebase.initializeApp (explicit options present) and
  MultiProvider wiring: `AuthViewModel`, `UserViewModel`, `CourseViewModel`.
- `lib/ux/shared/view_models/` — view models contain app state and small business logic
  (e.g. `auth_view_model.dart` uses SharedPreferences; follow these for caching patterns).
- `lib/platform/services/` — platform abstraction layer: e.g. `attendance_service.dart` (has
  a `MockAttendanceService` implementation used locally), `location_service.dart`.
- `lib/ux/navigation/` — contains simple Navigator helpers (`navigation.dart`) and the
  `NavigationHostPage` which composes the bottom navigation and main pages.

Project-specific conventions and patterns
- State management: Provider + ChangeNotifier. View models expose getters, setters and
  notifyListeners(). Tests and edits should preserve this pattern (avoid introducing
  Bloc/Riverpod without a clear migration plan).
- Caching: SharedPreferences is used directly in view models (see `AuthViewModel` and
  `UserViewModel`). When adding persisted keys, add them to `lib/ux/shared/resources/app_constants.dart`.
- Navigation: centralized in `lib/ux/navigation/navigation.dart`. Use the existing helper
  methods (navigateToScreen, navigateToHomePage, navigateToFaceVerification) to keep
  routing consistent and preserve platform transitions.
- Platform services are abstracted via simple interfaces (e.g. `AttendanceService`).
  Tests and feature work should prefer introducing a mock implementation in `lib/platform/services`
  rather than touching app UI.
- UI components: reusable widgets are under `lib/ux/shared/components/` (e.g. `app_material.dart`,
  `app_buttons.dart`). Prefer composing these for consistent styling.

Integration points and external dependencies to be cautious about
- Firebase initialization is explicit in `main.dart` (hard-coded options). Be careful
  when changing these values — they are required at runtime for Firebase APIs.
- Native permissions and hardware: camera, location, face verification and QR scanning
  are used. See `pubspec.yaml` dependencies: `camera`, `geolocator`, `mobile_scanner`,
  `permission_handler`, `face_verification_service.dart` (platform implementation).
  Respect permission flows in `lib/platform/utils/permission_utils.dart` and UI alert dialogs
  in `lib/ux/views/attendance/alert_dialogs/`.

Note about demo / mocked implementations
- Many services and flows in this repository are implemented as demos or mocks (for example,
  `MockAttendanceService` in `lib/platform/services/attendance_service.dart` and the
  simplified `face_verification_service.dart` usage). Expect these to change when the
  real backend, verification SDKs, or hardware integrations are integrated.
- When replacing a mock with a real implementation:
  - Preserve the service interface (the abstract class in `lib/platform/services/`).
  - Add configuration flags or DI switches (factory or provider) so tests can still inject
    mocks. See how services are consumed from view models like `AttendanceViewModel`.
  - Update `lib/ux/shared/resources/app_constants.dart` if you introduce new persisted keys.
  - Add small, focused tests for the integration adapter (happy path + permission failure).


Build / run / test commands (Windows / PowerShell)
- Install deps: `flutter pub get`
- Run on connected device/emulator: `flutter run`
- Build APK: `flutter build apk --release`
- Run analyzer / lints: `flutter analyze` (project uses `flutter_lints`)
- Run tests: `flutter test` (there is a `test/widget_test.dart` to start with)

Quick debugging tips
- To reproduce startup behavior, ensure Firebase initialization in `main.dart` does not throw.
  The app already catches and prints errors during Firebase.initializeApp — look at console logs.
- When editing view models that use SharedPreferences, note `UserViewModel(pref: prefs)` is
  constructed in `main.dart` so tests that instantiate view models directly may need a
  fake SharedPreferences (or call `SharedPreferences.setMockInitialValues({})`).

Code patterns and examples (copyable) to follow
- Navigation helper usage (preferred):

  Navigation.navigateToInPersonAttendance(context: context, onExit: () { /* ... */ });

- Persisting user signup details (follow pattern in `AuthViewModel.saveDetailsToCache`):
  - Use `SharedPreferences.getInstance()` and `Future.wait([...])` for parallel writes.

- Mocking services in tests: add a `MockAttendanceService` implementation next to the
  real service in `lib/platform/services/` as shown in `attendance_service.dart`.

Files & directories you should read for domain knowledge
- `lib/main.dart` — startup wiring
- `lib/ux/shared/view_models/` — app state and caching patterns
- `lib/platform/services/` — attendance, location, face verification service interfaces
- `lib/ux/navigation/` — navigation helpers and host page
- `lib/ux/views/attendance/` — multi-step UI and permission dialogs (important for flows)
- `pubspec.yaml` — declared packages and flutter assets

When changing or adding features, small checklist
1. Update or add keys in `lib/ux/shared/resources/app_constants.dart` if you add persisted keys.
2. If new platform capability is required, add dependency in `pubspec.yaml` and update Android/iOS
   manifest/entitlements as needed (this repo has native folders already).
3. Use existing Provider-based view models for state; register them in `main.dart` if app-scoped.
4. Use `Navigation` helpers for routing.
5. Run `flutter analyze` and `flutter test` before committing.

Merge policy for existing copilot instructions
- If this repository later adds its own `.github/copilot-instructions.md`, merge preserving
  any repo-specific bullet points. Prefer the most specific commands (exact filenames or
  config values) when conflicts arise.

If something is missing in these notes (secrets, CI, or native manifest changes) ask the
human maintainer rather than guessing. After editing, run `flutter analyze` and `flutter test`.

Null-safety, code issues & naming suggestions
- Null-safety guidance (preferred style): prefer using null-aware defaults and explicit guards
  instead of the null-assertion operator (`!`). Prefer patterns like:
  - Use `value ?? fallback` when a sensible fallback exists.
  - Prefer early-return guards:
    ```dart
    final formState = formKey.currentState;
    if (formState == null || !formState.validate()) return;
    ```
  - When a variable should never be null, prefer stronger typing or construct it earlier
    rather than forcibly asserting at use-sites.

- Why: Using `??` or explicit guards lets static analysis and automated agents locate
  possible null flows and suggest fixes; `!` silences the analyzer and hides risky locations.

- Examples found in the codebase (fix these patterns):
  - `lib/ux/views/onboarding/sign_up_page.dart` — `formKey.currentState!.validate()`
    Suggestion: cache `final formState = formKey.currentState; if (formState == null || !formState.validate()) return;`
  - `lib/ux/views/attendance/components/face_verification_content.dart` — `CameraPreview(cameraController!)`
    Suggestion: guard earlier when `isCameraInitialized` is true, or pass a non-null controller via constructor, or show a placeholder when null: `cameraController ?? cameraFallback`.
  - `lib/ux/shared/message_providers.dart` — `locationState.verificationStatus!` (TODO comment present)
    Suggestion: use `locationState.verificationStatus ?? LocationVerificationStatus.failed` or add an `if (verificationStatus == null)` branch.
  - `lib/ux/shared/view_models/attendance_view_model.dart` — `await submitAttendance(result.currentPosition!); //TODO: change this null check`
    Suggestion: check `if (result.currentPosition == null) { _locationError = 'No position'; return false; }` or pass an explicit fallback.

- Other concrete code issues that need attention
  - `lib/ux/shared/message_providers.dart` contains an invalid `switch` case:
    `case LocationVerificationStatus.successInRange || LocationVerificationStatus.outOfRange:`
    That's not valid Dart for multiple cases. Use separate `case` lines or a `default` with if checks.
  - `lib/ux/shared/view_models/attendance_view_model.dart` has a typo: `'longtitude'` -> should be `'longitude'` in `submitAttendance` map. Fix textual keys and any downstream parsing/consumers.

- Naming & file-structure suggestions
  - Duplicate/odd filename: `lib/ux/shared/models/models.dart.dart` looks like a mistaken double extension. Rename to `models.dart` and update imports.
  - Keep mock implementations next to interfaces but with clear suffixes: e.g. `attendance_service.dart` (interface) + `attendance_service_mock.dart` (mock). Current `MockAttendanceService` is fine but consider moving into `attendance_service_mock.dart` for clarity.
  - Consistent pluralization: prefer `services` directory for platform adapters (already used) and `view_models` for ChangeNotifier classes — keep those conventions.
  - Typos and naming consistency: search for `longtitude`, `verfication`, or similar misspellings and normalize to `longitude`, `verification`.

- Suggested quick automated checks to run now
  - Run `flutter analyze` and fix analyzer errors/warnings.
  - Search for `!` assertions: run a repo-wide search for `!` and review each occurrence.
  - Search for duplicated filenames: `rg "models\.dart\.dart" -n` and rename appropriately.

If you'd like, I can prepare a small PR that:
- Replaces the obvious `!` usages with guarded checks (one change per file, with tests)
- Fixes the `models.dart.dart` filename and updates imports
- Fixes the `longtitude` typo and the invalid `switch` case in `message_providers.dart`

Tell me if you want me to make those code changes now; I can implement them one-by-one and run `flutter analyze` / `flutter test` after each change.

-- End of file

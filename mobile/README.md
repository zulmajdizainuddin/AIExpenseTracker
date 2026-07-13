# AI Expense Tracker — Mobile

Flutter client for the [AI Expense Tracker + Receipt Scanner](../README.md) project. Riverpod for state management, Dio for networking, GoRouter for navigation, fl_chart for the dashboard.

See the [root README](../README.md) for the project overview and the [backend README](../backend/README.md) for the Laravel API.

## Requirements

* [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart SDK `>=3.3.0 <4.0.0`, see `pubspec.yaml`)
* The backend running locally — see [backend/README.md](../backend/README.md)
* A target to run on: an Android emulator, a physical Android device, or a browser (Chrome/Edge)

## Setup

```bash
flutter pub get
```

## Configuring the API URL

`AppConstants.baseUrl` (`lib/core/constants/app_constants.dart`) defaults to `http://10.0.2.2:8000/api/v1` — the special alias an **Android emulator** uses to reach `localhost` on the host machine. For any other target, override it at launch with `--dart-define` instead of editing the file:

| Target | Command |
|---|---|
| Android emulator | `flutter run` *(no flag needed — this is the default)* |
| Physical Android device (USB) | `adb reverse tcp:8000 tcp:8000` once, then `flutter run -d <device-id> --dart-define=API_BASE_URL=http://127.0.0.1:8000/api/v1` |
| Chrome / Edge / Windows desktop | `flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:8000/api/v1` |

Run `flutter devices` to list available targets and their IDs.

## Running

```bash
flutter run -d <device-id>
```

## Testing

```bash
flutter test
```

## Static analysis

```bash
flutter analyze
```

# fixit

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Backend URL overrides

You can override the API base URL at build/run time. This is useful for
connecting a physical device to the backend running on your machine.

Examples:
```
flutter run --dart-define=API_HOST=192.168.0.123
```

```
flutter run --dart-define=API_BASE_URL=http://192.168.0.123:8080
```

Or use a `.env` file (loaded at app start):
```
API_HOST=192.168.0.123
API_PORT=8080
```

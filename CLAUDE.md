# JumpaSini Mobile App — Flutter (Android)

This is the Flutter Android app for JumpaSini.

## Responsibilities

- Location input (manual address or GPS)
- Transport mode selection
- Venue results display with filtering
- Collaborative planning UI
- Google Maps Flutter SDK rendering (map display only — data comes from backend)

## Critical Rule

**All API calls go to the Laravel backend.** Never call Google APIs, Google Places, or any external API directly from this app. The backend proxies everything.

## Coding Standards

- Use **BLoC pattern** for all state management (`flutter_bloc` package)
- Follow the **Dart style guide** and Flutter best practices
- Separate UI, BLoC, repository, and data source layers
- Use `Equatable` for BLoC states and events
- No business logic in widgets — widgets are pure UI
- Use `dio` or `http` package for HTTP calls; wrap in a repository class

## Target Platform

- **Android only** (no iOS target for now)
- **Min SDK: Android 8.0 (API level 26)**
- Test on emulator API 26+ and a physical device before marking features done

## Project Structure

```
lib/
  core/
    api/            — HTTP client, base repository
    utils/
  features/
    session/
      bloc/
      data/
      ui/
    venues/
      bloc/
      data/
      ui/
    map/
      ui/
  shared/
    widgets/
```

## Environment

- Flutter (latest stable)
- Dart 3+
- Android SDK

# JumpaSini Mobile App

## Overview

Flutter Android app for **JumpaSini** — helps groups of friends find the fairest meetup spot in Klang Valley, Malaysia. Enter everyone's starting location, pick a venue type, and the app calculates the geographic midpoint with travel-time balancing, then surfaces the best nearby venue for the whole group.

---

## Tech Stack

| | |
|---|---|
| Framework | Flutter 3.41.9 (stable channel) |
| Language | Dart |
| Platform | Android only (MVP) |
| Minimum SDK | Android API 26 (Android 8.0) |
| State management | BLoC pattern — `flutter_bloc ^8.1.6` |
| HTTP client | Dio |
| Dependency injection | `get_it` |
| Maps | `google_maps_flutter` |
| Places autocomplete | `flutter_google_places_sdk` |
| Location | `geolocator` |
| Sharing | `share_plus` |
| Confetti | `confetti` |

---

## Architecture

Clean Architecture with three layers per feature:

```
features/<name>/
  data/         Models, remote datasources, repository implementations
  domain/       Entities, abstract repository interfaces, use cases
  presentation/ BLoC (events / states / bloc), pages, widgets
```

**Feature folders:**

| Feature | Responsibility |
|---|---|
| `features/session/` | Session creation, participant management, location input |
| `features/venue/` | Venue discovery, recommendation screen, map view |
| `features/collaboration/` | Voting, session confirmation, summary page, share flow |

**Core:**

```
lib/core/
  constants/    API URLs, app strings, colours
  di/           GetIt injection container (injection_container.dart)
  errors/       Failure types, exception mapping
  network/      Dio client + interceptors
  utils/        Validators
```

---

## Modules Built

| # | Module | Status |
|---|---|---|
| 1 | Session + Location Input | ✅ Complete |
| 2 | Midpoint Calculation (via API) | ✅ Complete |
| 3 | Venue Discovery + Halal Filter | ✅ Complete |
| 4 | Results & Recommendation UI | ✅ Complete |
| 5 | Collaborative Planning + Shareable Link | ✅ Complete |
| 6 | Weather Awareness | Planned |
| 7 | Admin Panel | N/A — web only |

---

## Key Features

- **Start a meetup** — select transport mode (car / public transport), venue type (mall, restaurant, cafe, park, beach, waterfall, river), and halal filter
- **Add up to 6 participants** with Google Places autocomplete restricted to Malaysia
- **Fair midpoint calculation** with travel-time balancing — the API adjusts the midpoint until no single participant bears a disproportionate travel burden
- **Best Pick recommendation** with a fairness score displayed as a percentage progress bar
- **Per-participant travel time** shown on every venue card and in the recommendation screen
- **Halal filter** with JAKIM-verified badge on qualifying venues
- **Crowd-source halal reporting** — users can flag or confirm halal status
- **Collaborative voting** — thumbs up / down on any venue; live vote tally with progress bars
- **Confetti animation** on meetup confirmation
- **Shareable session code** — 8-character code + native share sheet
- **Join existing session** via short code from the home screen
- **Debug test location buttons** (KLCC, Subang Jaya, PJ) — visible only in debug builds (`kDebugMode`)

---

## Local Setup

```bash
# 1. Clone the repo
git clone <repo-url>
cd JumpaSini-Mobile-App

# 2. Verify Flutter version
flutter --version
# Should report Flutter 3.41.x, stable channel

# 3. Install dependencies
flutter pub get

# 4. Add your Google Maps API key to AndroidManifest.xml
#    File: android/app/src/main/AndroidManifest.xml
#    Inside <application>:
#
#    <meta-data
#        android:name="com.google.android.geo.API_KEY"
#        android:value="YOUR_KEY_HERE"/>

# 5. Start the Laravel backend
cd ../JumpaSini-Backend
php artisan serve

# 6. Run on emulator (Android API 26+)
cd ../JumpaSini-Mobile-App
flutter run
```

> **Emulator note:** The API base URL defaults to `http://10.0.2.2:8000/api/v1`, which maps to `localhost:8000` on the host machine when running in an Android emulator.

---

## Required Google APIs

Enable all of the following in [Google Cloud Console](https://console.cloud.google.com/):

| API | Used by |
|---|---|
| Maps SDK for Android | In-app map rendering |
| Places API | Address autocomplete (participant location input) |
| Distance Matrix API | Travel time calculation — **backend only** |
| Geocoding API | Address resolution — **backend only** |

> The Distance Matrix and Geocoding APIs are called exclusively by the Laravel backend. The mobile app never calls Google APIs directly.

---

## Environment / Configuration

The API base URL is configured in one place:

```
lib/core/constants/api_constants.dart
```

Change `baseUrl` before building for production. All other endpoints are derived from this constant.

---

## Building

```bash
# Debug APK (includes test location buttons)
flutter build apk --debug

# Release APK
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-debug.apk` or `app-release.apk`

---

## Navigation Flow

```
HomePage
├── Start a Meetup
│     └── SetupPage (transport mode + venue type + halal filter)
│           └── AddParticipantsPage (add 1–6 locations)
│                 └── SessionPage (triggers midpoint calculation)
│                       └── RecommendationPage (best pick + vote buttons + fairness score)
│                             ├── SessionSummaryPage (session code + share + confirm)
│                             └── VenuesPage (all venues on map — optional)
│
└── Join Session (enter 8-char code)
      └── SessionSummaryPage (live session state + vote tally + confirm button)
```

---

## Known Issues & Notes

- Google Places autocomplete requires a valid API key with the **Places API** enabled; without it the address field will not return suggestions
- Debug test location buttons (KLCC / Subang Jaya / PJ) are gated behind `kDebugMode` and do not appear in release builds
- The halal toggle currently renders for all venue types — it should only show for restaurant and cafe; fix planned before beta
- Weather warnings are pending Module 6 implementation

---

## Related Repos

| Repo | Stack | Purpose |
|---|---|---|
| `JumpaSini-Backend` | Laravel 11 | REST API — all business logic and external API calls |
| `JumpaSini-Frontend-Dashboard` | Angular 17+ | Web shareable-link landing page and session view |

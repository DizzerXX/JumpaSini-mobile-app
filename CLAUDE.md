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
- Use `dio` for HTTP calls; wrap in a repository class
- **Repositories return `Either<Failure, T>` (dartz) — never throw across the domain
  boundary.** Data sources throw the exceptions in `core/errors/exceptions.dart`;
  repositories translate them to `core/errors/failures.dart`; blocs use `.fold(...)`.
- **One bloc per concern.** Do not emit unrelated states (e.g. weather) into another
  bloc's state — mutually exclusive states mean the last emit wipes the previous one,
  which forces widgets to keep shadow copies. Weather has its own `WeatherBloc`.
- Identity: the backend issues a per-participant `access_token` once, on join.
  `ParticipantIdentityStore` persists it per session; voting and leaving both require it.

## Target Platform

- **Android only** (no iOS target for now)
- **Min SDK: Android 8.0 (API level 26)**
- Test on emulator API 26+ and a physical device before marking features done

## Project Structure

Clean architecture per feature — `domain` (entities, repository contracts, usecases)
has no dependency on `data` or `presentation`; `data` implements the domain contracts
against the backend; `presentation` holds the BLoC + widgets. Wiring lives in
`core/di/injection_container.dart` (`get_it`) and is what actually decides what's live —
if a file isn't reachable from there, don't build on it.

```
lib/
  core/
    network/          — ApiClient (dio), request/response → typed exceptions
    di/                — get_it service locator (injection_container.dart)
    errors/            — exceptions.dart (data layer) / failures.dart (domain layer)
    constants/
    utils/
  features/
    session/
      domain/           — entities, SessionRepository contract, usecases
      data/             — datasources, models, SessionRepository impl
      presentation/      — bloc/, pages/, widgets/
    venue/
      domain/ data/ presentation/   — same shape
    collaboration/
      domain/ data/ presentation/   — voting, confirmation, session summary
  shared/
    widgets/
```

Each feature is wired end-to-end in `injection_container.dart` — when adding a new
feature, register its datasource → repository → usecases → bloc there, following the
existing `session`/`venue`/`collaboration` blocks as the template.

## Environment

- Flutter (latest stable)
- Dart 3+
- Android SDK

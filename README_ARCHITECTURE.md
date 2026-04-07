# MyFolio Flutter App

A personal portfolio Flutter application built with clean architecture principles.

## Features

- Clean Architecture with separation of concerns
- Web support enabled
- State management with BLoC
- Dependency injection with GetIt
- Type-safe networking with Dio
- Local storage with Hive and SharedPreferences
- Modern Material 3 design
- Dark/Light theme support

## Project Structure

```
lib/
core/                     # Core utilities and shared components
  constants/             # App constants
  exceptions/           # Custom exceptions
  network/              # Network service
  utils/                # Utility functions
  di/                   # Dependency injection

data/                    # Data layer
  datasources/          # Remote and local data sources
  models/               # Data models
  repositories/         # Repository implementations

domain/                  # Domain layer
  entities/             # Business entities
  repositories/         # Repository interfaces
  usecases/             # Business use cases

presentation/            # Presentation layer
  pages/                # Screen widgets
  widgets/              # Reusable widgets
  providers/            # State management (BLoC)
  routes/               # Navigation configuration

shared/                  # Shared components
  theme/                # App themes
  widgets/              # Shared widgets
  extensions/           # Dart extensions
```

## Getting Started

### Prerequisites

- Flutter SDK (>= 3.7.2)
- Dart SDK
- An IDE (VS Code, Android Studio, etc.)

### Installation

1. Clone the repository
2. Navigate to the project directory
3. Install dependencies:
   ```bash
   flutter pub get
   ```

### Running the App

For development:
```bash
flutter run
```

For web:
```bash
flutter run -d chrome
```

For build:
```bash
flutter build web
```

### Code Generation

This project uses code generation for:
- JSON serialization
- Freezed data classes
- Retrofit API clients
- Dependency injection

Run code generation:
```bash
flutter packages pub run build_runner build
```

For automatic updates during development:
```bash
flutter packages pub run build_runner watch
```

## Architecture

### Clean Architecture

The app follows clean architecture principles with three main layers:

1. **Domain Layer**: Contains business logic, entities, and use cases
2. **Data Layer**: Handles data sources, models, and repository implementations
3. **Presentation Layer**: Manages UI, state, and navigation

### State Management

Uses BLoC pattern for predictable state management:
- **Events**: User actions and system events
- **States**: UI states based on events
- **BLoC**: Manages the flow from events to states

### Dependency Injection

Uses GetIt with Injectable for:
- Service registration
- Automatic dependency resolution
- Testability and modularity

## Key Packages

- `flutter_bloc`: State management
- `go_router`: Navigation
- `dio`: HTTP client
- `retrofit`: Type-safe API clients
- `get_it`: Dependency injection
- `hive`: Local database
- `shared_preferences`: Simple key-value storage
- `freezed`: Immutable data classes
- `json_annotation`: JSON serialization

## Development

### Code Style

Follows the official Flutter style guide with:
- `very_good_analysis` lint rules
- Consistent formatting with Prettier
- Type safety wherever possible

### Testing

Run tests:
```bash
flutter test
```

Run tests with coverage:
```bash
flutter test --coverage
```

## Build and Deployment

### Web Build

```bash
flutter build web --web-renderer canvaskit
```

### APK Build

```bash
flutter build apk --release
```

### iOS Build

```bash
flutter build ios --release
```

## Environment Variables

Create a `.env` file in the root directory:

```env
API_BASE_URL=https://api.myfolio.com/api/v1
API_TIMEOUT=30000
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests and ensure they pass
5. Submit a pull request

## License

This project is private and not licensed for public distribution.

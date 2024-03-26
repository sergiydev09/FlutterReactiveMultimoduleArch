# Flutter Architecture Base (flutter_arch)

## Description

Explore the essence of simplicity with our Flutter app, a showcase of a straightforward, maintainable, and scalable architecture designed to streamline development processes and foster innovation. This project serves as a pre-built architectural foundation for new Flutter projects, emphasizing modularity, ease of use, extensibility, and efficient management through dependency injection.

## Features

- **Modular Architecture**: Organizes the app into independent features, core functionalities, and resources, facilitating easy addition and updating.
- **Dependency Injection**: Utilizes `get_it` and `injectable` for efficient dependency management, allowing for better testing and decoupling of components.

## Modular Architecture

Our architecture is built around the concept of modularity, allowing for easy addition, modification, and removal of features without affecting the core functionality. Here's a breakdown of the modular structure:

### Dependencies

- **Core Flutter**
    - `flutter`
    - `flutter_localizations`

- **Libraries**
    - `res`: Resources like images, text, colors, themes. (Located at `libs/res`)
    - `arch`: Base support classes for architecture, including `feature_route.dart`, `state_notifier.dart`, `cache_data_source.dart`. (Located at `libs/arch`)

- **Features**
    - `home`: UI, Domain, and Data for the home screen feature. (Located at `feature/home`)
    - `detail`: UI, Domain, and Data for the detail screen feature. (Located at `feature/detail`)

### Third-Party Libraries

- `cupertino_icons: ^1.0.6`
- `intl: any`
- `flutter_lints: ^3.0.0`
- `get_it: ^7.6.7` - For dependency injection.
- `injectable: any` - Works alongside `get_it` for code generation and easier management of dependencies.
- `http: ^1.2.1`
- `crypto: ^3.0.3`
- `flutter_secure_storage: ^9.0.0`


### Development Dependencies

- `build_runner: ^2.4.8`
- `injectable_generator: any`

## Roadmap

- [x] Modular architecture implementation
- [x] CacheManager
- [x] FeatureRoute, implement mobileScreen or desktopScreen depent's on screen size
- [x] MVI architecture, using StateNotifier as Kotlin StateFlow
- [X] Api res calls (Marvel's public api)
- [x] Dependency injection setup
- [x] Multi-language strings support
- [ ] Authentication with social media
- [ ] Payment library (Stripe or Square)
- [ ] Documentation improvement

*Note: The roadmap is subject to change as the project evolves.*

## Getting Started

To get started with `flutter_arch`, clone the repository and ensure you have Flutter installed on your system. Follow these steps:

1. Clone the repository.
2. Navigate to the project directory.
3. Run `flutter pub get` to install dependencies.
4. Run DI `/bin/bash run_build_runner.sh` if you have bash
5. Run `flutter run` to start the app on a connected device or emulator.

## Contributing

Contributions are welcome! If you'd like to contribute, please fork the repository and use a feature branch. Pull requests are warmly welcome.

## License

Specify your project's license here.

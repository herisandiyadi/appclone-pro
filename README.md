# AppClone Pro

Multi-instance app cloning for Android — run multiple instances of one app in a single device with virtual container isolation.

> Built with **Flutter + Dart**, orchestrated end-to-end by Hermes Agent.

## Features (MVP)

- **App Cloning Engine** — virtual container per clone, process & storage isolation simulation
- **Dashboard** — grid view of clones with search, lock, hide, delete
- **Notification Handler** — intercept & forward notifications per clone with unread badge
- **Security** — PIN lock (SHA-256 hashed), biometric toggle, AES-style data encryption helper
- **Performance** — memory compression on pause, container kill on idle, per-clone storage stats

## Architecture

```
lib/
├── main.dart                  # Entry point + ProviderScope
├── core/
│   ├── engine/                # Cloning engine & virtual container simulation
│   ├── notification/          # NotificationHandler (per-clone streams)
│   ├── security/              # SecurityManager (PIN / biometric / encryption)
│   └── di/                    # Riverpod providers (DI)
├── data/
│   ├── model/                 # CloneApp, InstalledApp
├── domain/
│   └── usecase/               # (reserved for business logic)
└── presentation/
    ├── dashboard/             # Clone grid
    ├── appselect/             # App picker
    ├── cloning/               # Clone progress screen
    ├── settings/              # Settings
    ├── security/              # Security lock gate
    ├── theme/                 # Design tokens (DESIGN.md)
    └── widgets/               # Reusable widgets
```

## Getting Started

```bash
flutter pub get
flutter run
```

## Roadmap

- [x] MVP: clone, dashboard, notifications, security, performance
- [ ] Cloud backup & sync (P2)
- [ ] Automation & macros (P2)
- [ ] Multi-window mode (P2)
- [ ] Theme & customization (P3)

## License

MIT

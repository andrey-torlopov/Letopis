<p align="center">
  <img src="Docs/banner.png" alt="Letopis Logo" width="600"/>
</p>

<p align="center">
  <a href="https://swift.org">
    <img src="https://img.shields.io/badge/Swift-6.2-orange.svg?logo=swift" />
  </a>
  <a href="https://swift.org/package-manager/">
    <img src="https://img.shields.io/badge/SPM-compatible-green.svg" />
  </a>
  <img src="https://img.shields.io/badge/platforms-iOS%20%7C%20macOS%20%7C%20Linux-blue.svg" />
  <a href="LICENSE">
    <img src="https://img.shields.io/badge/license-MIT-lightgrey.svg" />
  </a>
</p>

# Letopis

*Read this in other languages: [Русский](README-ru.md)*

`Letopis` is a lightweight logging and tracing module that lets you describe application events through a declarative API and deliver them through a chain of interceptors. The package has no external dependencies, so it can be used from any layer of your codebase.

## Key Features

- **Unified logging entry point** — one facade for console, network, and analytics
- **Extensible architecture through interceptors** — flexible filtering and event routing
- **Flexible network traffic management** — smart buffering and prioritization
- **Adaptation to external conditions** — dynamic configuration without changing the core

## Quick Start

```swift
import Letopis

// Define event types
enum AppEventType: String, EventTypeProtocol {
    case userAction = "user_action"
    case apiCall = "api_call"
}

// Initialize logger
let logger = Letopis(
    interceptors: [ConsoleInterceptor()]
)

// Use it
logger
    .event(AppEventType.userAction)
    .payload(["screen": "profile"])
    .info("User opened profile screen")
```

## Documentation

- 📦 [Installation](Docs/en/installation.md)
- 🚀 [Quick Start](Docs/en/quick-start.md)
- 📖 [Full Documentation](Docs/en/index.md)

## Usage Examples

```swift
// Logging critical events
logger
    .event(.apiCall)
    .critical()
    .error("Network request failed")

// Masking sensitive data
logger
    .payload(["password": "secret123"])
    .sensitive()
    .info("User logged in")
```

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

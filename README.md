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

`Letopis` is a lightweight logging and tracing module that lets you describe application events through a simple and intuitive API. The package offers two approaches: a straightforward method-based API for everyday use, and an optional fluent DSL for more expressive scenarios. All events are delivered through a chain of interceptors with no external dependencies.

## Key Features

- **Simple and intuitive API** — straightforward methods (`info`, `warning`, `error`, etc.) for common logging tasks
- **Optional DSL syntax** — expressive fluent API available for advanced use cases
- **Unified logging entry point** — one facade for console, network, and analytics
- **Extensible architecture through interceptors** — flexible filtering and event routing
- **Flexible network traffic management** — smart buffering and prioritization
- **Adaptation to external conditions** — dynamic configuration without changing the core

## Quick Start

```swift
import Letopis

// Define event types (optional)
enum AppEventType: String, EventTypeProtocol {
    case userAction = "user_action"
    case apiCall = "api_call"
}

enum UserAction: String, EventActionProtocol {
    case screenOpen = "screen_open"
    case buttonTap = "button_tap"
}

// Initialize logger
let logger = Letopis(
    interceptors: [ConsoleInterceptor()]
)

// Simple usage - just log a message
logger.info("User opened profile screen")

// Add metadata with optional parameters
logger.info(
    "User opened profile screen",
    payload: ["screen": "profile", "user_id": "123"],
    eventType: AppEventType.userAction,
    eventAction: UserAction.screenOpen
)
```

## Documentation

- 📦 [Installation](Docs/en/installation.md)
- 🚀 [Quick Start](Docs/en/quick-start.md)
- 📖 [Full Documentation](Docs/en/index.md)

## Usage Examples

### Standard API (Recommended)

```swift
// Info logging
logger.info("Application started")

// Warning with metadata
logger.warning(
    "API rate limit approaching",
    payload: ["remaining": "10", "limit": "100"]
)

// Error logging (critical by default)
logger.error("Network request failed", eventType: .apiCall)

// Debug logging with source location
logger.debug("Cache hit", payload: ["key": "user_profile"], includeSource: true)
// Automatically captures file, function, and line number

// Analytics events
logger.analytics(
    "Purchase completed",
    payload: ["item_id": "12345", "price": "9.99"]
)
```

### Optional DSL API

For users who prefer a fluent, chainable syntax:

```swift
// Chaining methods with DSL
logger.log()
    .event(.apiCall)
    .payload(["endpoint": "/users"])
    .critical()
    .error("Network request failed")

// Masking sensitive data
logger.log()
    .payload(["password": "secret123"])
    .sensitive(keys: ["password"])
    .info("User logged in")

// Adding source code location
logger.log()
    .source()
    .debug("Variable value at this point")
```

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

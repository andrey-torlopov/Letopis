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

`Letopis` is a lightweight logging and tracing module that lets you describe application events through a simple and intuitive API. The package offers two approaches: an expressive fluent DSL for building rich, structured logs, and a straightforward method-based API for quick and simple logging. All events are delivered through a chain of interceptors with no external dependencies.

## Key Features

- **Expressive DSL syntax** — fluent builder API for creating rich, structured log events with metadata
- **Simple direct methods** — optional straightforward methods (`info`, `warning`, `error`, etc.) for quick logging
- **Unified logging entry point** — one facade for console, network, and analytics
- **Extensible architecture through interceptors** — flexible filtering and event routing
- **Flexible network traffic management** — smart buffering and prioritization
- **Adaptation to external conditions** — dynamic configuration without changing the core

## Changelog

### November 2025

**Breaking Change: Sensitive Data Masking**

Sensitive data masking is now **enabled by default** to prevent accidental leakage of passwords, API keys, and other sensitive information in logs.

- All keys configured in `sensitiveKeys` are automatically masked using the partial strategy
- To disable masking for a specific log event, explicitly call `.notSensitive()`
- Custom masking strategies can still be applied using `.sensitive(keys:strategy:)`

**Before (old behavior):**
```swift
// Data was NOT masked by default
logger.info("User logged in", payload: ["password": "secret123"])
// Output: password: "secret123" ⚠️ EXPOSED
```

**After (new behavior):**
```swift
// Data is masked by default if key is in sensitiveKeys
logger.info("User logged in", payload: ["password": "secret123"])
// Output: password: "sec***23" ✅ PROTECTED

// Explicitly disable masking when needed
logger.log()
    .payload(["password": "secret123"])
    .notSensitive()
    .info("Debug login flow")
// Output: password: "secret123" (only when explicitly requested)
```

**Migration:** If you relied on sensitive data being visible in logs, add `.notSensitive()` to those specific log calls. For production code, we strongly recommend keeping the default behavior.

## Quick Start

```swift
import Letopis

// Initialize logger
let logger = Letopis(
    interceptors: [ConsoleInterceptor()]
)

// Recommended: Use fluent DSL for expressive, structured logging
// Option 1: Use built-in domains and actions
logger.log()
    .domain(UserDomain.ui)
    .action(UserAction.click)
    .payload(["screen": "profile", "user_id": "123"])
    .info("User opened profile screen")

// Option 2: Use custom string-based domain and action
logger.log()
    .domain("auth")
    .action("login_success")
    .payload(["user_id": "123"])
    .info("User logged in successfully")

// Alternative: Simple direct call for quick logging
logger.info("User opened profile screen")
```

## Documentation

- 📦 [Installation](Docs/en/installation.md)
- 🚀 [Quick Start](Docs/en/quick-start.md)
- 📖 [Full Documentation](Docs/en/index.md)

## Usage Examples

### DSL API (Recommended)

The fluent builder pattern provides expressive, chainable syntax for rich logging:

```swift
// Basic logging with domain and action
logger.log()
    .domain(NetworkDomain.api)
    .action(NetworkAction.start)
    .payload(["endpoint": "/users"])
    .info("API request started")

// Critical error with full context
logger.log()
    .domain(NetworkDomain.network)
    .action(NetworkAction.failure)
    .payload(["endpoint": "/users"])
    .critical()
    .error("Network request failed")

// Analytics with structured data using string-based domain/action
logger.log()
    .domain("purchase")
    .action("completed")
    .payload(["item_id": "12345", "price": "9.99"])
    .info("Purchase completed")

// Debug with source location
logger.log()
    .source()
    .payload(["cache_key": "user_profile"])
    .debug("Cache hit")
// Automatically captures file, function, and line number

// Sensitive data is masked by default (November 2025+)
// Configure sensitive keys when creating logger
let logger = Letopis(
    interceptors: [ConsoleInterceptor()],
    sensitiveKeys: ["password", "token", "api_key"]
)

logger.log()
    .payload(["password": "secret123", "username": "john"])
    .info("User logged in")
// Output: password=s***3, username=john
```

### Direct Methods API (Optional)

For quick, simple logging without metadata:

```swift
// Simple messages
logger.info("Application started")
logger.warning("API rate limit approaching")
logger.error("Network request failed")
logger.debug("Cache hit")
logger.analytics("Purchase completed")

// With basic payload
logger.info(
    "User logged in",
    payload: ["user_id": "123"]
)
```

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

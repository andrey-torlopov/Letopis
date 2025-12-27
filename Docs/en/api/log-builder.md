# Log Builder API (DSL) — Recommended

The `Log` builder provides a fluent interface for constructing rich, structured log events with metadata. This is the **recommended approach** for most logging scenarios in Letopis.

## Why Use the DSL?

- **Expressive and readable** — Chain methods to build complex log events naturally
- **Type-safe metadata** — Leverage protocol-based event types and actions
- **Rich context** — Easily attach payloads, source location, and priority
- **Flexible masking** — Fine-grained control over sensitive data

## Methods

### `domain(_:)`

Set the business domain or subsystem for the event.

- Accepts any type conforming to `DomainProtocol` or a string literal

```swift
logger.log()
    .domain(NetworkDomain.api)
    .info("API request started")

// Or with string
logger.log()
    .domain("auth")
    .info("Authentication event")
```

### `action(_:)`

Set the specific action within the domain.

- Accepts any type conforming to `ActionProtocol` or a string literal

```swift
logger.log()
    .action(NetworkAction.success)
    .info("Request successful")

// Or with string
logger.log()
    .action("login_success")
    .info("User logged in")
```

### `event(domain:action:)`

Set both domain and action together.

```swift
logger.log()
    .event(domain: NetworkDomain.api, action: NetworkAction.start)
    .info("API call initiated")

// Or with strings
logger.log()
    .event(domain: "payment", action: "completed")
    .info("Payment processed")
```

### `payload(_:)`

Merge additional key-value pairs into the event payload.

```swift
logger
    .event(.apiCall)
    .payload(["endpoint": "/api/users", "method": "GET"])
    .info("API request started")
```

### `critical()`

Mark the event as critical, requiring immediate attention.

```swift
logger
    .event(.payment)
    .critical()
    .error("Payment processing failed")
```

### `source(file:function:line:)`

Record call-site information in the payload. By default uses `#file`, `#function`, and `#line`.

```swift
logger
    .source()
    .info("Debug information with source location")
```

### `sensitive(keys:strategy:)` / `sensitive(key:strategy:)`

Apply custom masking strategies to specific keys in the payload.

> **Note:** As of November 2025, masking is **enabled by default** for all globally configured sensitive keys. This method is used to apply custom strategies or mask additional keys not in the global list.

```swift
// Apply custom strategies to specific keys
logger
    .payload(["email": "user@example.com", "card": "1234-5678"])
    .sensitive(key: "email", strategy: .email)
    .sensitive(key: "card", strategy: .last4)
    .info("Payment processed")

// Mask multiple keys with same strategy
logger
    .payload(["token": "abc123", "api_key": "xyz789"])
    .sensitive(keys: ["token", "api_key"], strategy: .full)
    .info("Auth completed")
```

### `notSensitive()`

Disable automatic masking for this specific log event.

> **Warning:** Use only in development/debugging. Production logs should keep default masking enabled.

```swift
// Disable masking to see raw values during debugging
logger
    .payload(["password": "secret123", "token": "abc123"])
    .notSensitive()
    .debug("Debug auth flow")
// Output: password=secret123, token=abc123 (unmasked)
```

### Terminal Methods

These methods set the event type, message, and immediately dispatch the event:

- `info(_:)` - Log informational message
- `warning(_:)` - Log warning message
- `error(_:)` or `error(_ error: Error, ...)` - Log error
- `debug(_:)` - Log debug message
- `analytics(_:)` - Log analytics event

```swift
logger.event(.userAction).info("User logged in")
logger.event(.system).warning("Low memory")
logger.event(.error).critical().error("Network failed")
logger.event(.debug).debug("Cache updated")
logger.event(.analytics).analytics("Purchase completed")
```

## Example Usage

```swift
// Simple log
logger.log().info("App started")

// With domain and action
logger.log()
    .domain(UserDomain.ui)
    .action(UserAction.click)
    .info("User tapped checkout button")

// Critical error with source info
logger.log()
    .domain("payment")
    .action("timeout")
    .source()
    .critical()
    .error("Payment gateway timeout")

// With payload
logger.log()
    .domain("purchase")
    .action("completed")
    .payload(["amount": "99.99", "currency": "USD"])
    .info("Purchase successful")

// Using built-in domains
logger.log()
    .domain(NetworkDomain.api)
    .action(NetworkAction.success)
    .payload(["endpoint": "/users"])
    .info("API request completed")
```

---

[Back to Documentation Index](../index.md)

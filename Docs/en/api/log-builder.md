The `Log` builder provides a fluent interface for constructing log events.

## Methods

### `action(_:)`

Set the semantic action for the event.

- Accepts any type conforming to `EventActionProtocol` or a string literal

```swift
logger.action("user_click").info("Button pressed")
```

### `event(_:)`

Set the event type.

- Accepts any type conforming to `EventTypeProtocol` or a string literal

```swift
logger.event(AppEventType.userAction).info("Screen opened")
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

### `sensitive()` / `sensitive(keys:strategy:)`

Enable masking for sensitive data in the payload.

```swift
logger
    .payload(["email": "user@example.com", "card": "1234-5678"])
    .sensitive(keys: ["email", "card"])
    .info("Payment processed")
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

// With event type and action
logger
    .event("user_action")
    .action("button_tap")
    .info("User tapped checkout button")

// Critical error with source info
logger
    .event("payment")
    .source()
    .critical()
    .error("Payment gateway timeout")

// Analytics with payload
logger
    .event("purchase")
    .action("completed")
    .payload(["amount": "99.99", "currency": "USD"])
    .analytics("Purchase successful")
```

---

[Back to Documentation Index](../index.md)

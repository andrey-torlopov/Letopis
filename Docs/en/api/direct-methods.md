# Direct Logging Methods

If the builder is overkill, call the facade methods directly.

## Available Methods

All methods accept optional `payload`, `eventType`, and `eventAction` arguments that are merged into the final payload.

### `info(_:priority:payload:eventType:eventAction:)`

Log informational messages:

```swift
logger.info(
    "Purchase completed successfully",
    priority: .critical,
    payload: ["product_id": "premium_plan", "amount": "9.99", "currency": "USD"],
    eventType: .analytics,
    eventAction: .purchase
)
```

### `warning(_:priority:payload:eventType:eventAction:)`

Log warnings:

```swift
logger.warning(
    "API rate limit approaching",
    payload: ["remaining_requests": "10", "reset_time": "60s"]
)
```

### `error(_:priority:payload:eventType:eventAction:)`

Log error messages or Error objects:

```swift
// With string
logger.error(
    "Network request failed",
    priority: .critical,
    payload: ["url": "https://api.example.com/data", "status_code": "404"],
    eventType: .error,
    eventAction: .networkFailure
)

// With Error object
do {
    try riskyOperation()
} catch {
    logger.error(error, priority: .critical)
}
```

### `debug(_:priority:payload:eventType:eventAction:)`

Log debug information:

```swift
logger.debug(
    "Cache state",
    payload: ["entries": "150", "size": "2.5MB"]
)
```

### `analytics(_:priority:payload:eventType:eventAction:)`

Log analytics events:

```swift
logger.analytics(
    "User signed up",
    payload: ["source": "email", "plan": "free"],
    eventType: .analytics
)
```

## When to Use Direct Methods

Direct methods are useful when:
- You need to log a simple message quickly
- You don't need the flexibility of the builder
- You're migrating from another logging system
- Performance is critical (slightly less overhead)

---

[Back to Documentation Index](../index.md)

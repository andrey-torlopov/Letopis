# Adoption Tips

## Consistency

### Keep payload keys consistent
Use the same keys across interceptors:
- `event_type`
- `event_action`
- `source_*` (source_file, source_function, source_line)

```swift
// Good
logger.payload(["event_type": "user_action", "event_action": "login"])

// Avoid
logger.payload(["type": "user_action", "action": "login"])
```

## Type Safety

### Use enums for event types and actions

```swift
// Good
enum AppEventType: String, EventTypeProtocol {
    case userAction = "user_action"
    case apiCall = "api_call"
}

logger.event(AppEventType.userAction)

// Avoid
logger.event("user_action") // String literals are error-prone
```

## Modularity

### Separate interceptor implementations

Place concrete interceptors in separate modules:

```
MyApp/
├── Logging/
│   ├── Interceptors/
│   │   ├── ConsoleInterceptor.swift
│   │   ├── NetworkInterceptor.swift
│   │   ├── AnalyticsInterceptor.swift
│   │   └── FileInterceptor.swift
│   └── Logger.swift
```

This improves:
- Testability
- Maintainability
- Reusability

## Configuration

### Centralize logger setup

```swift
// LoggerFactory.swift
enum LoggerFactory {
    static func createLogger(environment: Environment) -> Letopis {
        switch environment {
        case .development:
            return Letopis(interceptors: [
                ConsoleInterceptor()
            ])
        case .staging:
            return Letopis(interceptors: [
                ConsoleInterceptor(logTypes: [.error]),
                NetworkInterceptor(baseURL: "https://staging-api.com")
            ])
        case .production:
            return Letopis(interceptors: [
                ConsoleInterceptor(logTypes: [.error]),
                NetworkInterceptor(baseURL: "https://api.com"),
                AnalyticsInterceptor(),
                CrashlyticsInterceptor()
            ])
        }
    }
}
```

## Performance

### Use appropriate log levels

```swift
// Good - only in development
#if DEBUG
logger.debug("Cache state: \(cache)")
#endif

// Good - always log errors
logger.error("Fatal error", isCritical: true)
```

### Avoid expensive operations in payloads

```swift
// Bad
logger.info("Data processed", payload: ["data": expensiveSerialize(data)])

// Good
logger.info("Data processed", payload: ["count": data.count])
```

## Security

### Always mask sensitive data

```swift
let logger = Letopis(
    interceptors: [...],
    sensitiveKeys: ["password", "token", "api_key", "credit_card"]
)

logger
    .payload(["password": "secret123"])
    .sensitive()
    .info("User logged in")
```

## Migration

### Gradual migration from existing loggers

```swift
// Old code
print("User logged in")
NSLog("Error: %@", error.localizedDescription)

// Step 1: Wrap existing logging
logger.info("User logged in")
logger.error(error)

// Step 2: Add metadata
logger
    .payload(["user_id": user.id])
    .info("User logged in")

// Step 3: Add event types
logger
    .event(AppEventType.authentication)
    .payload(["user_id": user.id])
    .info("User logged in")
```

## Documentation

### Document your event taxonomy

Create a document describing:
- Available event types
- When to use each type
- Standard payload keys
- Priority guidelines

Example:

```markdown
# Event Types

## user_action
Use for user-initiated actions
- Payload: `user_id`, `screen`, `action`
- Priority: `.default`

## error
Use for error conditions
- Payload: `error_code`, `error_message`
- Priority: `.critical`
```

---

[Back to Documentation Index](../index.md)

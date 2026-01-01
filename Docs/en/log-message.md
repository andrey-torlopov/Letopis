# LogMessage - Simple Logging API

`LogMessage` provides the simplest possible interface for logging through Letopis. Just create an object with parameters and the event is automatically sent.

## Philosophy

Unlike method-based APIs or DSL builders, `LogMessage` follows the principle "create object = send event". This is similar to the `Mayday()` pattern - just fill in the parameters and you're done.

## Quick Start

### 1. Configure at App Startup

```swift
import Letopis

// In AppDelegate or @main
LogDispatcher.configure(with: Letopis(
    interceptors: [ConsoleInterceptor()],
    healthCheckInterval: 30.0,
    sensitiveKeys: ["password", "token", "apiKey"]
))
```

### 2. Use in Your Code

```swift
// Simple logging - just severity and message
LogMessage(.debug, "Application started")
LogMessage(.info, "User session initialized")

// With domain and action
LogMessage(.notice, "User logged in",
    domain: CommonDomain.auth,
    action: CommonAction.loggedIn
)

// With all parameters
LogMessage(.info, "Payment processed",
    domain: CommonDomain.business,
    action: CommonAction.completed,
    payload: ["amount": "99.99", "currency": "USD", "user_id": "12345"]
)

// Critical event
LogMessage(.error, "Network request failed",
    domain: CommonDomain.network,
    action: CommonAction.failed,
    isCritical: true,
    payload: ["url": "https://api.example.com"]
)

// Logging errors
let error = NSError(domain: "com.app", code: 404)
LogMessage(.error, error,
    domain: CommonDomain.api,
    action: CommonAction.errorOccurred
)
```

## Available Parameters

### Required
- `severity: LogSeverity` - Log level (`.debug`, `.info`, `.notice`, `.warning`, `.error`, `.fault`)
- `message: String` - Message, or `error: Error` for logging errors

### Optional (with default values)
- `domain: DomainProtocol = DefaultDomain.empty` - Domain/subsystem
- `action: ActionProtocol = DefaultAction.empty` - Action
- `purpose: LogPurpose = .operational` - Event purpose
- `isCritical: Bool = false` - Event criticality
- `payload: [String: String] = [:]` - Additional data
- `correlationID: UUID? = nil` - ID for linking events

## Log Levels (LogSeverity)

```swift
LogMessage(.debug, "Detailed debug info")      // Debug information
LogMessage(.info, "Informational message")     // Informational message
LogMessage(.notice, "Notable event")           // Notable event
LogMessage(.warning, "Warning condition")      // Warning
LogMessage(.error, "Error occurred")           // Error
LogMessage(.fault, "System fault")             // Critical system fault
```

## Custom Domains and Actions

```swift
// Define your types
enum PaymentDomain: String, DomainProtocol {
    case payments
    var value: String { rawValue }
}

enum PaymentAction: String, ActionProtocol {
    case initiated = "payment_initiated"
    case processing = "payment_processing"
    case succeeded = "payment_succeeded"
    case failed = "payment_failed"
    var value: String { rawValue }
}

// Use them
LogMessage(.info, "Payment initiated",
    domain: PaymentDomain.payments,
    action: PaymentAction.initiated,
    payload: ["amount": "149.99"]
)

LogMessage(.notice, "Payment succeeded",
    domain: PaymentDomain.payments,
    action: PaymentAction.succeeded,
    payload: ["transaction_id": "txn_123456"]
)
```

## Real-World Examples

### User Authentication
```swift
LogMessage(.info, "User authentication started",
    domain: CommonDomain.auth,
    action: CommonAction.started
)

LogMessage(.notice, "User credentials validated",
    domain: CommonDomain.auth,
    action: CommonAction.validated
)

LogMessage(.notice, "User logged in",
    domain: CommonDomain.auth,
    action: CommonAction.loggedIn,
    payload: ["user_id": "usr_12345", "method": "password"]
)
```

### Network Requests
```swift
LogMessage(.debug, "API request initiated",
    domain: CommonDomain.network,
    action: CommonAction.requestSent,
    payload: ["endpoint": "/api/v1/users", "method": "GET"]
)

LogMessage(.info, "API response received",
    domain: CommonDomain.network,
    action: CommonAction.responseReceived,
    payload: ["status": "200", "duration_ms": "245"]
)
```

### Error Handling
```swift
let networkError = NSError(
    domain: "NetworkError",
    code: -1009,
    userInfo: [NSLocalizedDescriptionKey: "The Internet connection appears to be offline."]
)

LogMessage(.error, networkError,
    domain: CommonDomain.network,
    action: CommonAction.failed,
    isCritical: true,
    payload: ["retry_count": "3"]
)
```

### Performance Monitoring
```swift
LogMessage(.info, "Screen render completed",
    domain: CommonDomain.performance,
    action: CommonAction.measured,
    payload: ["screen": "HomeView", "render_time_ms": "42"]
)
```

## Testing

```swift
// Create mock interceptor
class MockInterceptor: LetopisInterceptor {
    var capturedEvents: [LogEvent] = []
    
    var name: String { "MockInterceptor" }
    
    func handle(_ event: LogEvent) async throws {
        capturedEvents.append(event)
    }
    
    func health() async -> Bool { true }
}

// Setup mock in tests
let mockInterceptor = MockInterceptor()
let mockLogger = Letopis(interceptors: [mockInterceptor])

LogDispatcher.reset()
LogDispatcher.configure(with: mockLogger)

// Execute code that logs
LogMessage(.info, "Test event")

// Verify captured events
XCTAssertEqual(mockInterceptor.capturedEvents.count, 1)
XCTAssertEqual(mockInterceptor.capturedEvents[0].message, "Test event")
XCTAssertEqual(mockInterceptor.capturedEvents[0].severity, .info)

// Cleanup after tests
LogDispatcher.reset()
```

## What Happens if Logger is Not Configured?

In DEBUG mode you'll get a warning in the console:

```
⚠️ [Letopis] Cannot send log message - LogDispatcher is not configured!
   Message: [info] User logged in
   Configure LogDispatcher at app startup: LogDispatcher.configure(with: Letopis(...))
```

In RELEASE mode events are silently ignored.

## Accessing the Created Event

```swift
let logMsg = LogMessage(.info, "Test event",
    domain: CommonDomain.app,
    action: CommonAction.started
)

// Access the created LogEvent
print(logMsg.logEvent.eventID)      // "app.started"
print(logMsg.logEvent.timestamp)    // 2024-01-01 10:00:00
print(logMsg.logEvent.severity)     // .info
```

## When to Use LogMessage?

- ✅ When you need maximum simplicity
- ✅ When you only need to specify parameters once
- ✅ For quick logging anywhere in the code
- ✅ When you don't need builder patterns or method chaining

## Alternatives

- **Direct Letopis** - Full control through `Letopis` instance
- **DSL (logger.log())** - Builder pattern with method chaining
- **Custom wrappers** - Create your own abstraction

## See Also

- [Quick Start](quick-start.md)
- [Examples](examples/)
- [API Reference](api/)

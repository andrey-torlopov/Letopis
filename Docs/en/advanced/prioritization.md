## Event Criticality

Events can be marked as critical using the `isCritical` flag to indicate they require immediate attention.

### Non-Critical Events (Default)

Regular events that can be buffered or sent in batches.

```swift
logger.log()
    .event("user_action")
    .info("User scrolled to bottom")
// isCritical = false by default
```

### Critical Events

Events that require immediate handling (failures, critical analytics).

```swift
logger.log()
    .event("payment")
    .critical()
    .error("Payment processing failed")
// isCritical = true
```

Or using convenience methods:

```swift
// Error methods default to critical
logger.error("Payment failed", isCritical: true)

// Other methods default to non-critical
logger.info("User action", isCritical: false)
```

## Interceptor-Specific Interpretation

Each interceptor can interpret criticality differently:

### Network Interceptor Example

```swift
final class NetworkInterceptor: LetopisInterceptor {
    func handle(_ logEvent: LogEvent) {
        if logEvent.isCritical {
            // Send immediately
            sendImmediately(logEvent)
        } else {
            // Queue for batch sending
            addToQueue(logEvent)
        }
    }
}
```

### Disk Interceptor Example

```swift
final class DiskInterceptor: LetopisInterceptor {
    func handle(_ logEvent: LogEvent) {
        // Persist everything
        saveToDisk(logEvent)
        
        // Trigger sync only for critical events
        if logEvent.isCritical {
            triggerBackgroundSync()
        }
    }
}
```

### Console Interceptor Example

```swift
let consoleInterceptor = ConsoleInterceptor(
    criticalOnly: true  // Only print critical events
)
```

## OSLog Integration

When using `ConsoleInterceptor` with OSLog, criticality affects the log level:

```swift
let consoleInterceptor = ConsoleInterceptor(
    useOSLog: true,
    subsystem: "com.yourapp.identifier",
    category: "Analytics"
)
```

**Log level mapping:**
- `.debug` → `.debug`
- `.info` → `.info`  
- `.warning` → `.default` (or `.error` if critical)
- `.error` → `.error` (or `.fault` if critical)

Critical events get elevated to higher OSLog levels for better visibility.

## Best Practices

1. **Use non-critical for most logs**: Reserve critical flag for truly important events
2. **Define clear criteria**: Document when to mark events as critical
3. **Test criticality handling**: Verify interceptors behave correctly
4. **Consider user impact**: Critical events should be worth the performance cost

## Common Use Cases

### Critical Events
- Payment failures
- Security breaches
- Data corruption
- Service outages
- Fatal errors

### Non-Critical Events
- User interactions
- API calls
- Debug information
- Performance metrics
- Feature usage

---

[Back to Documentation Index](../index.md)

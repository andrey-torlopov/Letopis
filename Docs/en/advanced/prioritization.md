# Event Prioritization

## Priority Levels

`LogPriority` defines two levels:

### `.default`
Regular events that can be buffered or sent in batches.

```swift
logger.priority(.default).info("User scrolled to bottom")
```

### `.critical`
Events that require immediate handling (failures, critical analytics).

```swift
logger.priority(.critical).error("Payment processing failed")
```

## Interceptor-Specific Interpretation

Each interceptor can interpret priorities differently:

### Network Interceptor Example
```swift
final class NetworkInterceptor: LetopisInterceptor {
    func handle(_ logEvent: LogEvent) {
        if logEvent.priority == .critical {
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
        if logEvent.priority == .critical {
            triggerBackgroundSync()
        }
    }
}
```

### Console Interceptor Example
```swift
let consoleInterceptor = ConsoleInterceptor(
    priorities: [.critical] // Only print critical messages
)
```

## Best Practices

1. **Use `.default` for most logs**: Reserve `.critical` for truly important events
2. **Define clear criteria**: Document when to use each priority level
3. **Test priority handling**: Verify interceptors behave correctly for each level
4. **Consider user impact**: Critical events should be worth the performance cost

## Common Use Cases

### Critical Priority
- Payment failures
- Security breaches
- Data corruption
- Service outages
- Fatal errors

### Default Priority
- User interactions
- API calls
- Debug information
- Performance metrics
- Feature usage

---

[Back to Documentation Index](../index.md)

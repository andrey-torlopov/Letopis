# Combining Interceptors

## Multiple Interceptors

`Letopis` supports multiple interceptors simultaneously, allowing you to mix and match handlers per environment.

## Production Setup

```swift
let logger = Letopis(
    interceptors: [
        ConsoleInterceptor(logTypes: [.error]), // Only errors in console
        AnalyticsInterceptor(analyticsService: mixpanel), // User events to analytics
        CrashReportingInterceptor(crashlytics: crashlytics), // Critical errors to crash reporting
        LocalStorageInterceptor(storage: coreDataStack) // All events to local database
    ]
)
```

## Development Setup

```swift
#if DEBUG
let devLogger = Letopis(
    interceptors: [
        ConsoleInterceptor() // All events to console for debugging
    ]
)
#endif
```

## Dynamic Interceptor Management

Add interceptors at runtime:

```swift
let logger = Letopis(interceptors: [ConsoleInterceptor()])

// Add network interceptor when user logs in
logger.addInterceptor(NetworkInterceptor(apiClient: client))

// Add analytics when user accepts tracking
logger.addInterceptor(AnalyticsInterceptor(service: analytics))
```

## Event Flow

When any logging method is called:
1. A `LogEvent` is created
2. The event is forwarded to each interceptor in order
3. Each interceptor processes the event independently
4. No interceptor blocks others

## Interceptor Combinations

### Local + Remote
```swift
Letopis(interceptors: [
    LocalStorageInterceptor(), // Backup all events locally
    NetworkInterceptor() // Send to server when online
])
```

### Console + Analytics + Crash Reporting
```swift
Letopis(interceptors: [
    ConsoleInterceptor(logTypes: [.debug, .info]),
    AnalyticsInterceptor(),
    CrashReportingInterceptor()
])
```

### Priority-Based Routing
```swift
Letopis(interceptors: [
    ConsoleInterceptor(), // All events
    NetworkInterceptor(priorities: [.critical]), // Only critical to network
    FileInterceptor(logTypes: [.error]) // Only errors to file
])
```

## Best Practices

1. **Order matters**: Place interceptors in order of importance
2. **Keep interceptors independent**: Don't rely on execution order
3. **Handle failures gracefully**: One interceptor failure shouldn't affect others
4. **Test combinations**: Verify interceptors work well together
5. **Monitor performance**: Too many interceptors can impact performance

---

[Back to Documentation Index](../index.md)

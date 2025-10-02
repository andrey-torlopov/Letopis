# Interceptors

## Overview

Interceptors are the core extension mechanism in Letopis. They decide what to do with log events: send them to the network, persist them, filter them, or transform them.

## Base Protocol

To conform to `LetopisInterceptor`, implement a single method:

```swift
func handle(_ logEvent: LogEvent)
```

Once invoked, you can:
- Process the event synchronously or asynchronously
- Drop it if it doesn't match your rules
- Transform the payload and forward it to another system

## Console Interceptor

`ConsoleInterceptor` is a ready-to-use implementation that filters events by:
- Log type
- Priority
- Semantic values
- Source file

```swift
let consoleInterceptor = ConsoleInterceptor(
    logTypes: [.info, .error],
    eventTypes: ["user_action", "api_call"],
    priorities: [.default, .critical],
    sourceFiles: ["ViewController.swift"]
)
```

### Features

- Filters are provided as arrays and normalized into sets
- Formats events into strings
- Prints using a `Printer` closure (defaults to `print`)
- Executes on `LoggingActor` for serialized output
- Suppresses output in non-DEBUG builds

## Custom Interceptors

### Example: Analytics Interceptor

```swift
final class AnalyticsInterceptor: LetopisInterceptor {
    private let analyticsService: AnalyticsService
    
    init(analyticsService: AnalyticsService) {
        self.analyticsService = analyticsService
    }
    
    func handle(_ logEvent: LogEvent) {
        // Only send analytics and user action events
        guard let eventType = logEvent.payload["event_type"],
              ["analytics", "user_action"].contains(eventType) else { return }
        
        let analyticsEvent = AnalyticsEvent(
            name: logEvent.message,
            properties: logEvent.payload,
            timestamp: logEvent.timestamp
        )
        
        analyticsService.track(analyticsEvent)
    }
}
```

### Example: File Storage Interceptor

```swift
final class FileStorageInterceptor: LetopisInterceptor {
    private let fileManager: FileManager
    private let logFileURL: URL
    
    func handle(_ logEvent: LogEvent) {
        let jsonData = try? JSONEncoder().encode(logEvent)
        // Write to file...
    }
}
```

### Example: Database Interceptor

```swift
final class DatabaseInterceptor: LetopisInterceptor {
    private let database: Database
    
    func handle(_ logEvent: LogEvent) {
        database.insert(logEvent)
    }
}
```

## Implementation Tips

1. **Keep interceptors focused**: Each interceptor should have a single responsibility
2. **Handle errors gracefully**: Don't let interceptor failures break the logging pipeline
3. **Consider performance**: Avoid blocking operations in the handle method
4. **Use actors for thread safety**: When managing mutable state, use Swift actors
5. **Test thoroughly**: Write unit tests for your interceptors

---

[Back to Documentation Index](../index.md)

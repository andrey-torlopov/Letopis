# Network Interceptor with Caching

For a complete example of a network-aware interceptor with caching and connectivity monitoring, see [`Demo.swift`](../../../Sources/Letopis/Examples/Demo.swift).

## Features Demonstrated

### Thread-Safe Actor-Based Interceptor
Handles network logs safely across concurrent operations.

### Smart Caching
Stores logs when offline and processes them when connectivity returns.

### Priority-Based Handling
Critical logs are sent even in poor network conditions.

### Network State Monitoring
Different behaviors for:
- Online
- Offline
- Poor connectivity

### Real-World Scenarios
- Server failures
- Retry logic
- Connection recovery

## Basic Implementation

```swift
actor NetworkInterceptor: LetopisInterceptor {
    private var cachedEvents: [LogEvent] = []
    private var isOnline: Bool = true
    
    func handle(_ logEvent: LogEvent) async {
        if isOnline {
            await sendToServer(logEvent)
        } else {
            cacheEvent(logEvent)
        }
    }
    
    func setOnline(_ online: Bool) {
        isOnline = online
        if online {
            Task {
                await processCachedEvents()
            }
        }
    }
    
    private func cacheEvent(_ event: LogEvent) {
        cachedEvents.append(event)
    }
    
    private func processCachedEvents() async {
        for event in cachedEvents {
            await sendToServer(event)
        }
        cachedEvents.removeAll()
    }
    
    private func sendToServer(_ event: LogEvent) async {
        // Network request implementation
    }
}
```

## Usage

```swift
let networkInterceptor = NetworkInterceptor()
let logger = Letopis(interceptors: [networkInterceptor])

// Log events
logger.info("User action", isCritical: true)

// Update network state
await networkInterceptor.setOnline(false)

// Events will be cached
logger.info("Offline event")

// Restore connection
await networkInterceptor.setOnline(true)
// Cached events are now sent
```

---

[Back to Documentation Index](../index.md)

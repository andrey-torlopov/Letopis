# Testing Interceptors

## Spy Interceptor Pattern

Create a spy interceptor to verify event delivery:

```swift
final class SpyInterceptor: LetopisInterceptor {
    private(set) var receivedEvents: [LogEvent] = []
    
    func handle(_ logEvent: LogEvent) {
        receivedEvents.append(logEvent)
    }
    
    func reset() {
        receivedEvents.removeAll()
    }
}
```

## Unit Tests

### Test Event Delivery

```swift
import XCTest
@testable import Letopis

class LoggerTests: XCTestCase {
    func testEventDelivery() {
        let spy = SpyInterceptor()
        let logger = Letopis(interceptors: [spy])
        
        logger.info("Test message")
        
        XCTAssertEqual(spy.receivedEvents.count, 1)
        XCTAssertEqual(spy.receivedEvents.first?.message, "Test message")
        XCTAssertEqual(spy.receivedEvents.first?.type, .info)
    }
}
```

### Test Event Filtering

```swift
func testConsoleInterceptorFiltering() {
    let spy = SpyInterceptor()
    let console = ConsoleInterceptor(logTypes: [.error])
    let logger = Letopis(interceptors: [spy, console])
    
    logger.info("Info message")
    logger.error("Error message")
    
    // Spy receives all events
    XCTAssertEqual(spy.receivedEvents.count, 2)
    
    // Console only processes errors
    // (verify through console output or mock printer)
}
```

### Test Priority Handling

```swift
func testPriorityHandling() {
    let spy = SpyInterceptor()
    let logger = Letopis(interceptors: [spy])
    
    logger.priority(.critical).error("Critical error")
    
    XCTAssertEqual(spy.receivedEvents.first?.priority, .critical)
}
```

### Test Payload

```swift
func testPayload() {
    let spy = SpyInterceptor()
    let logger = Letopis(interceptors: [spy])
    
    logger
        .payload(["user_id": "12345", "action": "login"])
        .info("User action")
    
    let payload = spy.receivedEvents.first?.payload
    XCTAssertEqual(payload?["user_id"] as? String, "12345")
    XCTAssertEqual(payload?["action"] as? String, "login")
}
```

## Testing Custom Interceptors

### Test Network Interceptor

```swift
actor MockNetworkClient {
    var sentEvents: [LogEvent] = []
    
    func send(_ event: LogEvent) async {
        sentEvents.append(event)
    }
}

func testNetworkInterceptor() async {
    let mockClient = MockNetworkClient()
    let interceptor = NetworkInterceptor(client: mockClient)
    let logger = Letopis(interceptors: [interceptor])
    
    logger.info("Network message")
    
    // Wait for async processing
    try? await Task.sleep(nanoseconds: 100_000_000)
    
    let sent = await mockClient.sentEvents
    XCTAssertEqual(sent.count, 1)
}
```

### Test Caching

```swift
func testEventCaching() async {
    let interceptor = NetworkInterceptor()
    await interceptor.setOnline(false)
    
    let logger = Letopis(interceptors: [interceptor])
    logger.info("Cached event")
    
    let cached = await interceptor.cachedEventsCount
    XCTAssertEqual(cached, 1)
    
    await interceptor.setOnline(true)
    try? await Task.sleep(nanoseconds: 100_000_000)
    
    let afterSync = await interceptor.cachedEventsCount
    XCTAssertEqual(afterSync, 0)
}
```

## Testing Sensitive Data Masking

```swift
func testSensitiveDataMasking() {
    let spy = SpyInterceptor()
    let logger = Letopis(
        interceptors: [spy],
        sensitiveKeys: ["password"]
    )
    
    logger
        .payload(["password": "secret123", "username": "john"])
        .sensitive()
        .info("Login")
    
    let payload = spy.receivedEvents.first?.payload
    XCTAssertEqual(payload?["password"] as? String, "s***3")
    XCTAssertEqual(payload?["username"] as? String, "john")
}
```

## Mock Printer for Console Testing

```swift
final class MockPrinter {
    var printedMessages: [String] = []
    
    func print(_ message: String) {
        printedMessages.append(message)
    }
}

func testConsoleOutput() {
    let mockPrinter = MockPrinter()
    let console = ConsoleInterceptor(printer: mockPrinter.print)
    let logger = Letopis(interceptors: [console])
    
    logger.info("Test")
    
    XCTAssertTrue(mockPrinter.printedMessages.first?.contains("Test") ?? false)
}
```

## Integration Tests

```swift
func testMultipleInterceptors() {
    let spy1 = SpyInterceptor()
    let spy2 = SpyInterceptor()
    let logger = Letopis(interceptors: [spy1, spy2])
    
    logger.info("Message")
    
    XCTAssertEqual(spy1.receivedEvents.count, 1)
    XCTAssertEqual(spy2.receivedEvents.count, 1)
}
```

## Performance Tests

```swift
func testLoggingPerformance() {
    let logger = Letopis(interceptors: [SpyInterceptor()])
    
    measure {
        for _ in 0..<1000 {
            logger.info("Performance test")
        }
    }
}
```

---

[Back to Documentation Index](../index.md)

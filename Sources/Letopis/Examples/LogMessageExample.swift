import Foundation

/// Example demonstrating how to use LogMessage class for simple logging.
///
/// LogMessage provides a straightforward interface where you create an object
/// with all necessary parameters, and it automatically sends the event to Letopis.
public func logMessageExample() {
    print("\n=== LogMessage Example ===\n")

    // MARK: - 1. Configuration

    print("1. Configuring LogDispatcher...")

    let logger = Letopis(
        interceptors: [ConsoleInterceptor()],
        healthCheckInterval: 30.0,
        sensitiveKeys: ["password", "token", "apiKey"]
    )

    LogDispatcher.configure(with: logger)
    print("   Logger configured\n")

    // MARK: - 2. Simple Logging

    print("2. Simple logging with LogMessage...\n")

    // Just severity and message
    LogMessage(.debug, "Application started")
    LogMessage(.info, "User session initialized")

    // With domain and action
    LogMessage(.notice, "User logged in successfully",
        domain: CommonDomain.auth,
        action: CommonAction.loggedIn
    )

    // With all parameters
    LogMessage(.info, "Payment processed",
        domain: CommonDomain.business,
        action: CommonAction.completed,
        payload: [
            "amount": "99.99",
            "currency": "USD",
            "user_id": "12345"
        ]
    )

    // Critical warning
    LogMessage(.warning, "Low memory warning",
        domain: CommonDomain.system,
        action: CommonAction.errorOccurred,
        isCritical: true
    )

    // Error logging
    LogMessage(.error, "Network request failed",
        domain: CommonDomain.network,
        action: CommonAction.failed,
        payload: ["url": "https://api.example.com/users"]
    )

    // Critical fault
    LogMessage(.fault, "Database connection lost",
        domain: CommonDomain.database,
        action: CommonAction.disconnected,
        isCritical: true
    )

    print("\n")

    // MARK: - 3. Logging Errors

    print("3. Logging Error instances...\n")

    let error = NSError(domain: "com.example.app", code: 404, userInfo: [
        NSLocalizedDescriptionKey: "Resource not found"
    ])

    LogMessage(.error, error,
        domain: CommonDomain.api,
        action: CommonAction.errorOccurred
    )

    print("\n")

    // MARK: - 4. Custom Domains and Actions

    print("4. Using custom typed domains and actions...\n")

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

    LogMessage(.info, "Payment initiated",
        domain: PaymentDomain.payments,
        action: PaymentAction.initiated,
        payload: ["amount": "149.99"]
    )

    LogMessage(.notice, "Payment processing",
        domain: PaymentDomain.payments,
        action: PaymentAction.processing
    )

    LogMessage(.notice, "Payment succeeded",
        domain: PaymentDomain.payments,
        action: PaymentAction.succeeded,
        payload: ["transaction_id": "txn_123456"]
    )

    print("\n")
}

/// Example demonstrating behavior when logger is not configured.
public func unconfiguredLogMessageExample() {
    print("\n=== Unconfigured LogMessage Example ===\n")

    print("1. Resetting logger...")
    LogDispatcher.reset()

    print("\n2. Attempting to log without configuration (DEBUG mode shows warning)...\n")

    // These will show warnings in DEBUG mode
    LogMessage(.debug, "This won't be logged")
    LogMessage(.error, "Neither will this")

    print("\n3. Configuring logger...")
    LogDispatcher.configure(with: Letopis(interceptors: [ConsoleInterceptor()]))

    print("\n4. Now logging works...\n")
    LogMessage(.info, "This will be logged!",
        domain: CommonDomain.app,
        action: CommonAction.started
    )

    print("\n")
}

/// Example demonstrating LogMessage with mock logger for testing.
public func mockLogMessageExample() {
    print("\n=== Mock LogMessage Example ===\n")

    print("1. Creating mock logger for tests...")

    class MockInterceptor: LetopisInterceptor {
        var capturedEvents: [LogEvent] = []

        var name: String { "MockInterceptor" }

        func handle(_ event: LogEvent) async throws {
            capturedEvents.append(event)
            print("   [Mock] Captured: \(event.severity) - \(event.message)")
        }

        func health() async -> Bool {
            return true
        }
    }

    let mockInterceptor = MockInterceptor()
    let mockLogger = Letopis(interceptors: [mockInterceptor])

    LogDispatcher.reset()
    LogDispatcher.configure(with: mockLogger)

    print("\n2. Logging with mock...\n")

    LogMessage(.info, "Test event 1")
    LogMessage(.warning, "Test event 2",
        domain: CommonDomain.debug,
        action: CommonAction.checkpoint
    )
    LogMessage(.error, "Test event 3", isCritical: true)

    // Give async tasks time to complete
    Thread.sleep(forTimeInterval: 0.1)

    print("\n3. Verifying captured events...")
    print("   Total events captured: \(mockInterceptor.capturedEvents.count)")

    for (index, event) in mockInterceptor.capturedEvents.enumerated() {
        print("   Event \(index + 1): [\(event.severity)] \(event.message) - \(event.domain).\(event.action)")
    }

    print("\n4. Cleaning up...")
    LogDispatcher.reset()
    print("   Logger reset\n")
}

/// Real-world example showing practical usage patterns.
public func realWorldLogMessageExample() {
    print("\n=== Real-World LogMessage Usage ===\n")

    // Configure at app startup
    LogDispatcher.configure(with: Letopis(interceptors: [ConsoleInterceptor()]))

    print("Simulating real-world scenarios...\n")

    // 1. User authentication flow
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

    // 2. API request
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

    // 3. Data processing
    LogMessage(.debug, "Data parsing started",
        domain: CommonDomain.parsing,
        action: CommonAction.started
    )

    LogMessage(.info, "Data cached",
        domain: CommonDomain.cache,
        action: CommonAction.cached,
        payload: ["cache_key": "users_list", "ttl": "300"]
    )

    // 4. Error scenario
    let networkError = NSError(domain: "NetworkError", code: -1009, userInfo: [
        NSLocalizedDescriptionKey: "The Internet connection appears to be offline."
    ])

    LogMessage(.error, networkError,
        domain: CommonDomain.network,
        action: CommonAction.failed,
        isCritical: true,
        payload: ["retry_count": "3"]
    )

    // 5. Performance monitoring
    LogMessage(.info, "Screen render completed",
        domain: CommonDomain.performance,
        action: CommonAction.measured,
        payload: ["screen": "HomeView", "render_time_ms": "42"]
    )

    print("\n")
}

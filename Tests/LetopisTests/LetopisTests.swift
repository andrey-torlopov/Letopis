import Testing
import Foundation
@testable import Letopis

@Test func logEventCreation() async throws {
    enum TestEvent: String, EventTypeProtocol { case someEvent = "some_event" }
    enum TestAction: String, EventActionProtocol { case open = "open" }

    let logger = Letopis()
    let payload: [String: String] = ["Key": "Value"]

    let event = logger.info(
        "Test message",
        priority: .critical,
        payload: payload,
        eventType: TestEvent.someEvent,
        eventAction: TestAction.open
    )

    #expect(event.message == "Test message")
    #expect(event.type == LogEventType.info)
    #expect(event.priority == LogPriority.critical)
    #expect(event.payload["Key"] == "Value")
    #expect(event.payload["event_type"] == TestEvent.someEvent.rawValue)
    #expect(event.payload["event_action"] == TestAction.open.rawValue)
}

@Test func interceptorsReceiveEvents() async throws {
    enum TestEventType: String, EventTypeProtocol {
        case analytics = "analytics"
        case userAction = "user_action"
    }
    enum TestEventAction: String, EventActionProtocol {
        case view = "view"
    }

    actor SpyInterceptor: LetopisInterceptor {
        var handledEvents: [LogEvent] = []

        nonisolated var name: String { "SpyInterceptor" }

        func handle(_ logEvent: LogEvent) async throws {
            handledEvents.append(logEvent)
        }

        func health() async -> Bool {
            return true
        }

        func getHandledEvents() -> [LogEvent] {
            return handledEvents
        }
    }

    let interceptor = SpyInterceptor()
    let logger = Letopis()
    logger.addInterceptor(interceptor)

    let directEvent = logger.info("Intercepted info", eventType: TestEventType.analytics)

    // Ждем завершения асинхронных операций
    try await Task.sleep(nanoseconds: 100_000_000) // 0.1 секунда

    let events = await interceptor.getHandledEvents()
    #expect(events.count >= 1)
    #expect(events.contains { $0.id == directEvent.id })
}

@Test func consoleInterceptorFiltersEvents() async throws {
    enum TestEventType: String, EventTypeProtocol {
        case error = "error"
        case analytics = "analytics"
    }
    enum TestEventAction: String, EventActionProtocol {
        case view = "view"
        case purchase = "purchase"
    }

    final class MessageCollector: @unchecked Sendable {
        private var _messages: [String] = []
        private let lock = NSLock()

        func append(_ message: String) {
            lock.lock()
            defer { lock.unlock() }
            _messages.append(message)
        }

        var messages: [String] {
            lock.lock()
            defer { lock.unlock() }
            return _messages
        }
    }

    let messageCollector = MessageCollector()

    let consoleInterceptor = ConsoleInterceptor(
        logTypes: [.error],
        priorities: [.critical],
        eventTypes: ["error"],
        actions: ["view"],
        sourceFiles: ["TestFile.swift"],
        printer: { messageCollector.append($0) }
    )

    let logger = Letopis(interceptors: [consoleInterceptor])

    // Создаем payload для тестирования фильтров
    let visiblePayload: [String: String] = [
        "event_type": "error",
        "event_action": "view",
        "source_file": "TestFile.swift"
    ]

    let hiddenByActionPayload: [String: String] = [
        "event_type": "error",
        "event_action": "purchase",
        "source_file": "TestFile.swift"
    ]

    logger.error("Visible error", priority: .critical, payload: visiblePayload)
    logger.error("Hidden by action", priority: .critical, payload: hiddenByActionPayload)
    logger.info("Hidden by log type", priority: .critical, payload: visiblePayload)

    // Ждем завершения асинхронных операций
    try await Task.sleep(nanoseconds: 100_000_000) // 0.1 секунда

    #expect(messageCollector.messages.count == 1)
    #expect(messageCollector.messages.first?.contains("Visible error") == true)
}

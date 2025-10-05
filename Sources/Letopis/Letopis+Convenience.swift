import Foundation

// MARK: - String-based Event Wrappers

/// Internal wrapper for String-based event types
private struct StringEventType: EventTypeProtocol {
    let value: String
}

/// Internal wrapper for String-based event actions
private struct StringEventAction: EventActionProtocol {
    let value: String
}

// MARK: - Convenience Extensions

public extension Letopis {

    // MARK: - Global Console Logger

    /// Simple console logger for quick debugging and prototyping.
    /// Only works in DEBUG builds.
    /// Perfect for getting started without setting up dependency injection.
    ///
    /// Example:
    /// ```swift
    /// Letopis.console.log("Quick debug message")
    /// Letopis.console.log("Error occurred", level: .error, event: "network")
    /// ```
    static let console = Letopis(interceptors: [ConsoleInterceptor()])

    // MARK: - Convenience Logging Methods

    /// Quick logging method with optional String-based event and action.
    /// Perfect for simple logging without creating enum types.
    ///
    /// - Parameters:
    ///   - message: Message to log
    ///   - level: Log level (defaults to .info)
    ///   - priority: Log priority (defaults to .default)
    ///   - event: Optional event type as String
    ///   - action: Optional action as String
    ///   - payload: Optional payload dictionary
    /// - Returns: Created LogEvent
    ///
    /// Example:
    /// ```swift
    /// logger.log("User logged in", event: "auth", action: "success")
    /// logger.log("Network error", level: .error, event: "network")
    /// ```
    @discardableResult
    func log(
        _ message: String,
        level: LogLevel = .info,
        priority: LogPriority = .default,
        event: String? = nil,
        action: String? = nil,
        payload: [String: String]? = nil
    ) -> LogEvent {
        let eventType: EventTypeProtocol? = event.map { StringEventType(value: $0) }
        let eventAction: EventActionProtocol? = action.map { StringEventAction(value: $0) }

        switch level {
        case .info:
            return info(message, priority: priority, payload: payload, eventType: eventType, eventAction: eventAction)
        case .debug:
            return debug(message, priority: priority, payload: payload, eventType: eventType, eventAction: eventAction)
        case .warning:
            return warning(message, priority: priority, payload: payload, eventType: eventType, eventAction: eventAction)
        case .error:
            return error(message, priority: priority, payload: payload, eventType: eventType, eventAction: eventAction)
        case .analytics:
            return analytics(message, priority: priority, payload: payload, eventType: eventType, eventAction: eventAction)
        }
    }

    /// Quick error logging with Error object.
    ///
    /// - Parameters:
    ///   - error: Error object to log
    ///   - priority: Log priority (defaults to .critical)
    ///   - event: Optional event type as String
    ///   - action: Optional action as String
    ///   - payload: Optional payload dictionary
    /// - Returns: Created LogEvent
    ///
    /// Example:
    /// ```swift
    /// logger.log(networkError, event: "network", action: "request_failed")
    /// ```
    @discardableResult
    func log(
        _ error: Error,
        priority: LogPriority = .critical,
        event: String? = nil,
        action: String? = nil,
        payload: [String: String]? = nil
    ) -> LogEvent {
        let eventType: EventTypeProtocol? = event.map { StringEventType(value: $0) }
        let eventAction: EventActionProtocol? = action.map { StringEventAction(value: $0) }

        return self.error(error, priority: priority, payload: payload, eventType: eventType, eventAction: eventAction)
    }
}

// MARK: - LogLevel Enum

/// Simple enum for log levels to make convenience API easier to use.
public enum LogLevel {
    case info
    case debug
    case warning
    case error
    case analytics
}

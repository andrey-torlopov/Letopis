import Foundation

/// Metadata about the source location where a log was created.
public struct SourceInfo {
    let fileName: String
    let function: String
    let line: String
}

/// Internal builder for constructing log events with metadata.
///
/// This class is used internally and can be extended with DSL methods via extensions.
/// For standard logging, use the direct methods on `Letopis` (info, warning, error, etc.).
public final class Log {

    // MARK: - Internal Properties

    internal let logger: Letopis
    internal var isCritical: Bool = false
    internal var payload: [String: String] = [:]
    internal var eventType: String?
    internal var eventAction: String?
    internal var sourceInfo: SourceInfo?
    internal var customSensitiveKeys: [String: SensitiveDataStrategy] = [:]
    internal var shouldUseSensitive: Bool = true

    // MARK: - Initialization

    init(logger: Letopis) {
        self.logger = logger
    }

    // MARK: - Public Methods

    /// Creates and dispatches an informational log event.
    /// - Parameter message: Descriptive message for the log.
    /// - Returns: The created ``LogEvent``.
    @discardableResult
    public func info(_ message: String) -> LogEvent {
        return createAndSendEvent(message: message, type: .info)
    }

    /// Creates and dispatches a warning log event.
    /// - Parameter message: Descriptive message for the log.
    /// - Returns: The created ``LogEvent``.
    @discardableResult
    public func warning(_ message: String) -> LogEvent {
        return createAndSendEvent(message: message, type: .warning)
    }

    /// Creates and dispatches an error log event with a message.
    /// - Parameter message: Descriptive message for the log.
    /// - Returns: The created ``LogEvent``.
    @discardableResult
    public func error(_ message: String) -> LogEvent {
        return createAndSendEvent(message: message, type: .error)
    }

    /// Creates and dispatches an error log event from an Error instance.
    /// - Parameter error: Error to log.
    /// - Returns: The created ``LogEvent``.
    @discardableResult
    public func error(_ error: Error) -> LogEvent {
        return createAndSendEvent(message: error.localizedDescription, type: .error)
    }

    /// Creates and dispatches a debug log event.
    /// - Parameter message: Descriptive message for the log.
    /// - Returns: The created ``LogEvent``.
    @discardableResult
    public func debug(_ message: String) -> LogEvent {
        return createAndSendEvent(message: message, type: .debug)
    }

    /// Creates and dispatches an analytics log event.
    /// - Parameter message: Descriptive message for the log.
    /// - Returns: The created ``LogEvent``.
    @discardableResult
    public func analytics(_ message: String) -> LogEvent {
        return createAndSendEvent(message: message, type: .analytics)
    }

    // MARK: - Internal Methods

    /// Sets the event type internally.
    /// - Parameter value: Event type string.
    /// - Returns: Self for chaining.
    internal func setEventType(_ value: String) -> Log {
        eventType = value
        return self
    }

    /// Sets the event action internally.
    /// - Parameter value: Event action string.
    /// - Returns: Self for chaining.
    internal func setEventAction(_ value: String) -> Log {
        eventAction = value
        return self
    }

    /// Creates a log event with accumulated metadata and dispatches it to interceptors.
    /// - Parameters:
    ///   - message: Log message.
    ///   - type: Type of log event.
    /// - Returns: The created ``LogEvent``.
    internal func createAndSendEvent(message: String, type: LogEventType) -> LogEvent {
        let event = logger.createLogEvent(
            message,
            type: type,
            isCritical: isCritical,
            payload: buildPayload()
        )
        return event
    }

    /// Builds the final payload by combining all metadata and applying masking if enabled.
    /// - Returns: Complete payload dictionary.
    internal func buildPayload() -> [String: String] {
        var result = payload

        if let eventType {
            result["event_type"] = eventType
        }

        if let eventAction {
            result["event_action"] = eventAction
        }

        if let sourceInfo {
            result["source_file"] = sourceInfo.fileName
            result["source_function"] = sourceInfo.function
            result["source_line"] = sourceInfo.line
        }

        // Apply sensitive data masking if enabled
        if shouldUseSensitive {
            result = maskSensitiveData(in: result)
        }

        return result.isEmpty ? [:] : result
    }

    /// Applies masking strategies to sensitive keys in the payload.
    /// - Parameter payload: Original payload dictionary.
    /// - Returns: Payload with sensitive values masked.
    internal func maskSensitiveData(in payload: [String: String]) -> [String: String] {
        var maskedPayload = payload

        for (key, value) in payload {
            // Check if key has a custom strategy
            if let strategy = customSensitiveKeys[key] {
                maskedPayload[key] = strategy.mask(value)
            }
            // Check if key is in global sensitive keys list
            else if logger.sensitiveKeys.contains(key) {
                maskedPayload[key] = SensitiveDataStrategy.partial.mask(value)
            }
        }

        return maskedPayload
    }
}

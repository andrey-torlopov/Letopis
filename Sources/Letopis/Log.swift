import Foundation

/// Metadata about the source location where a log was created.
public struct SourceInfo {
    let fileName: String
    let function: String
    let line: String
}

/// Fluent builder for constructing and dispatching log events with metadata.
///
/// Use this class to chain configuration methods before sending a log event.
/// Each method returns `self` to enable fluent API pattern.
///
/// Example usage:
/// ```swift
/// logger.log()
///     .event("user_action")
///     .action("button_tap")
///     .payload(["screen": "home"])
///     .critical()
///     .sensitive(keys: ["user_id"])
///     .info("User tapped button")
/// ```
public final class Log {
    private let logger: Letopis
    private var isCritical: Bool = false
    private var payload: [String: String] = [:]
    private var eventType: String?
    private var eventAction: String?
    private var sourceInfo: SourceInfo?
    private var customSensitiveKeys: [String: SensitiveDataStrategy] = [:]
    private var shouldUseSensitive: Bool = false

    // MARK: - Init

    init(logger: Letopis) {
        self.logger = logger
    }

    // MARK: - Public

    /// Sets the event type using a protocol-conforming type.
    /// - Parameter type: Event type conforming to ``EventTypeProtocol``.
    /// - Returns: Self for chaining.
    @discardableResult
    public func event<T: EventTypeProtocol>(_ type: T) -> Log {
        setEventType(type.value)
    }

    /// Sets the event type using a string value.
    /// - Parameter value: Event type as a string.
    /// - Returns: Self for chaining.
    @discardableResult
    public func event(_ value: String) -> Log {
        setEventType(value)
    }

    /// Sets the event action using a protocol-conforming type.
    /// - Parameter action: Event action conforming to ``EventActionProtocol``.
    /// - Returns: Self for chaining.
    @discardableResult
    public func action<T: EventActionProtocol>(_ action: T) -> Log {
        setEventAction(action.value)
    }

    /// Sets the event action using a string value.
    /// - Parameter value: Event action as a string.
    /// - Returns: Self for chaining.
    @discardableResult
    public func action(_ value: String) -> Log {
        setEventAction(value)
    }

    /// Adds or merges additional metadata to the log payload.
    /// - Parameter payload: Dictionary of key-value pairs to add to the payload.
    /// - Returns: Self for chaining.
    @discardableResult
    public func payload(_ payload: [String: String]) -> Log {
        self.payload.merge(payload) { _, new in new }
        return self
    }

    /// Marks the log event as critical, requiring immediate attention.
    /// - Returns: Self for chaining.
    @discardableResult
    public func critical() -> Log {
        self.isCritical = true
        return self
    }

    /// Enables masking for all globally configured sensitive keys using partial strategy.
    /// - Returns: Self for chaining.
    @discardableResult
    public func sensitive() -> Log {
        shouldUseSensitive = true
        return self
    }

    /// Enables masking for specific keys with a given strategy.
    /// - Parameters:
    ///   - keys: Array of keys to mask in the payload.
    ///   - strategy: Masking strategy to use (defaults to .partial).
    /// - Returns: Self for chaining.
    @discardableResult
    public func sensitive(keys: [String], strategy: SensitiveDataStrategy = .partial) -> Log {
        shouldUseSensitive = true
        for key in keys {
            customSensitiveKeys[key] = strategy
        }
        return self
    }

    /// Enables masking for a specific key with a given strategy.
    /// - Parameters:
    ///   - key: Key to mask in the payload.
    ///   - strategy: Masking strategy to use (defaults to .partial).
    /// - Returns: Self for chaining.
    @discardableResult
    public func sensitive(key: String, strategy: SensitiveDataStrategy = .partial) -> Log {
        shouldUseSensitive = true
        customSensitiveKeys[key] = strategy
        return self
    }

    /// Captures source code location metadata for debugging purposes.
    /// - Parameters:
    ///   - file: Source file path (automatically captured).
    ///   - function: Function name (automatically captured).
    ///   - line: Line number (automatically captured).
    /// - Returns: Self for chaining.
    @discardableResult
    public func source(file: String = #file, function: String = #function, line: Int = #line) -> Log {
        let fileName = (file as NSString).lastPathComponent
        sourceInfo = SourceInfo(
            fileName: fileName,
            function: function,
            line: String(line)
        )
        return self
    }

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

    // MARK: - Private

    /// Creates a log event with accumulated metadata and dispatches it to interceptors.
    /// - Parameters:
    ///   - message: Log message.
    ///   - type: Type of log event.
    /// - Returns: The created ``LogEvent``.
    private func createAndSendEvent(message: String, type: LogEventType) -> LogEvent {
        let event = logger.createLogEvent(
            message,
            type: type,
            isCritical: isCritical,
            payload: buildPayload()
        )
        return event
    }

    /// Sets the event type internally.
    /// - Parameter value: Event type string.
    /// - Returns: Self for chaining.
    private func setEventType(_ value: String) -> Log {
        eventType = value
        return self
    }

    /// Sets the event action internally.
    /// - Parameter value: Event action string.
    /// - Returns: Self for chaining.
    private func setEventAction(_ value: String) -> Log {
        eventAction = value
        return self
    }

    /// Builds the final payload by combining all metadata and applying masking if enabled.
    /// - Returns: Complete payload dictionary.
    private func buildPayload() -> [String: String] {
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
    private func maskSensitiveData(in payload: [String: String]) -> [String: String] {
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

// MARK: - Helpers

/// Convenience extensions for creating Log instances from Letopis.
public extension Letopis {
    /// Creates a new Log builder instance.
    /// - Returns: A new ``Log`` builder.
    func log() -> Log {
        Log(logger: self)
    }

    /// Creates a Log builder and sets the event type using a protocol-conforming type.
    /// - Parameter event: Event type conforming to ``EventTypeProtocol``.
    /// - Returns: A ``Log`` builder with the event type set.
    @discardableResult
    func event<T: EventTypeProtocol>(_ event: T) -> Log {
        log().event(event)
    }

    /// Creates a Log builder and sets the event type using a string value.
    /// - Parameter value: Event type as a string.
    /// - Returns: A ``Log`` builder with the event type set.
    @discardableResult
    func event(_ value: String) -> Log {
        log().event(value)
    }

    /// Creates a Log builder and sets the event action using a protocol-conforming type.
    /// - Parameter action: Event action conforming to ``EventActionProtocol``.
    /// - Returns: A ``Log`` builder with the event action set.
    @discardableResult
    func action<T: EventActionProtocol>(_ action: T) -> Log {
        log().action(action)
    }

    /// Creates a Log builder and sets the event action using a string value.
    /// - Parameter value: Event action as a string.
    /// - Returns: A ``Log`` builder with the event action set.
    @discardableResult
    func action(_ value: String) -> Log {
        log().action(value)
    }
}

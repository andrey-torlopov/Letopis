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
    internal var purpose: LogPurpose = .operational
    internal var isCritical: Bool = false
    internal var payload: [String: String] = [:]
    internal var domain: String?
    internal var action: String?
    internal var correlationID: UUID?
    internal var sourceInfo: SourceInfo?
    internal var customSensitiveKeys: [String: SensitiveDataStrategy] = [:]
    internal var shouldUseSensitive: Bool = true

    // MARK: - Initialization

    init(logger: Letopis) {
        self.logger = logger
    }

    // MARK: - Public Methods - Severity-based Logging

    /// Sends a debug-level log event.
    /// - Parameter message: Descriptive message for the log.
    /// - Returns: The created ``LogEvent``.
    @discardableResult
    public func debug(_ message: String) -> LogEvent {
        return createAndSendEvent(message: message, severity: .debug)
    }

    /// Sends an info-level log event.
    /// - Parameter message: Descriptive message for the log.
    /// - Returns: The created ``LogEvent``.
    @discardableResult
    public func info(_ message: String) -> LogEvent {
        return createAndSendEvent(message: message, severity: .info)
    }

    /// Sends a notice-level log event.
    /// - Parameter message: Descriptive message for the log.
    /// - Returns: The created ``LogEvent``.
    @discardableResult
    public func notice(_ message: String) -> LogEvent {
        return createAndSendEvent(message: message, severity: .notice)
    }

    /// Sends a warning-level log event.
    /// - Parameter message: Descriptive message for the log.
    /// - Returns: The created ``LogEvent``.
    @discardableResult
    public func warning(_ message: String) -> LogEvent {
        return createAndSendEvent(message: message, severity: .warning)
    }

    /// Sends an error-level log event.
    /// - Parameter message: Descriptive message for the log.
    /// - Returns: The created ``LogEvent``.
    @discardableResult
    public func error(_ message: String) -> LogEvent {
        return createAndSendEvent(message: message, severity: .error)
    }

    /// Sends an error-level log event from an Error instance.
    /// - Parameter error: Error to log.
    /// - Returns: The created ``LogEvent``.
    @discardableResult
    public func error(_ error: Error) -> LogEvent {
        return self.error(error.localizedDescription)
    }

    /// Sends a fault-level log event.
    /// - Parameter message: Descriptive message for the log.
    /// - Returns: The created ``LogEvent``.
    @discardableResult
    public func fault(_ message: String) -> LogEvent {
        return createAndSendEvent(message: message, severity: .fault)
    }

    // MARK: - Internal Methods

    /// Sets the event type internally.
    /// - Parameter value: Event type string.
    /// - Returns: Self for chaining.
    internal func setDomain(_ value: String) -> Log {
        domain = value
        return self
    }

    /// Sets the event action internally.
    /// - Parameter value: Event action string.
    /// - Returns: Self for chaining.
    internal func setAction(_ value: String) -> Log {
        action = value
        return self
    }

    /// Creates a log event with accumulated metadata and dispatches it to interceptors.
    /// - Parameters:
    ///   - message: Log message.
    ///   - severity: Severity level of the event.
    ///   - purpose: Purpose of the event (defaults to internal purpose property).
    /// - Returns: The created ``LogEvent``.
    internal func createAndSendEvent(
        message: String,
        severity: LogSeverity,
        purpose: LogPurpose? = nil
    ) -> LogEvent {
        let domainValue = domain ?? DefaultDomain.empty.value
        let actionValue = action ?? DefaultAction.empty.value

        let event = logger.createLogEvent(
            message,
            severity: severity,
            purpose: purpose ?? self.purpose,
            domain: domainValue,
            action: actionValue,
            isCritical: isCritical,
            payload: buildPayload(),
            correlationID: correlationID
        )
        return event
    }

    /// Builds the final payload by combining all metadata and applying masking if enabled.
    /// - Returns: Complete payload dictionary.
    internal func buildPayload() -> [String: String] {
        var result = payload

        // Add legacy event_type and event_action for backward compatibility
        if let domain {
            result["domain"] = domain
        }
        if let action {
            result["action"] = action
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
            let lowercasedKey = key.lowercased()

            // Check if key has a custom strategy (case-insensitive)
            if let strategy = customSensitiveKeys[lowercasedKey] {
                maskedPayload[key] = strategy.mask(value)
            }
            // Check if key is in global sensitive keys list (case-insensitive)
            else if logger.sensitiveKeys.contains(lowercasedKey) {
                maskedPayload[key] = SensitiveDataStrategy.partial.mask(value)
            }
        }

        return maskedPayload
    }
}

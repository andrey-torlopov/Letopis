import Foundation

/// Simple message-based logging interface that creates and sends log events.
///
/// This class provides a straightforward way to create and send log events
/// by instantiating a message object with all necessary parameters.
///
/// Example usage:
/// ```swift
/// // Configure once at app startup
/// LogDispatcher.configure(with: Letopis(interceptors: [ConsoleInterceptor()]))
///
/// // Create and send log messages
/// LogMessage(.debug, "Application started")
///
/// LogMessage(.info, "User logged in",
///     domain: CommonDomain.auth,
///     action: CommonAction.loggedIn,
///     payload: ["user_id": "12345"]
/// )
///
/// LogMessage(.error, "Network request failed",
///     domain: CommonDomain.network,
///     action: CommonAction.failed,
///     isCritical: true,
///     payload: ["url": "https://api.example.com"]
/// )
///
/// // Logging errors
/// LogMessage(.error, someError,
///     domain: CommonDomain.network,
///     action: CommonAction.failed
/// )
/// ```
public final class LogMessage {

    // MARK: - Properties

    /// The underlying log event created from the message parameters.
    private let event: LogEvent

    // MARK: - Initialization

    /// Creates and immediately sends a log message with all parameters.
    /// - Parameters:
    ///   - severity: Severity level of the event.
    ///   - message: Human readable description of the event.
    ///   - domain: Business domain or subsystem. Defaults to empty.
    ///   - action: Specific action within the domain. Defaults to empty.
    ///   - purpose: Purpose of the event. Defaults to `.operational`.
    ///   - isCritical: Whether the event is critical. Defaults to `false`.
    ///   - payload: Additional metadata. Defaults to empty dictionary.
    ///   - correlationID: Optional correlation ID for tracking related events.
    @discardableResult
    public init(
        _ severity: LogSeverity,
        _ message: String,
        domain: DomainProtocol = DefaultDomain.empty,
        action: ActionProtocol = DefaultAction.empty,
        purpose: LogPurpose = .operational,
        isCritical: Bool = false,
        payload: [String: String] = [:],
        correlationID: UUID? = nil
    ) {
        // Create the log event
        self.event = LogEvent(
            severity: severity,
            purpose: purpose,
            domain: domain,
            action: action,
            message: message,
            payload: payload,
            isCritical: isCritical,
            correlationID: correlationID
        )

        // Send immediately upon creation
        send()
    }

    /// Creates and immediately sends a log message from an Error instance.
    /// - Parameters:
    ///   - severity: Severity level of the event.
    ///   - error: Error to log.
    ///   - domain: Business domain or subsystem. Defaults to empty.
    ///   - action: Specific action within the domain. Defaults to empty.
    ///   - purpose: Purpose of the event. Defaults to `.operational`.
    ///   - isCritical: Whether the event is critical. Defaults to `false`.
    ///   - payload: Additional metadata. Defaults to empty dictionary.
    ///   - correlationID: Optional correlation ID for tracking related events.
    @discardableResult
    public convenience init(
        _ severity: LogSeverity,
        _ error: Error,
        domain: DomainProtocol = DefaultDomain.empty,
        action: ActionProtocol = DefaultAction.empty,
        purpose: LogPurpose = .operational,
        isCritical: Bool = false,
        payload: [String: String] = [:],
        correlationID: UUID? = nil
    ) {
        self.init(
            severity,
            error.localizedDescription,
            domain: domain,
            action: action,
            purpose: purpose,
            isCritical: isCritical,
            payload: payload,
            correlationID: correlationID
        )
    }

    // MARK: - Public Properties

    /// Returns the created log event.
    public var logEvent: LogEvent {
        return event
    }

    // MARK: - Private Methods

    /// Sends the log message to the configured logger.
    private func send() {
        guard let logger = LogDispatcher.instance() else {
            #if DEBUG
            print("⚠️ [Letopis] Cannot send log message - LogDispatcher is not configured!")
            print("   Message: [\(event.severity)] \(event.message)")
            print("   Configure LogDispatcher at app startup: LogDispatcher.configure(with: Letopis(...))")
            #endif
            return
        }

        // Send to Letopis using internal createLogEvent method
        logger.createLogEvent(
            event.message,
            severity: event.severity,
            purpose: event.purpose,
            domain: event.domain,
            action: event.action,
            isCritical: event.isCritical,
            payload: event.payload,
            correlationID: event.correlationID
        )
    }
}

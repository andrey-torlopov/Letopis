import Foundation

/// Represents a single log event emitted by ``Letopis``.
///
/// A log event is a transport-independent contract that fully describes
/// what happened in the system. It can be sent to OSLog, files, network,
/// or analytics services.
public struct LogEvent: Codable, Sendable {
    // MARK: - Identity

    /// Unique identifier of this event instance.
    public let id: UUID

    /// Timestamp indicating when the event was created.
    public let timestamp: Date

    // MARK: - Semantics

    /// Severity level indicating how critical this event is.
    public let severity: LogSeverity

    /// Purpose or intended use of this event.
    public let purpose: LogPurpose

    /// Structured event identifier in the format "domain.action".
    /// Example: "auth.token.refresh.failed" or "ui.screen.opened"
    public let eventID: String

    /// Business domain or subsystem this event belongs to.
    /// Example: "auth", "payments", "network"
    public let domain: String

    /// Specific action or occurrence within the domain.
    /// Example: "token_refresh_failed", "screen_opened"
    public let action: String

    // MARK: - Message

    /// Human readable description of the event.
    public let message: String

    // MARK: - Context

    /// Arbitrary metadata attached to the event.
    public let payload: [String: String]

    // MARK: - Diagnostics

    /// Indicates whether the event is critical and requires immediate attention.
    public let isCritical: Bool

    // MARK: - Correlation

    /// Optional correlation ID for tracking related events across the system.
    public let correlationID: UUID?

    // MARK: - Computed Properties

    /// Visual icon representing the criticality level.
    public var criticalityIcon: String {
        isCritical ? "🛑" : ""
    }

    // MARK: - Initialization

    /// Creates a new ``LogEvent`` instance with full semantic information.
    /// - Parameters:
    ///   - id: Unique identifier used to correlate events. Defaults to a new ``UUID``.
    ///   - timestamp: Creation timestamp. Defaults to the current date.
    ///   - severity: Severity level of the event.
    ///   - purpose: Purpose or intended use of the event. Defaults to `.operational`.
    ///   - eventID: Structured event identifier. Generated from domain and action if not provided.
    ///   - domain: Business domain or subsystem. Defaults to "app".
    ///   - action: Specific action within the domain. Defaults to "event".
    ///   - message: Human readable description of the event.
    ///   - payload: Additional metadata. Defaults to empty dictionary.
    ///   - isCritical: Whether the event is critical. Defaults to `false`.
    ///   - correlationID: Optional correlation ID for tracking related events.
    public init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        severity: LogSeverity,
        purpose: LogPurpose = .operational,
        eventID: String? = nil,
        domain: String = "app",
        action: String = "event",
        message: String,
        payload: [String: String] = [:],
        isCritical: Bool = false,
        correlationID: UUID? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.severity = severity
        self.purpose = purpose
        self.domain = domain
        self.action = action
        self.eventID = eventID ?? "\(domain).\(action)"
        self.message = message
        self.payload = payload
        self.isCritical = isCritical
        self.correlationID = correlationID
    }

    /// Creates a new ``LogEvent`` instance using enum types for domain and action.
    /// - Parameters:
    ///   - id: Unique identifier used to correlate events. Defaults to a new ``UUID``.
    ///   - timestamp: Creation timestamp. Defaults to the current date.
    ///   - severity: Severity level of the event.
    ///   - purpose: Purpose or intended use of the event. Defaults to `.operational`.
    ///   - eventID: Structured event identifier. Generated from domain and action if not provided.
    ///   - domain: Business domain enum conforming to ``DomainProtocol``.
    ///   - action: Specific action enum conforming to ``ActionProtocol``.
    ///   - message: Human readable description of the event.
    ///   - payload: Additional metadata. Defaults to empty dictionary.
    ///   - isCritical: Whether the event is critical. Defaults to `false`.
    ///   - correlationID: Optional correlation ID for tracking related events.
    public init<D: DomainProtocol, A: ActionProtocol>(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        severity: LogSeverity,
        purpose: LogPurpose = .operational,
        eventID: String? = nil,
        domain: D,
        action: A,
        message: String,
        payload: [String: String] = [:],
        isCritical: Bool = false,
        correlationID: UUID? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.severity = severity
        self.purpose = purpose
        self.domain = domain.value
        self.action = action.value
        self.eventID = eventID ?? "\(domain.value).\(action.value)"
        self.message = message
        self.payload = payload
        self.isCritical = isCritical
        self.correlationID = correlationID
    }
}

import Foundation

/// Represents a single log event emitted by ``Letopis``.
public struct LogEvent: Codable, Sendable {
    /// Unique identifier of the event instance.
    public let id: UUID

    /// Timestamp indicating when the event was created.
    public let timestamp: Date

    /// Semantic type of the event (info, warning, error, etc.).
    public let type: LogEventType

    /// Indicates whether the event is critical and requires immediate attention.
    public let isCritical: Bool

    /// Human readable description of the event.
    public let message: String

    /// Arbitrary metadata attached to the event.
    public let payload: [String: String]

    /// Visual icon representing the criticality level.
    public var criticalityIcon: String {
        isCritical ? "🛑" : ""
    }

    /// Creates a new ``LogEvent`` instance.
    /// - Parameters:
    ///   - id: Unique identifier used to correlate events. Defaults to a new ``UUID``.
    ///   - timestamp: Creation timestamp. Defaults to the current date.
    ///   - type: Semantic type of the event.
    ///   - isCritical: Whether the event is critical. Defaults to `false`.
    ///   - message: Human readable description of the event.
    ///   - payload: Additional metadata that should be associated with the event.
    public init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        type: LogEventType,
        isCritical: Bool = false,
        message: String,
        payload: [String: String] = [:]
    ) {
        self.id = id
        self.timestamp = timestamp
        self.type = type
        self.isCritical = isCritical
        self.message = message
        self.payload = payload
    }
}

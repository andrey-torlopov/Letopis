import Foundation

/// Represents a single log event emitted by ``Letopis``.
public struct LogEvent: Codable, Sendable {
    /// Unique identifier of the event instance.
    public let id: UUID
    /// Timestamp indicating when the event was created.
    public let timestamp: Date
    /// Semantic type of the event (info, warning, error, etc.).
    public let type: LogEventType
    /// Priority associated with the event.
    public let priority: LogPriority
    /// Human readable description of the event.
    public let message: String
    /// Arbitrary metadata attached to the event.
    public let payload: [String: String]

    /// Creates a new ``LogEvent`` instance.
    /// - Parameters:
    ///   - id: Unique identifier used to correlate events. Defaults to a new ``UUID``.
    ///   - timestamp: Creation timestamp. Defaults to the current date.
    ///   - type: Semantic type of the event.
    ///   - priority: Priority of the event.
    ///   - message: Human readable description of the event.
    ///   - payload: Additional metadata that should be associated with the event.
    public init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        type: LogEventType,
        priority: LogPriority,
        message: String,
        payload: [String: String] = [:]
    ) {
        self.id = id
        self.timestamp = timestamp
        self.type = type
        self.priority = priority
        self.message = message
        self.payload = payload
    }
}

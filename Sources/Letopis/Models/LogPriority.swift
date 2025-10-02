import Foundation

/// Represents the urgency of a log event.
public enum LogPriority: String, Codable, Sendable{
    /// Standard priority suitable for most events.
    case `default`
    /// Critical priority used for severe situations.
    case critical
}

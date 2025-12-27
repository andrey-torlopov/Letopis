import Foundation
import OSLog

/// Severity level of a log event, mapping 1:1 to OSLog levels.
///
/// This enum represents the criticality of a log event and is independent
/// of the event's purpose (diagnostic, operational, analytics).
public enum LogSeverity: String, Codable, Sendable {
    /// Detailed diagnostic information useful during development.
    case debug = "🐞"

    /// Informational messages about normal operations.
    case info = "ℹ️"

    /// Events that are noteworthy but not problematic.
    case notice = "📌"

    /// Potentially problematic situations requiring monitoring.
    case warning = "⚠️"

    /// Error conditions that need attention.
    case error = "☠️"

    /// Critical failures requiring immediate action.
    case fault = "🔥"

    /// Maps the severity to the corresponding OSLog level.
    /// - Returns: The OSLog type that matches this severity.
    public var osLogType: OSLogType {
        switch self {
        case .debug:
            return .debug
        case .info:
            return .info
        case .notice:
            return .default
        case .warning:
            return .default
        case .error:
            return .error
        case .fault:
            return .fault
        }
    }
}

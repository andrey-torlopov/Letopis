import Foundation

/// High-level semantic categories supported by the logging system.
public enum LogEventType: String, Codable, Sendable {
    /// Informational message that does not indicate a problem.
    case info = "ℹ️"

    /// Diagnostic message used for debugging purposes.
    case debug = "🐞"

    /// Analytics event intended to be sent to analytics services for tracking user behavior and metrics.
    case analytics = "📊"

    /// Potentially problematic situation that should be monitored.
    case warning = "⚠️"

    /// Fatal error that requires immediate attention.
    case error = "☠️"
}

import Foundation

/// Purpose or intended use of a log event.
///
/// This enum represents the functional purpose of a log event,
/// independent of its severity level. The same event can have
/// different purposes depending on the context.
///
/// Example:
/// ```swift
/// // An info-level event for analytics
/// LogEvent(severity: .info, purpose: .analytics, ...)
///
/// // An error-level event for operations monitoring
/// LogEvent(severity: .error, purpose: .operational, ...)
/// ```
public enum LogPurpose: String, Codable, Sendable {
    /// Diagnostic information useful for debugging and development.
    /// Typically consumed by developers during troubleshooting.
    case diagnostic = "🔍"

    /// Operational logs for production monitoring and alerting.
    /// Used by operations teams to monitor system health.
    case operational = "⚙️"

    /// Analytics and behavioral tracking events.
    /// Used for understanding user behavior, metrics, and business intelligence.
    case analytics = "📊"
}

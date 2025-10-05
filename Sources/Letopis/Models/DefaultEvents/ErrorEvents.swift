/// Error event types for different error categories.
public enum ErrorEventType: String, EventTypeProtocol, Sendable {
    /// Data validation errors
    case validation = "validation_error"

    /// Network-related errors
    case network = "network_error"

    /// Data parsing/serialization errors
    case parsing = "parsing_error"

    /// Business logic errors
    case business = "business_error"

    /// System-level errors
    case system = "system_error"

    /// Authentication/authorization errors
    case auth = "auth_error"

    /// Database errors
    case database = "database_error"

    /// File system errors
    case fileSystem = "file_system_error"
}

/// Error action types representing different error handling stages.
public enum ErrorAction: String, EventActionProtocol, Sendable {
    /// Error occurred
    case occurred = "occurred"

    /// Error recovered successfully
    case recovered = "recovered"

    /// Retrying after error
    case retrying = "retrying"

    /// Fatal error that cannot be recovered
    case fatal = "fatal"

    /// Error ignored/suppressed
    case ignored = "ignored"

    /// Error logged for analysis
    case logged = "logged"

    /// Error handled by user action
    case handledByUser = "handled_by_user"
}

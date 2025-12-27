/// Error domains for different error categories.
public enum ErrorDomain: String, DomainProtocol, Sendable {
    /// Data validation
    case validation = "validation"

    /// Network operations
    case network = "network"

    /// Data parsing/serialization
    case parsing = "parsing"

    /// Business logic
    case business = "business"

    /// System operations
    case system = "system"

    /// Authentication/authorization
    case auth = "auth"

    /// Database operations
    case database = "database"
}

/// Error action types representing different error handling stages.
public enum ErrorAction: String, ActionProtocol, Sendable {
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

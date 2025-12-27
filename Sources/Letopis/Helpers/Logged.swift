import Foundation

/// A property wrapper that automatically logs get/set operations on a property.
///
/// Use `@Logged` to track state changes and access patterns in your application:
///
/// ```swift
/// @Logged("authToken", logger: .shared)
/// var token: String?
///
/// // When accessed or modified, logs will be automatically generated
/// token = "new_value"  // Logs: set authToken: nil → new_value
/// let current = token   // Logs: get authToken = new_value
/// ```
///
/// The wrapper integrates with Letopis's domain/action system for structured logging.
@propertyWrapper
public struct Logged<Value> {
    private var value: Value
    private let name: String
    private let logger: Letopis
    private let domain: any DomainProtocol
    private let action: any ActionProtocol

    /// Creates a logged property wrapper with custom domain and action.
    /// - Parameters:
    ///   - wrappedValue: Initial value of the property.
    ///   - name: Display name for logging.
    ///   - logger: Letopis instance to use for logging.
    ///   - domain: Business domain for the log events. Defaults to DefaultDomain.state.
    ///   - action: Action type for the log events. Defaults to DefaultAction.access.
    public init(
        wrappedValue: Value,
        _ name: String,
        logger: Letopis,
        domain: any DomainProtocol = DefaultDomain.state,
        action: any ActionProtocol = DefaultAction.read
    ) {
        self.value = wrappedValue
        self.name = name
        self.logger = logger
        self.domain = domain
        self.action = action

        logger
            .domain(domain)
            .action(action)
            .payload([
                "property": name,
                "operation": "init",
                "value": "\(wrappedValue)"
            ])
            .debug("Property initialized")
    }

    public var wrappedValue: Value {
        get {
            logger
                .domain(domain)
                .action(action)
                .payload([
                    "property": name,
                    "operation": "get",
                    "value": "\(value)"
                ])
                .debug("Property accessed")
            return value
        }
        set {
            logger
                .domain(domain)
                .action(action)
                .payload([
                    "property": name,
                    "operation": "set",
                    "old_value": "\(value)",
                    "new_value": "\(newValue)"
                ])
                .debug("Property updated")
            value = newValue
        }
    }
}

/// A property wrapper that logs only set operations (useful for performance-sensitive scenarios).
///
/// Use `@LoggedSet` when you only care about mutations, not reads:
///
/// ```swift
/// @LoggedSet("userName", logger: .shared)
/// var userName: String = ""
///
/// userName = "john_doe"  // Logs the change
/// let name = userName    // No log generated
/// ```
@propertyWrapper
public struct LoggedSet<Value> {
    private var value: Value
    private let name: String
    private let logger: Letopis
    private let domain: any DomainProtocol
    private let action: any ActionProtocol

    /// Creates a logged set-only property wrapper.
    /// - Parameters:
    ///   - wrappedValue: Initial value of the property.
    ///   - name: Display name for logging.
    ///   - logger: Letopis instance to use for logging.
    ///   - domain: Business domain for the log events. Defaults to DefaultDomain.state.
    ///   - action: Action type for the log events. Defaults to DefaultAction.mutation.
    public init(
        wrappedValue: Value,
        _ name: String,
        logger: Letopis,
        domain: any DomainProtocol = DefaultDomain.state,
        action: any ActionProtocol = DefaultAction.updated
    ) {
        self.value = wrappedValue
        self.name = name
        self.logger = logger
        self.domain = domain
        self.action = action
    }

    public var wrappedValue: Value {
        get {
            return value
        }
        set {
            logger
                .domain(domain)
                .action(action)
                .payload([
                    "property": name,
                    "old_value": "\(value)",
                    "new_value": "\(newValue)"
                ])
                .info("Property mutated")
            value = newValue
        }
    }
}

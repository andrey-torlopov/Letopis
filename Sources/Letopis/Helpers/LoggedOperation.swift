import Foundation

/// A scope-based helper for automatic logging of async operations.
///
/// This helper logs the start and completion of async operations, including errors:
///
/// ```swift
/// let user = try await Letopis.logged(
///     "fetchUser",
///     logger: .shared,
///     domain: "api",
///     action: "fetch"
/// ) {
///     await apiClient.fetchUser()
/// }
/// ```
///
/// The operation will automatically log:
/// - When the operation starts
/// - When it completes successfully
/// - If it throws an error
extension Letopis {
    /// Executes an async throwing operation with automatic logging.
    /// - Parameters:
    ///   - operationName: Display name for the operation.
    ///   - logger: Letopis instance to use for logging.
    ///   - domain: Business domain for log events.
    ///   - startAction: Action name for start event.
    ///   - completeAction: Action name for completion event.
    ///   - errorAction: Action name for error event.
    ///   - operation: The async operation to execute.
    /// - Returns: Result of the operation.
    /// - Throws: Any error thrown by the operation.
    public static func logged<T, D: DomainProtocol, A: ActionProtocol>(
        _ operationName: String,
        logger: Letopis,
        domain: D,
        startAction: A,
        completeAction: A,
        errorAction: A,
        operation: () async throws -> T
    ) async rethrows -> T {
        logger
            .domain(domain)
            .action(startAction)
            .payload(["operation": operationName])
            .debug("Operation started")

        do {
            let result = try await operation()
            logger
                .domain(domain)
                .action(completeAction)
                .payload(["operation": operationName])
                .debug("Operation completed")
            return result
        } catch {
            logger
                .domain(domain)
                .action(errorAction)
                .payload([
                    "operation": operationName,
                    "error": error.localizedDescription
                ])
                .error("Operation failed")
            throw error
        }
    }

    /// Executes a non-throwing async operation with automatic logging.
    /// - Parameters:
    ///   - operationName: Display name for the operation.
    ///   - logger: Letopis instance to use for logging.
    ///   - domain: Business domain for log events.
    ///   - startAction: Action name for start event.
    ///   - completeAction: Action name for completion event.
    ///   - operation: The async operation to execute.
    /// - Returns: Result of the operation.
    public static func logged<T, D: DomainProtocol, A: ActionProtocol>(
        _ operationName: String,
        logger: Letopis,
        domain: D,
        startAction: A,
        completeAction: A,
        operation: () async -> T
    ) async -> T {
        logger
            .domain(domain)
            .action(startAction)
            .payload(["operation": operationName])
            .debug("Operation started")

        let result = await operation()

        logger
            .domain(domain)
            .action(completeAction)
            .payload(["operation": operationName])
            .debug("Operation completed")

        return result
    }

    /// Executes a throwing synchronous operation with automatic logging.
    /// - Parameters:
    ///   - operationName: Display name for the operation.
    ///   - logger: Letopis instance to use for logging.
    ///   - domain: Business domain for log events.
    ///   - startAction: Action name for start event.
    ///   - completeAction: Action name for completion event.
    ///   - errorAction: Action name for error event.
    ///   - operation: The synchronous operation to execute.
    /// - Returns: Result of the operation.
    /// - Throws: Any error thrown by the operation.
    public static func logged<T, D: DomainProtocol, A: ActionProtocol>(
        _ operationName: String,
        logger: Letopis,
        domain: D,
        startAction: A,
        completeAction: A,
        errorAction: A,
        operation: () throws -> T
    ) rethrows -> T {
        logger
            .domain(domain)
            .action(startAction)
            .payload(["operation": operationName])
            .debug("Operation started")

        do {
            let result = try operation()
            logger
                .domain(domain)
                .action(completeAction)
                .payload(["operation": operationName])
                .debug("Operation completed")
            return result
        } catch {
            logger
                .domain(domain)
                .action(errorAction)
                .payload([
                    "operation": operationName,
                    "error": error.localizedDescription
                ])
                .error("Operation failed")
            throw error
        }
    }

    // MARK: - Convenience overloads with default actions

    /// Convenience overload with default actions for async throwing operations
    public static func logged<T>(
        _ operationName: String,
        logger: Letopis,
        domain: any DomainProtocol = DefaultDomain.async,
        operation: () async throws -> T
    ) async rethrows -> T {
        try await logged(
            operationName,
            logger: logger,
            domain: domain,
            startAction: DefaultAction.started,
            completeAction: DefaultAction.completed,
            errorAction: DefaultAction.failed,
            operation: operation
        )
    }

    /// Convenience overload with default actions for async non-throwing operations
    public static func logged<T>(
        _ operationName: String,
        logger: Letopis,
        domain: any DomainProtocol = DefaultDomain.async,
        operation: () async -> T
    ) async -> T {
        await logged(
            operationName,
            logger: logger,
            domain: domain,
            startAction: DefaultAction.started,
            completeAction: DefaultAction.completed,
            operation: operation
        )
    }

    /// Convenience overload with default actions for synchronous throwing operations
    public static func logged<T>(
        _ operationName: String,
        logger: Letopis,
        domain: any DomainProtocol = DefaultDomain.async,
        operation: () throws -> T
    ) rethrows -> T {
        try logged(
            operationName,
            logger: logger,
            domain: domain,
            startAction: DefaultAction.started,
            completeAction: DefaultAction.completed,
            errorAction: DefaultAction.failed,
            operation: operation
        )
    }
}

// MARK: - Global convenience functions

/// Global convenience function for logging async throwing operations.
///
/// Usage:
/// ```swift
/// let data = try await logged("fetchData", logger: .shared, domain: .operation) {
///     await api.fetchData()
/// }
/// ```
public func logged<T>(
    _ operationName: String,
    logger: Letopis,
    domain: any DomainProtocol = DefaultDomain.async,
    operation: () async throws -> T
) async rethrows -> T {
    try await Letopis.logged(
        operationName,
        logger: logger,
        domain: domain,
        operation: operation
    )
}

/// Global convenience function for logging async non-throwing operations.
public func logged<T>(
    _ operationName: String,
    logger: Letopis,
    domain: any DomainProtocol = DefaultDomain.async,
    operation: () async -> T
) async -> T {
    await Letopis.logged(
        operationName,
        logger: logger,
        domain: domain,
        operation: operation
    )
}

/// Global convenience function for logging synchronous throwing operations.
public func logged<T>(
    _ operationName: String,
    logger: Letopis,
    domain: any DomainProtocol = DefaultDomain.async,
    operation: () throws -> T
) rethrows -> T {
    try Letopis.logged(
        operationName,
        logger: logger,
        domain: domain,
        operation: operation
    )
}

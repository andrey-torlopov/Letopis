#if canImport(Combine)
import Combine
import Foundation

extension Publisher {
    /// Logs lifecycle events of a Combine publisher (subscription, output, completion).
    ///
    /// Use this operator to track publisher behavior in your reactive chains:
    ///
    /// ```swift
    /// userPublisher
    ///     .logged("userUpdates", logger: .shared, domain: "user")
    ///     .sink { completion in
    ///         // handle completion
    ///     } receiveValue: { user in
    ///         // handle user
    ///     }
    /// ```
    ///
    /// - Parameters:
    ///   - name: Display name for the publisher in logs.
    ///   - logger: Letopis instance to use for logging.
    ///   - domain: Business domain for log events.
    ///   - subscribeAction: Action for subscription events.
    ///   - outputAction: Action for output events.
    ///   - completionAction: Action for completion events.
    ///   - logOutput: Whether to log each output value. Defaults to true.
    /// - Returns: Publisher with logging behavior injected.
    public func logged<D: DomainProtocol, A: ActionProtocol>(
        _ name: String,
        logger: Letopis,
        domain: D,
        subscribeAction: A,
        outputAction: A,
        completionAction: A,
        logOutput: Bool = true
    ) -> Publishers.HandleEvents<Self> {
        handleEvents(
            receiveSubscription: { _ in
                logger
                    .domain(domain)
                    .action(subscribeAction)
                    .payload(["publisher": name])
                    .debug("Publisher subscribed")
            },
            receiveOutput: { output in
                if logOutput {
                    logger
                        .domain(domain)
                        .action(outputAction)
                        .payload([
                            "publisher": name,
                            "value": "\(output)"
                        ])
                        .debug("Publisher emitted value")
                }
            },
            receiveCompletion: { completion in
                switch completion {
                case .finished:
                    logger
                        .domain(domain)
                        .action(completionAction)
                        .payload([
                            "publisher": name,
                            "status": "finished"
                        ])
                        .debug("Publisher finished")
                case .failure(let error):
                    logger
                        .domain(domain)
                        .action(completionAction)
                        .payload([
                            "publisher": name,
                            "status": "failed",
                            "error": "\(error)"
                        ])
                        .error("Publisher failed")
                }
            },
            receiveCancel: {
                logger
                    .domain(domain)
                    .action(DefaultAction.cancelled)
                    .payload(["publisher": name])
                    .debug("Publisher cancelled")
            }
        )
    }

    /// Convenience overload with default actions
    public func logged(
        _ name: String,
        logger: Letopis,
        domain: any DomainProtocol = DefaultDomain.combine,
        logOutput: Bool = true
    ) -> Publishers.HandleEvents<Self> {
        logged(
            name,
            logger: logger,
            domain: domain,
            subscribeAction: DefaultAction.subscribed,
            outputAction: DefaultAction.output,
            completionAction: DefaultAction.completed,
            logOutput: logOutput
        )
    }

    /// Logs only errors from a Combine publisher.
    ///
    /// Useful when you only care about failures:
    ///
    /// ```swift
    /// apiPublisher
    ///     .logErrors("apiRequest", logger: .shared)
    /// ```
    ///
    /// - Parameters:
    ///   - name: Display name for the publisher in logs.
    ///   - logger: Letopis instance to use for logging.
    ///   - domain: Business domain for log events.
    /// - Returns: Publisher with error logging behavior.
    public func logErrors(
        _ name: String,
        logger: Letopis,
        domain: any DomainProtocol = DefaultDomain.combine
    ) -> Publishers.HandleEvents<Self> {
        handleEvents(
            receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    logger
                        .domain(domain)
                        .action(DefaultAction.failed)
                        .payload([
                            "publisher": name,
                            "error": "\(error)"
                        ])
                        .error("Publisher failed")
                }
            }
        )
    }

    /// Logs subscription and completion events only (not output values).
    ///
    /// Useful for performance-sensitive scenarios:
    ///
    /// ```swift
    /// dataStream
    ///     .logLifecycle("dataStream", logger: .shared)
    /// ```
    ///
    /// - Parameters:
    ///   - name: Display name for the publisher in logs.
    ///   - logger: Letopis instance to use for logging.
    ///   - domain: Business domain for log events.
    ///   - subscribeAction: Action for subscription events.
    ///   - outputAction: Action for output events.
    ///   - completionAction: Action for completion events.
    /// - Returns: Publisher with lifecycle logging behavior.
    public func logLifecycle<D: DomainProtocol, A: ActionProtocol>(
        _ name: String,
        logger: Letopis,
        domain: D,
        subscribeAction: A,
        outputAction: A,
        completionAction: A
    ) -> Publishers.HandleEvents<Self> {
        logged(name, logger: logger, domain: domain, subscribeAction: subscribeAction, outputAction: outputAction, completionAction: completionAction, logOutput: false)
    }

    /// Convenience overload with default actions
    public func logLifecycle(
        _ name: String,
        logger: Letopis,
        domain: any DomainProtocol = DefaultDomain.combine
    ) -> Publishers.HandleEvents<Self> {
        logLifecycle(
            name,
            logger: logger,
            domain: domain,
            subscribeAction: DefaultAction.subscribed,
            outputAction: DefaultAction.output,
            completionAction: DefaultAction.completed
        )
    }
}

#endif

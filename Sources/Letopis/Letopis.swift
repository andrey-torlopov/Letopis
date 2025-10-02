import Foundation

/// Central entry point for creating log events and dispatching them to registered interceptors.
public final class Letopis: @unchecked Sendable {
    private var healthTrackers: [InterceptorHealthTracker] = []
    private var recoveryTimer: Timer?

    /// Creates a new instance of ``Letopis``.
    /// - Parameters:
    ///   - interceptors: Initial list of interceptors that will handle log events.
    ///   - healthCheckInterval: Interval in seconds between health checks for failed interceptors. Defaults to 30.0 seconds. Set to 0 to disable automatic health checks.
    public init(interceptors: [LetopisInterceptor] = [], healthCheckInterval: TimeInterval = 30.0) {
        self.healthTrackers = interceptors.map { InterceptorHealthTracker(interceptor: $0) }
        self.recoveryTimer = nil

        // Start recovery timer after initialization if interval > 0
        if healthCheckInterval > 0 {
            self.recoveryTimer = Timer.scheduledTimer(withTimeInterval: healthCheckInterval, repeats: true) { [weak self] _ in
                self?.performHealthChecks()
            }
        }
    }

    deinit {
        recoveryTimer?.invalidate()
    }

    /// Adds a new interceptor to the dispatch list.
    /// - Parameter interceptor: Object conforming to ``LetopisInterceptor`` that should receive log events.
    public func addInterceptor(_ interceptor: LetopisInterceptor) {
        let tracker = InterceptorHealthTracker(interceptor: interceptor)
        healthTrackers.append(tracker)
    }

    /// Creates a raw log event, forwards it to interceptors and returns the created event.
    /// - Parameters:
    ///   - message: Descriptive message associated with the event.
    ///   - type: Semantic type of the event.
    ///   - priority: Priority of the event. Defaults to ``LogPriority/default``.
    ///   - payload: Additional metadata that should accompany the event.
    /// - Returns: Fully constructed ``LogEvent``.
    @discardableResult
    func createLogEvent(
        _ message: String,
        type: LogEventType,
        priority: LogPriority = .default,
        payload: [String: String] = [:]
    ) -> LogEvent {
        let event = LogEvent(
            type: type,
            priority: priority,
            message: message,
            payload: payload
        )
        notifyInterceptors(with: event)
        return event
    }

    /// Iterates through the registered interceptors and forwards the provided event.
    /// - Parameter event: Event that should be delivered to interceptors.
    private func notifyInterceptors(with event: LogEvent) {
        guard healthTrackers.isEmpty == false else {
            print("⚠️ Letopis interceptors is empty!")
            return
        }

        Task {
            await withTaskGroup(of: Void.self) { group in
                for tracker in healthTrackers {
                    guard tracker.canHandleEvents else { continue }

                    group.addTask {
                        do {
                            try await tracker.interceptor.handle(event)
                            tracker.recordSuccess()
                        } catch {
                            tracker.recordFailure()
                            #if DEBUG
                            // Optionally log the failure
                            print("⚠️  Interceptor failed to handle event: \(error)")
                            #endif
                        }
                    }
                }
            }
        }
    }

    /// Performs health checks and recovery attempts for failed interceptors.
    private func performHealthChecks() {
        Task {
            for tracker in healthTrackers {
                if tracker.shouldAttemptRecovery() {
                    let recovered = await tracker.attemptRecovery()
                    if recovered {
                        print("✅ Interceptor recovered successfully")
                    } else if tracker.isPermanentlyFailed {
                        print("❌ Interceptor permanently failed after maximum recovery attempts")
                    }
                }
            }
        }
    }

    /// Merges optional metadata into a single payload dictionary used in log events.
    /// - Parameters:
    ///   - payload: Payload provided by the caller.
    ///   - eventType: Optional high-level event type.
    ///   - eventAction: Optional action that describes the event.
    /// - Returns: A normalized payload dictionary.
    private func combinePayload(
        payload: [String: String]?,
        eventType: (any EventTypeProtocol)?,
        eventAction: (any EventActionProtocol)?
    ) -> [String: String] {
        var updatedPayload = payload ?? [:]

        if let eventType {
            updatedPayload["event_type"] = eventType.value
        }

        if let eventAction {
            updatedPayload["event_action"] = eventAction.value
        }

        return updatedPayload.isEmpty ? [:] : updatedPayload
    }

    /// Creates an informational log event.
    /// - Parameters:
    ///   - message: Descriptive message to log.
    ///   - priority: Priority of the event. Defaults to ``LogPriority/default``.
    ///   - payload: Additional metadata for the event.
    ///   - eventType: Optional high-level classification of the event.
    ///   - eventAction: Optional action performed during the event.
    /// - Returns: Created ``LogEvent`` instance.
    @discardableResult
    public func info(
        _ message: String,
        priority: LogPriority = .default,
        payload: [String: String]? = nil,
        eventType: (any EventTypeProtocol)? = nil,
        eventAction: (any EventActionProtocol)? = nil
    ) -> LogEvent {
        createLogEvent(
            message,
            type: .info,
            priority: priority,
            payload: combinePayload(payload: payload, eventType: eventType, eventAction: eventAction)
        )
    }

    /// Creates a warning log event.
    /// - Parameters:
    ///   - message: Descriptive message to log.
    ///   - priority: Priority of the event. Defaults to ``LogPriority/default``.
    ///   - payload: Additional metadata for the event.
    ///   - eventType: Optional high-level classification of the event.
    ///   - eventAction: Optional action performed during the event.
    /// - Returns: Created ``LogEvent`` instance.
    @discardableResult
    public func warning(
        _ message: String,
        priority: LogPriority = .default,
        payload: [String: String]? = nil,
        eventType: (any EventTypeProtocol)? = nil,
        eventAction: (any EventActionProtocol)? = nil
    ) -> LogEvent {
        createLogEvent(
            message,
            type: .warning,
            priority: priority,
            payload: combinePayload(payload: payload, eventType: eventType, eventAction: eventAction)
        )
    }

    /// Creates an error log event from a descriptive message.
    /// - Parameters:
    ///   - message: Descriptive message to log.
    ///   - priority: Priority of the event. Defaults to ``LogPriority/critical``.
    ///   - payload: Additional metadata for the event.
    ///   - eventType: Optional high-level classification of the event.
    ///   - eventAction: Optional action performed during the event.
    /// - Returns: Created ``LogEvent`` instance.
    @discardableResult
    public func error(
        _ message: String,
        priority: LogPriority = .critical,
        payload: [String: String]? = nil,
        eventType: (any EventTypeProtocol)? = nil,
        eventAction: (any EventActionProtocol)? = nil
    ) -> LogEvent {
        createLogEvent(
            message,
            type: .error,
            priority: priority,
            payload: combinePayload(payload: payload, eventType: eventType, eventAction: eventAction)
        )
    }

    /// Creates an error log event from an ``Error`` instance.
    /// - Parameters:
    ///   - error: Error to log.
    ///   - priority: Priority of the event. Defaults to ``LogPriority/critical``.
    ///   - payload: Additional metadata for the event.
    ///   - eventType: Optional high-level classification of the event.
    ///   - eventAction: Optional action performed during the event.
    /// - Returns: Created ``LogEvent`` instance.
    @discardableResult
    public func error(
        _ error: Error,
        priority: LogPriority = .critical,
        payload: [String: String]? = nil,
        eventType: (any EventTypeProtocol)? = nil,
        eventAction: (any EventActionProtocol)? = nil
    ) -> LogEvent {
        createLogEvent(
            error.localizedDescription,
            type: .error,
            priority: priority,
            payload: combinePayload(payload: payload, eventType: eventType, eventAction: eventAction)
        )
    }

    /// Creates a debug log event.
    /// - Parameters:
    ///   - message: Descriptive message to log.
    ///   - priority: Priority of the event. Defaults to ``LogPriority/default``.
    ///   - payload: Additional metadata for the event.
    ///   - eventType: Optional high-level classification of the event.
    ///   - eventAction: Optional action performed during the event.
    /// - Returns: Created ``LogEvent`` instance.
    @discardableResult
    public func debug(
        _ message: String,
        priority: LogPriority = .default,
        payload: [String: String]? = nil,
        eventType: (any EventTypeProtocol)? = nil,
        eventAction: (any EventActionProtocol)? = nil
    ) -> LogEvent {
        createLogEvent(
            message,
            type: .debug,
            priority: priority,
            payload: combinePayload(payload: payload, eventType: eventType, eventAction: eventAction)
        )
    }

    /// Creates an analytics log event intended for analytics services.
    /// - Parameters:
    ///   - message: Descriptive message to log.
    ///   - priority: Priority of the event. Defaults to ``LogPriority/default``.
    ///   - payload: Additional metadata for the event.
    ///   - eventType: Optional high-level classification of the event.
    ///   - eventAction: Optional action performed during the event.
    /// - Returns: Created ``LogEvent`` instance.
    @discardableResult
    public func analytics(
        _ message: String,
        priority: LogPriority = .default,
        payload: [String: String]? = nil,
        eventType: (any EventTypeProtocol)? = nil,
        eventAction: (any EventActionProtocol)? = nil
    ) -> LogEvent {
        createLogEvent(
            message,
            type: .analytics,
            priority: priority,
            payload: combinePayload(payload: payload, eventType: eventType, eventAction: eventAction)
        )
    }

    /// Returns the current health status of all interceptors.
    /// - Returns: Array of tuples containing interceptor type and health state.
    public func getInterceptorHealthStatus() -> [(type: String, state: InterceptorHealthState, canHandle: Bool)] {
        return healthTrackers.map { tracker in
            let typeName = String(describing: type(of: tracker.interceptor))
            return (type: typeName, state: tracker.state, canHandle: tracker.canHandleEvents)
        }
    }

    /// Returns the number of healthy interceptors.
    public var healthyInterceptorsCount: Int {
        return healthTrackers.filter { $0.canHandleEvents }.count
    }

    /// Returns the total number of interceptors.
    public var totalInterceptorsCount: Int {
        return healthTrackers.count
    }

    /// Manually triggers health checks for all interceptors.
    public func triggerHealthChecks() {
        performHealthChecks()
    }
}

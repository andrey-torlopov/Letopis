import Foundation

/// Central entry point for creating log events and dispatching them to registered interceptors.
public final class Letopis: @unchecked Sendable {

    // MARK: - Public Properties

    /// Global list of sensitive keys that should be masked in all logs
    public private(set) var sensitiveKeys: Set<String> = []

    /// Returns the number of healthy interceptors.
    public var healthyInterceptorsCount: Int {
        return healthTrackers.filter { $0.canHandleEvents }.count
    }

    /// Returns the total number of interceptors.
    public var totalInterceptorsCount: Int {
        return healthTrackers.count
    }

    // MARK: - Private Properties

    private var healthTrackers: [InterceptorHealthTracker] = []
    private var recoveryTimer: Timer?

    // MARK: - Initialization

    /// Creates a new instance of ``Letopis``.
    /// - Parameters:
    ///   - interceptors: Initial list of interceptors that will handle log events.
    ///   - healthCheckInterval: Interval in seconds between health checks for failed interceptors. Defaults to 30.0 seconds. Set to 0 to disable automatic health checks.
    ///   - sensitiveKeys: Global list of keys that should be masked in all log payloads (case-insensitive).
    public init(interceptors: [LetopisInterceptor] = [], healthCheckInterval: TimeInterval = 30.0, sensitiveKeys: [String] = []) {
        self.healthTrackers = interceptors.map { InterceptorHealthTracker(interceptor: $0) }
        self.recoveryTimer = nil
        self.sensitiveKeys = Set(sensitiveKeys.map { $0.lowercased() })

        // Start recovery timer after initialization if interval > 0
        if healthCheckInterval > 0 {
            let timer = Timer.scheduledTimer(withTimeInterval: healthCheckInterval, repeats: true) { [weak self] _ in
                self?.performHealthChecks()
            }
            self.recoveryTimer = timer
            RunLoop.current.add(timer, forMode: .common)
        }
    }

    deinit {
        recoveryTimer?.invalidate()
    }

    // MARK: - Public Methods

    /// Adds a new interceptor to the dispatch list.
    /// - Parameter interceptor: Object conforming to ``LetopisInterceptor`` that should receive log events.
    public func addInterceptor(_ interceptor: LetopisInterceptor) {
        let tracker = InterceptorHealthTracker(interceptor: interceptor)
        healthTrackers.append(tracker)
    }

    /// Creates and sends a log event with all parameters specified directly.
    /// - Parameters:
    ///   - message: Message for the log event.
    ///   - severity: Severity level of the event.
    ///   - purpose: Purpose of the event. Defaults to `.operational`.
    ///   - domain: Business domain or subsystem. Defaults to "app".
    ///   - action: Specific action within the domain. Defaults to "event".
    ///   - isCritical: Whether the event is critical. Defaults to `false`.
    ///   - payload: Additional metadata. Defaults to empty dictionary.
    ///   - correlationID: Optional correlation ID for tracking related events.
    /// - Returns: The created ``LogEvent``.
    @discardableResult
    public func logEvent(
        _ message: String,
        severity: LogSeverity,
        purpose: LogPurpose = .operational,
        domain: DomainProtocol,
        action: ActionProtocol,
        isCritical: Bool = false,
        payload: [String: String] = [:],
        correlationID: UUID? = nil
    ) -> LogEvent {
        return createLogEvent(
            message,
            severity: severity,
            purpose: purpose,
            domain: domain,
            action: action,
            isCritical: isCritical,
            payload: payload,
            correlationID: correlationID
        )
    }

    /// Returns the current health status of all interceptors.
    /// - Returns: Array of tuples containing interceptor type and health state.
    public func getInterceptorHealthStatus() -> [(type: String, state: InterceptorHealthState, canHandle: Bool)] {
        return healthTrackers.map { tracker in
            return (type: tracker.interceptor.name, state: tracker.state, canHandle: tracker.canHandleEvents)
        }
    }

    /// Manually triggers health checks for all interceptors.
    public func triggerHealthChecks() {
        performHealthChecks()
    }

    /// Adds sensitive keys to the global list
    /// - Parameter keys: Keys to add to the sensitive keys list
    public func addSensitiveKeys(_ keys: [String]) {
        sensitiveKeys.formUnion(keys.map { $0.lowercased() })
    }

    /// Removes sensitive keys from the global list
    /// - Parameter keys: Keys to remove from the sensitive keys list
    public func removeSensitiveKeys(_ keys: [String]) {
        sensitiveKeys.subtract(keys.map { $0.lowercased() })
    }

    // MARK: - Internal Methods

    /// Creates a raw log event with severity and purpose, forwards it to interceptors and returns the created event.
    /// - Parameters:
    ///   - message: Descriptive message associated with the event.
    ///   - severity: Severity level of the event.
    ///   - purpose: Purpose of the event.
    ///   - domain: Business domain or subsystem.
    ///   - action: Specific action within the domain.
    ///   - isCritical: Whether the event is critical. Defaults to `false`.
    ///   - payload: Additional metadata that should accompany the event.
    ///   - correlationID: Optional correlation ID for tracking related events.
    /// - Returns: Fully constructed ``LogEvent``.
    @discardableResult
    internal func createLogEvent(
        _ message: String,
        severity: LogSeverity,
        purpose: LogPurpose = .operational,
        domain: DomainProtocol,
        action: ActionProtocol,
        isCritical: Bool = false,
        payload: [String: String] = [:],
        correlationID: UUID? = nil
    ) -> LogEvent {
        let event = LogEvent(
            severity: severity,
            purpose: purpose,
            domain: domain,
            action: action,
            message: message,
            payload: payload,
            isCritical: isCritical,
            correlationID: correlationID
        )
        Task.detached(priority: .userInitiated) { await self.notifyInterceptors(with: event) }
        return event
    }

    /// Creates a raw log event with severity and purpose using string domain and action.
    /// - Parameters:
    ///   - message: Descriptive message associated with the event.
    ///   - severity: Severity level of the event.
    ///   - purpose: Purpose of the event.
    ///   - domain: Business domain or subsystem as a string.
    ///   - action: Specific action within the domain as a string.
    ///   - isCritical: Whether the event is critical. Defaults to `false`.
    ///   - payload: Additional metadata that should accompany the event.
    ///   - correlationID: Optional correlation ID for tracking related events.
    /// - Returns: Fully constructed ``LogEvent``.
    @discardableResult
    internal func createLogEvent(
        _ message: String,
        severity: LogSeverity,
        purpose: LogPurpose = .operational,
        domain: String,
        action: String,
        isCritical: Bool = false,
        payload: [String: String] = [:],
        correlationID: UUID? = nil
    ) -> LogEvent {
        let event = LogEvent(
            severity: severity,
            purpose: purpose,
            domain: domain,
            action: action,
            message: message,
            payload: payload,
            isCritical: isCritical,
            correlationID: correlationID
        )
        Task.detached(priority: .userInitiated) { await self.notifyInterceptors(with: event) }
        return event
    }

    /// Merges optional metadata into a single payload dictionary used in log events.
    /// - Parameters:
    ///   - payload: Payload provided by the caller.
    ///   - eventType: Optional high-level event type.
    ///   - eventAction: Optional action that describes the event.
    ///   - includeSource: Whether to include source code location metadata.
    ///   - file: Source file path.
    ///   - function: Function name.
    ///   - line: Line number.
    /// - Returns: A normalized payload dictionary.
    internal func combinePayload(
        payload: [String: String]?,
        eventType: (any EventTypeProtocol)?,
        eventAction: (any ActionProtocol)?,
        includeSource: Bool = false,
        file: String = "",
        function: String = "",
        line: Int = 0
    ) -> [String: String] {
        var updatedPayload = payload ?? [:]

        if let eventType {
            updatedPayload["event_type"] = eventType.value
        }

        if let eventAction {
            updatedPayload["event_action"] = eventAction.value
        }

        if includeSource {
            let fileName = (file as NSString).lastPathComponent
            updatedPayload["source_file"] = fileName
            updatedPayload["source_function"] = function
            updatedPayload["source_line"] = String(line)
        }

        return updatedPayload.isEmpty ? [:] : updatedPayload
    }
}

// MARK: - Private Methods

private extension Letopis {
    /// Iterates through the registered interceptors and forwards the provided event.
    /// - Parameter event: Event that should be delivered to interceptors.
    func notifyInterceptors(with event: LogEvent) async {
        guard healthTrackers.isEmpty == false else {
            print("⚠️ Letopis interceptors is empty!")
            return
        }

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

    /// Performs health checks and recovery attempts for failed interceptors.
    func performHealthChecks() {
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
}

// MARK: - Convenience Logging Methods

public extension Letopis {
    /// Logs a debug-level message.
    /// - Parameters:
    ///   - message: The message to log.
    ///   - domain: Business domain or subsystem. Defaults to empty.
    ///   - action: Specific action within the domain. Defaults to empty.
    ///   - purpose: Purpose of the event. Defaults to `.operational`.
    ///   - isCritical: Whether the event is critical. Defaults to `false`.
    ///   - payload: Additional metadata. Defaults to empty dictionary.
    ///   - correlationID: Optional correlation ID for tracking related events.
    /// - Returns: The created ``LogEvent``.
    @discardableResult
    func debug(
        _ message: String,
        domain: String = "",
        action: String = "",
        purpose: LogPurpose = .operational,
        isCritical: Bool = false,
        payload: [String: String] = [:],
        correlationID: UUID? = nil
    ) -> LogEvent {
        return createLogEvent(
            message,
            severity: .debug,
            purpose: purpose,
            domain: domain.isEmpty ? DefaultDomain.empty.value : domain,
            action: action.isEmpty ? DefaultAction.empty.value : action,
            isCritical: isCritical,
            payload: payload,
            correlationID: correlationID
        )
    }

    /// Logs an info-level message.
    /// - Parameters:
    ///   - message: The message to log.
    ///   - domain: Business domain or subsystem. Defaults to empty.
    ///   - action: Specific action within the domain. Defaults to empty.
    ///   - purpose: Purpose of the event. Defaults to `.operational`.
    ///   - isCritical: Whether the event is critical. Defaults to `false`.
    ///   - payload: Additional metadata. Defaults to empty dictionary.
    ///   - correlationID: Optional correlation ID for tracking related events.
    /// - Returns: The created ``LogEvent``.
    @discardableResult
    func info(
        _ message: String,
        domain: String = "",
        action: String = "",
        purpose: LogPurpose = .operational,
        isCritical: Bool = false,
        payload: [String: String] = [:],
        correlationID: UUID? = nil
    ) -> LogEvent {
        return createLogEvent(
            message,
            severity: .info,
            purpose: purpose,
            domain: domain.isEmpty ? DefaultDomain.empty.value : domain,
            action: action.isEmpty ? DefaultAction.empty.value : action,
            isCritical: isCritical,
            payload: payload,
            correlationID: correlationID
        )
    }

    /// Logs a notice-level message.
    /// - Parameters:
    ///   - message: The message to log.
    ///   - domain: Business domain or subsystem. Defaults to empty.
    ///   - action: Specific action within the domain. Defaults to empty.
    ///   - purpose: Purpose of the event. Defaults to `.operational`.
    ///   - isCritical: Whether the event is critical. Defaults to `false`.
    ///   - payload: Additional metadata. Defaults to empty dictionary.
    ///   - correlationID: Optional correlation ID for tracking related events.
    /// - Returns: The created ``LogEvent``.
    @discardableResult
    func notice(
        _ message: String,
        domain: String = "",
        action: String = "",
        purpose: LogPurpose = .operational,
        isCritical: Bool = false,
        payload: [String: String] = [:],
        correlationID: UUID? = nil
    ) -> LogEvent {
        return createLogEvent(
            message,
            severity: .notice,
            purpose: purpose,
            domain: domain.isEmpty ? DefaultDomain.empty.value : domain,
            action: action.isEmpty ? DefaultAction.empty.value : action,
            isCritical: isCritical,
            payload: payload,
            correlationID: correlationID
        )
    }

    /// Logs a warning-level message.
    /// - Parameters:
    ///   - message: The message to log.
    ///   - domain: Business domain or subsystem. Defaults to empty.
    ///   - action: Specific action within the domain. Defaults to empty.
    ///   - purpose: Purpose of the event. Defaults to `.operational`.
    ///   - isCritical: Whether the event is critical. Defaults to `false`.
    ///   - payload: Additional metadata. Defaults to empty dictionary.
    ///   - correlationID: Optional correlation ID for tracking related events.
    /// - Returns: The created ``LogEvent``.
    @discardableResult
    func warning(
        _ message: String,
        domain: String = "",
        action: String = "",
        purpose: LogPurpose = .operational,
        isCritical: Bool = false,
        payload: [String: String] = [:],
        correlationID: UUID? = nil
    ) -> LogEvent {
        return createLogEvent(
            message,
            severity: .warning,
            purpose: purpose,
            domain: domain.isEmpty ? DefaultDomain.empty.value : domain,
            action: action.isEmpty ? DefaultAction.empty.value : action,
            isCritical: isCritical,
            payload: payload,
            correlationID: correlationID
        )
    }

    /// Logs an error-level message.
    /// - Parameters:
    ///   - message: The message to log.
    ///   - domain: Business domain or subsystem. Defaults to empty.
    ///   - action: Specific action within the domain. Defaults to empty.
    ///   - purpose: Purpose of the event. Defaults to `.operational`.
    ///   - isCritical: Whether the event is critical. Defaults to `false`.
    ///   - payload: Additional metadata. Defaults to empty dictionary.
    ///   - correlationID: Optional correlation ID for tracking related events.
    /// - Returns: The created ``LogEvent``.
    @discardableResult
    func error(
        _ message: String,
        domain: String = "",
        action: String = "",
        purpose: LogPurpose = .operational,
        isCritical: Bool = false,
        payload: [String: String] = [:],
        correlationID: UUID? = nil
    ) -> LogEvent {
        return createLogEvent(
            message,
            severity: .error,
            purpose: purpose,
            domain: domain.isEmpty ? DefaultDomain.empty.value : domain,
            action: action.isEmpty ? DefaultAction.empty.value : action,
            isCritical: isCritical,
            payload: payload,
            correlationID: correlationID
        )
    }

    /// Logs an error from an Error instance.
    /// - Parameters:
    ///   - error: The error to log.
    ///   - domain: Business domain or subsystem. Defaults to empty.
    ///   - action: Specific action within the domain. Defaults to empty.
    ///   - purpose: Purpose of the event. Defaults to `.operational`.
    ///   - isCritical: Whether the event is critical. Defaults to `false`.
    ///   - payload: Additional metadata. Defaults to empty dictionary.
    ///   - correlationID: Optional correlation ID for tracking related events.
    /// - Returns: The created ``LogEvent``.
    @discardableResult
    func error(
        _ error: Error,
        domain: String = "",
        action: String = "",
        purpose: LogPurpose = .operational,
        isCritical: Bool = false,
        payload: [String: String] = [:],
        correlationID: UUID? = nil
    ) -> LogEvent {
        return self.error(
            error.localizedDescription,
            domain: domain,
            action: action,
            purpose: purpose,
            isCritical: isCritical,
            payload: payload,
            correlationID: correlationID
        )
    }

    /// Logs a fault-level message.
    /// - Parameters:
    ///   - message: The message to log.
    ///   - domain: Business domain or subsystem. Defaults to empty.
    ///   - action: Specific action within the domain. Defaults to empty.
    ///   - purpose: Purpose of the event. Defaults to `.operational`.
    ///   - isCritical: Whether the event is critical. Defaults to `false`.
    ///   - payload: Additional metadata. Defaults to empty dictionary.
    ///   - correlationID: Optional correlation ID for tracking related events.
    /// - Returns: The created ``LogEvent``.
    @discardableResult
    func fault(
        _ message: String,
        domain: String = "",
        action: String = "",
        purpose: LogPurpose = .operational,
        isCritical: Bool = false,
        payload: [String: String] = [:],
        correlationID: UUID? = nil
    ) -> LogEvent {
        return createLogEvent(
            message,
            severity: .fault,
            purpose: purpose,
            domain: domain.isEmpty ? DefaultDomain.empty.value : domain,
            action: action.isEmpty ? DefaultAction.empty.value : action,
            isCritical: isCritical,
            payload: payload,
            correlationID: correlationID
        )
    }
}

// MARK: - Convenience Logging Methods with Protocol Support

public extension Letopis {
    /// Logs a debug-level message with protocol-based domain and action.
    @discardableResult
    func debug<D: DomainProtocol, A: ActionProtocol>(
        _ message: String,
        domain: D,
        action: A,
        purpose: LogPurpose = .operational,
        isCritical: Bool = false,
        payload: [String: String] = [:],
        correlationID: UUID? = nil
    ) -> LogEvent {
        return self.debug(
            message,
            domain: domain.value,
            action: action.value,
            purpose: purpose,
            isCritical: isCritical,
            payload: payload,
            correlationID: correlationID
        )
    }

    /// Logs an info-level message with protocol-based domain and action.
    @discardableResult
    func info<D: DomainProtocol, A: ActionProtocol>(
        _ message: String,
        domain: D,
        action: A,
        purpose: LogPurpose = .operational,
        isCritical: Bool = false,
        payload: [String: String] = [:],
        correlationID: UUID? = nil
    ) -> LogEvent {
        return self.info(
            message,
            domain: domain.value,
            action: action.value,
            purpose: purpose,
            isCritical: isCritical,
            payload: payload,
            correlationID: correlationID
        )
    }

    /// Logs a notice-level message with protocol-based domain and action.
    @discardableResult
    func notice<D: DomainProtocol, A: ActionProtocol>(
        _ message: String,
        domain: D,
        action: A,
        purpose: LogPurpose = .operational,
        isCritical: Bool = false,
        payload: [String: String] = [:],
        correlationID: UUID? = nil
    ) -> LogEvent {
        return self.notice(
            message,
            domain: domain.value,
            action: action.value,
            purpose: purpose,
            isCritical: isCritical,
            payload: payload,
            correlationID: correlationID
        )
    }

    /// Logs a warning-level message with protocol-based domain and action.
    @discardableResult
    func warning<D: DomainProtocol, A: ActionProtocol>(
        _ message: String,
        domain: D,
        action: A,
        purpose: LogPurpose = .operational,
        isCritical: Bool = false,
        payload: [String: String] = [:],
        correlationID: UUID? = nil
    ) -> LogEvent {
        return self.warning(
            message,
            domain: domain.value,
            action: action.value,
            purpose: purpose,
            isCritical: isCritical,
            payload: payload,
            correlationID: correlationID
        )
    }

    /// Logs an error-level message with protocol-based domain and action.
    @discardableResult
    func error<D: DomainProtocol, A: ActionProtocol>(
        _ message: String,
        domain: D,
        action: A,
        purpose: LogPurpose = .operational,
        isCritical: Bool = false,
        payload: [String: String] = [:],
        correlationID: UUID? = nil
    ) -> LogEvent {
        return self.error(
            message,
            domain: domain.value,
            action: action.value,
            purpose: purpose,
            isCritical: isCritical,
            payload: payload,
            correlationID: correlationID
        )
    }

    /// Logs a fault-level message with protocol-based domain and action.
    @discardableResult
    func fault<D: DomainProtocol, A: ActionProtocol>(
        _ message: String,
        domain: D,
        action: A,
        purpose: LogPurpose = .operational,
        isCritical: Bool = false,
        payload: [String: String] = [:],
        correlationID: UUID? = nil
    ) -> LogEvent {
        return self.fault(
            message,
            domain: domain.value,
            action: action.value,
            purpose: purpose,
            isCritical: isCritical,
            payload: payload,
            correlationID: correlationID
        )
    }
}

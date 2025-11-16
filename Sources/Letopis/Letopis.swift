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
    ///   - sensitiveKeys: Global list of keys that should be masked in all log payloads.
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

    /// Creates an informational log event.
    /// - Parameters:
    ///   - message: Descriptive message to log.
    ///   - isCritical: Whether the event is critical. Defaults to `false`.
    ///   - payload: Additional metadata for the event.
    ///   - eventType: Optional high-level classification of the event.
    ///   - eventAction: Optional action performed during the event.
    ///   - includeSource: Whether to include source code location metadata. Defaults to `false`.
    ///   - file: Source file path (automatically captured).
    ///   - function: Function name (automatically captured).
    ///   - line: Line number (automatically captured).
    /// - Returns: Created ``LogEvent`` instance.
    @discardableResult
    public func info(
        _ message: String,
        isCritical: Bool = false,
        payload: [String: String]? = nil,
        eventType: (any EventTypeProtocol)? = nil,
        eventAction: (any EventActionProtocol)? = nil,
        includeSource: Bool = false,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) -> LogEvent {
        createLogEvent(
            message,
            type: .info,
            isCritical: isCritical,
            payload: combinePayload(
                payload: payload,
                eventType: eventType,
                eventAction: eventAction,
                includeSource: includeSource,
                file: file,
                function: function,
                line: line
            )
        )
    }

    /// Creates a warning log event.
    /// - Parameters:
    ///   - message: Descriptive message to log.
    ///   - isCritical: Whether the event is critical. Defaults to `false`.
    ///   - payload: Additional metadata for the event.
    ///   - eventType: Optional high-level classification of the event.
    ///   - eventAction: Optional action performed during the event.
    ///   - includeSource: Whether to include source code location metadata. Defaults to `false`.
    ///   - file: Source file path (automatically captured).
    ///   - function: Function name (automatically captured).
    ///   - line: Line number (automatically captured).
    /// - Returns: Created ``LogEvent`` instance.
    @discardableResult
    public func warning(
        _ message: String,
        isCritical: Bool = false,
        payload: [String: String]? = nil,
        eventType: (any EventTypeProtocol)? = nil,
        eventAction: (any EventActionProtocol)? = nil,
        includeSource: Bool = false,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) -> LogEvent {
        createLogEvent(
            message,
            type: .warning,
            isCritical: isCritical,
            payload: combinePayload(
                payload: payload,
                eventType: eventType,
                eventAction: eventAction,
                includeSource: includeSource,
                file: file,
                function: function,
                line: line
            )
        )
    }

    /// Creates an error log event from a descriptive message.
    /// - Parameters:
    ///   - message: Descriptive message to log.
    ///   - isCritical: Whether the event is critical. Defaults to `true`.
    ///   - payload: Additional metadata for the event.
    ///   - eventType: Optional high-level classification of the event.
    ///   - eventAction: Optional action performed during the event.
    ///   - includeSource: Whether to include source code location metadata. Defaults to `false`.
    ///   - file: Source file path (automatically captured).
    ///   - function: Function name (automatically captured).
    ///   - line: Line number (automatically captured).
    /// - Returns: Created ``LogEvent`` instance.
    @discardableResult
    public func error(
        _ message: String,
        isCritical: Bool = true,
        payload: [String: String]? = nil,
        eventType: (any EventTypeProtocol)? = nil,
        eventAction: (any EventActionProtocol)? = nil,
        includeSource: Bool = false,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) -> LogEvent {
        createLogEvent(
            message,
            type: .error,
            isCritical: isCritical,
            payload: combinePayload(
                payload: payload,
                eventType: eventType,
                eventAction: eventAction,
                includeSource: includeSource,
                file: file,
                function: function,
                line: line
            )
        )
    }

    /// Creates an error log event from an ``Error`` instance.
    /// - Parameters:
    ///   - error: Error to log.
    ///   - isCritical: Whether the event is critical. Defaults to `true`.
    ///   - payload: Additional metadata for the event.
    ///   - eventType: Optional high-level classification of the event.
    ///   - eventAction: Optional action performed during the event.
    ///   - includeSource: Whether to include source code location metadata. Defaults to `false`.
    ///   - file: Source file path (automatically captured).
    ///   - function: Function name (automatically captured).
    ///   - line: Line number (automatically captured).
    /// - Returns: Created ``LogEvent`` instance.
    @discardableResult
    public func error(
        _ error: Error,
        isCritical: Bool = true,
        payload: [String: String]? = nil,
        eventType: (any EventTypeProtocol)? = nil,
        eventAction: (any EventActionProtocol)? = nil,
        includeSource: Bool = false,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) -> LogEvent {
        createLogEvent(
            error.localizedDescription,
            type: .error,
            isCritical: isCritical,
            payload: combinePayload(
                payload: payload,
                eventType: eventType,
                eventAction: eventAction,
                includeSource: includeSource,
                file: file,
                function: function,
                line: line
            )
        )
    }

    /// Creates a debug log event.
    /// - Parameters:
    ///   - message: Descriptive message to log.
    ///   - isCritical: Whether the event is critical. Defaults to `false`.
    ///   - payload: Additional metadata for the event.
    ///   - eventType: Optional high-level classification of the event.
    ///   - eventAction: Optional action performed during the event.
    ///   - includeSource: Whether to include source code location metadata. Defaults to `false`.
    ///   - file: Source file path (automatically captured).
    ///   - function: Function name (automatically captured).
    ///   - line: Line number (automatically captured).
    /// - Returns: Created ``LogEvent`` instance.
    @discardableResult
    public func debug(
        _ message: String,
        isCritical: Bool = false,
        payload: [String: String]? = nil,
        eventType: (any EventTypeProtocol)? = nil,
        eventAction: (any EventActionProtocol)? = nil,
        includeSource: Bool = false,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) -> LogEvent {
        createLogEvent(
            message,
            type: .debug,
            isCritical: isCritical,
            payload: combinePayload(
                payload: payload,
                eventType: eventType,
                eventAction: eventAction,
                includeSource: includeSource,
                file: file,
                function: function,
                line: line
            )
        )
    }

    /// Creates an analytics log event intended for analytics services.
    /// - Parameters:
    ///   - message: Descriptive message to log.
    ///   - isCritical: Whether the event is critical. Defaults to `false`.
    ///   - payload: Additional metadata for the event.
    ///   - eventType: Optional high-level classification of the event.
    ///   - eventAction: Optional action performed during the event.
    ///   - includeSource: Whether to include source code location metadata. Defaults to `false`.
    ///   - file: Source file path (automatically captured).
    ///   - function: Function name (automatically captured).
    ///   - line: Line number (automatically captured).
    /// - Returns: Created ``LogEvent`` instance.
    @discardableResult
    public func analytics(
        _ message: String,
        isCritical: Bool = false,
        payload: [String: String]? = nil,
        eventType: (any EventTypeProtocol)? = nil,
        eventAction: (any EventActionProtocol)? = nil,
        includeSource: Bool = false,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) -> LogEvent {
        createLogEvent(
            message,
            type: .analytics,
            isCritical: isCritical,
            payload: combinePayload(
                payload: payload,
                eventType: eventType,
                eventAction: eventAction,
                includeSource: includeSource,
                file: file,
                function: function,
                line: line
            )
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

    /// Creates a raw log event, forwards it to interceptors and returns the created event.
    /// - Parameters:
    ///   - message: Descriptive message associated with the event.
    ///   - type: Semantic type of the event.
    ///   - isCritical: Whether the event is critical. Defaults to `false`.
    ///   - payload: Additional metadata that should accompany the event.
    /// - Returns: Fully constructed ``LogEvent``.
    @discardableResult
    internal func createLogEvent(
        _ message: String,
        type: LogEventType,
        isCritical: Bool = false,
        payload: [String: String] = [:]
    ) -> LogEvent {
        let event = LogEvent(
            type: type,
            isCritical: isCritical,
            message: message,
            payload: payload
        )
        notifyInterceptors(with: event)
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
        eventAction: (any EventActionProtocol)?,
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
    func notifyInterceptors(with event: LogEvent) {
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

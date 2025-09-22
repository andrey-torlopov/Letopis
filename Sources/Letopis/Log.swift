import Foundation

public struct SourceInfo {
    let fileName: String
    let function: String
    let line: String
}

public final class Log {
    private let logger: Letopis
    private var priority: LogPriority = .default
    private var payload: [String: String] = [:]
    private var eventType: String?
    private var eventAction: String?
    private var sourceInfo: SourceInfo?

    init(logger: Letopis) {
        self.logger = logger
    }

    @discardableResult
    public func event<T: EventTypeProtocol>(_ type: T) -> Log {
        setEventType(type.value)
    }

    @discardableResult
    public func event(_ value: String) -> Log {
        setEventType(value)
    }

    @discardableResult
    public func action<T: EventActionProtocol>(_ action: T) -> Log {
        setEventAction(action.value)
    }

    @discardableResult
    public func action(_ value: String) -> Log {
        setEventAction(value)
    }

    @discardableResult
    public func payload(_ payload: [String: String]) -> Log {
        self.payload.merge(payload) { _, new in new }
        return self
    }

    @discardableResult
    public func priority(_ priority: LogPriority) -> Log {
        self.priority = priority
        return self
    }

    @discardableResult
    public func source(file: String = #file, function: String = #function, line: Int = #line) -> Log {
        let fileName = (file as NSString).lastPathComponent
        sourceInfo = SourceInfo(
            fileName: fileName,
            function: function,
            line: String(line)
        )
        return self
    }

    @discardableResult
    public func info(_ message: String) -> LogEvent {
        return createAndSendEvent(message: message, type: .info)
    }

    @discardableResult
    public func warning(_ message: String) -> LogEvent {
        return createAndSendEvent(message: message, type: .warning)
    }

    @discardableResult
    public func error(_ message: String) -> LogEvent {
        return createAndSendEvent(message: message, type: .error)
    }

    @discardableResult
    public func error(_ error: Error) -> LogEvent {
        return createAndSendEvent(message: error.localizedDescription, type: .error)
    }

    @discardableResult
    public func debug(_ message: String) -> LogEvent {
        return createAndSendEvent(message: message, type: .debug)
    }

    private func createAndSendEvent(message: String, type: LogEventType) -> LogEvent {
        let event = logger.createLogEvent(
            message,
            type: type,
            priority: priority,
            payload: buildPayload()
        )

        return event
    }

    private func setEventType(_ value: String) -> Log {
        eventType = value
        return self
    }

    private func setEventAction(_ value: String) -> Log {
        eventAction = value
        return self
    }



    private func buildPayload() -> [String: String] {
        var result = payload

        if let eventType {
            result["event_type"] = eventType
        }

        if let eventAction {
            result["event_action"] = eventAction
        }

        if let sourceInfo {
            result["source_file"] = sourceInfo.fileName
            result["source_function"] = sourceInfo.function
            result["source_line"] = sourceInfo.line
        }

        return result.isEmpty ? [:] : result
    }
}

public extension Letopis {
    func log() -> Log {
        Log(logger: self)
    }

    @discardableResult
    func event<T: EventTypeProtocol>(_ event: T) -> Log {
        log().event(event)
    }

    @discardableResult
    func event(_ value: String) -> Log {
        log().event(value)
    }

    @discardableResult
    func action<T: EventActionProtocol>(_ action: T) -> Log {
        log().action(action)
    }

    @discardableResult
    func action(_ value: String) -> Log {
        log().action(value)
    }
}

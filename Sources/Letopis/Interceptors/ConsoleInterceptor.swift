import OSLog

/// Global actor that serialises console output to avoid interleaving log lines.
@globalActor
actor LoggingActor {
    /// Shared logging actor instance.
    static let shared = LoggingActor()

    /// Prints a message using the provided printer closure.
    /// - Parameters:
    ///   - message: Message to print.
    ///   - printer: Printer closure to use.
    func print(_ message: String, using printer: @Sendable (String) -> Void) {
        printer(message)
    }
}

/// Interceptor that formats log events and prints them to a provided output closure.
public final class ConsoleInterceptor: LetopisInterceptor {
    /// Closure that prints formatted log messages.
    public typealias Printer = @Sendable (String) -> Void

    public var name: String { "ConsoleInterceptor" }

    private let logTypes: Set<LogEventType>?
    private let priorities: Set<LogPriority>?
    private let eventTypes: Set<String>?
    private let actions: Set<String>?
    private let sourceFiles: Set<String>?
    private let printer: Printer
    private let logger: Logger?
    private let useOSLog: Bool

    /// Creates a console interceptor using raw string filters.
    /// - Parameters:
    ///   - logTypes: Accepted log event types.
    ///   - priorities: Accepted log priorities.
    ///   - eventTypes: Accepted event types extracted from payload.
    ///   - actions: Accepted event actions extracted from payload.
    ///   - sourceFiles: Accepted source file names from payload metadata.
    ///   - useOSLog: Whether to use OSLog instead of print. Defaults to `false`.
    ///   - subsystem: OSLog subsystem identifier. Required when `useOSLog` is `true`.
    ///   - category: OSLog category. Defaults to "Letopis".
    ///   - printer: Closure that outputs a formatted message. Defaults to ``Swift/print(_:)``. Ignored when `useOSLog` is `true`.
    public init(
        logTypes: [LogEventType]? = nil,
        priorities: [LogPriority]? = nil,
        eventTypes: [String]? = nil,
        actions: [String]? = nil,
        sourceFiles: [String]? = nil,
        useOSLog: Bool = false,
        subsystem: String? = nil,
        category: String = "Letopis",
        printer: @escaping Printer = { print($0) }
    ) {
        self.logTypes = ConsoleInterceptor.normalize(logTypes)
        self.priorities = ConsoleInterceptor.normalize(priorities)
        self.eventTypes = ConsoleInterceptor.normalize(eventTypes)
        self.actions = ConsoleInterceptor.normalize(actions)
        self.sourceFiles = ConsoleInterceptor.normalize(sourceFiles)
        self.useOSLog = useOSLog
        self.printer = printer

        if useOSLog, let subsystem = subsystem {
            self.logger = Logger(subsystem: subsystem, category: category)
        } else {
            self.logger = nil
        }
    }

    /// Handles a log event by formatting it and printing it on the ``LoggingActor``.
    /// - Parameter logEvent: Event to handle.
    public func handle(_ logEvent: LogEvent) async throws {
        guard shouldHandle(logEvent) else { return }

        if useOSLog, let logger = logger {
            logWithOSLog(logEvent, logger: logger)
        } else {
            let formattedMessage = format(logEvent)
            await LoggingActor.shared.print(formattedMessage, using: printer)
        }
    }

    /// Checks if the console interceptor is healthy.
    /// - Returns: Always returns `true` as console output rarely fails.
    public func health() async -> Bool {
        return true
    }

    /// Logs an event using OSLog.
    /// - Parameters:
    ///   - event: Event to log.
    ///   - logger: Logger instance to use.
    private func logWithOSLog(_ event: LogEvent, logger: Logger) {
        let osLogLevel = mapToOSLogLevel(event.priority)
        let message = formatForOSLog(event)

        logger.log(level: osLogLevel, "\(message)")
    }

    /// Maps Letopis priority to OSLog level.
    /// - Parameter priority: Letopis log priority.
    /// - Returns: Corresponding OSLog level.
    private func mapToOSLogLevel(_ priority: LogPriority) -> OSLogType {
        switch priority {
        case .low:
            return .debug
        case .medium:
            return .info
        case .high:
            return .default
        case .critical:
            return .error
        }
    }

    /// Formats the log event for OSLog output.
    /// - Parameter event: Event to format.
    /// - Returns: Formatted message string.
    private func formatForOSLog(_ event: LogEvent) -> String {
        var parts: [String] = []

        parts.append("[\(event.type.rawValue)]")
        parts.append(event.message)

        if !event.payload.isEmpty {
            let sourceFile = event.payload["source_file"]
            let sourceFunction = event.payload["source_function"]
            let sourceLine = event.payload["source_line"]

            let filteredPayload = event.payload.filter {
                $0.key != "source_file" && $0.key != "source_function" && $0.key != "source_line"
            }

            if let file = sourceFile, let function = sourceFunction, let line = sourceLine {
                parts.append("[source: \(file)::\(function)::\(line)]")
            }

            if !filteredPayload.isEmpty {
                let payloadDescription = filteredPayload
                    .sorted { $0.key < $1.key }
                    .map { "\($0.key)=\($0.value)" }
                    .joined(separator: ", ")
                parts.append("[\(payloadDescription)]")
            }
        }

        return parts.joined(separator: " ")
    }

    /// Determines whether a log event matches the configured filters.
    /// - Parameter event: Event to evaluate.
    /// - Returns: ``true`` if the event should be handled, otherwise ``false``.
    private func shouldHandle(_ event: LogEvent) -> Bool {
        #if !DEBUG
        return false
        #endif

        if let logTypes, !logTypes.contains(event.type) { return false }
        if let priorities, !priorities.contains(event.priority) { return false }

        if let eventTypes {
            guard
                let value = event.payload["event_type"],
                eventTypes.contains(value)
            else { return false }
        }

        if let actions {
            guard
                let value = event.payload["event_action"],
                actions.contains(value)
            else { return false }
        }

        if let sourceFiles {
            guard
                let sourceFile = sourceFileName(from: event.payload),
                sourceFiles.contains(sourceFile)
            else { return false }
        }

        return true
    }

    /// Extracts a source file name from payload metadata.
    /// - Parameter payload: Payload dictionary.
    /// - Returns: Name of the source file if present.
    private func sourceFileName(from payload: [String: String]?) -> String? {
        guard let sourceFile = payload?["source_file"] else { return nil }
        return sourceFile
    }

    /// Formats the provided log event into a printable string.
    /// - Parameter event: Event to format.
    /// - Returns: Human readable representation of the event.
    private func format(_ event: LogEvent) -> String {
        var parts: [String] = []

        parts.append("\(event.type.rawValue) \(event.priority.icon) \(event.message)")

        if !event.payload.isEmpty {
            // Extract source information
            let sourceFile = event.payload["source_file"]
            let sourceFunction = event.payload["source_function"]
            let sourceLine = event.payload["source_line"]

            // Filter out source keys from payload
            let filteredPayload = event.payload.filter {
                $0.key != "source_file" && $0.key != "source_function" && $0.key != "source_line"
            }

            // Add source info if present
            if let file = sourceFile, let function = sourceFunction, let line = sourceLine {
                parts.append("[source: \(file) :: \(function) :: \(line)]")
            }

            // Add remaining payload if any
            if !filteredPayload.isEmpty {
                let payloadDescription = filteredPayload
                    .sorted { $0.key < $1.key }
                    .map { "\($0.key)=\($0.value)" }
                    .joined(separator: ", ")
                parts.append("[\(payloadDescription)]")
            }
        }

        return parts.joined(separator: " ")
    }

    /// Converts an optional array into an optional non-empty set.
    /// - Parameter values: Values to normalise.
    /// - Returns: A set containing the unique values or ``nil`` when the result would be empty.
    private static func normalize<Value: Hashable>(_ values: [Value]?) -> Set<Value>? {
        guard let values else { return nil }
        let set = Set(values)
        return set.isEmpty ? nil : set
    }
}

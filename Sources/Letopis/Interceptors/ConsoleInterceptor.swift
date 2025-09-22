import Foundation

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

    private let logTypes: Set<LogEventType>?
    private let priorities: Set<LogPriority>?
    private let eventTypes: Set<String>?
    private let actions: Set<String>?
    private let sourceFiles: Set<String>?
    private let printer: Printer

    /// Creates a console interceptor using raw string filters.
    /// - Parameters:
    ///   - logTypes: Accepted log event types.
    ///   - priorities: Accepted log priorities.
    ///   - eventTypes: Accepted event types extracted from payload.
    ///   - actions: Accepted event actions extracted from payload.
    ///   - sourceFiles: Accepted source file names from payload metadata.
    ///   - printer: Closure that outputs a formatted message. Defaults to ``Swift/print(_:)``.
    public init(
        logTypes: [LogEventType]? = nil,
        priorities: [LogPriority]? = nil,
        eventTypes: [String]? = nil,
        actions: [String]? = nil,
        sourceFiles: [String]? = nil,
        printer: @escaping Printer = { print($0) }
    ) {
        self.logTypes = ConsoleInterceptor.normalize(logTypes)
        self.priorities = ConsoleInterceptor.normalize(priorities)
        self.eventTypes = ConsoleInterceptor.normalize(eventTypes)
        self.actions = ConsoleInterceptor.normalize(actions)
        self.sourceFiles = ConsoleInterceptor.normalize(sourceFiles)
        self.printer = printer
    }

    /// Handles a log event by formatting it and printing it on the ``LoggingActor``.
    /// - Parameter logEvent: Event to handle.
    public func handle(_ logEvent: LogEvent) async throws {
        guard shouldHandle(logEvent) else { return }
        let formattedMessage = format(logEvent)
        await LoggingActor.shared.print(formattedMessage, using: printer)
    }

    /// Checks if the console interceptor is healthy.
    /// - Returns: Always returns `true` as console output rarely fails.
    public func health() async -> Bool {
        return true
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
        parts.append("\(event.type.rawValue) \(event.message)")
        parts.append("(priority: \(String(describing: event.priority)))")

        if !event.payload.isEmpty {
            let payloadDescription = event.payload
                .sorted { $0.key < $1.key }
                .map { "\($0.key)=\($0.value)" }
                .joined(separator: ", ")
            parts.append("[\(payloadDescription)]")
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

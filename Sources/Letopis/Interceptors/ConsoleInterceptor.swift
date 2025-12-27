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
    private let severities: Set<LogSeverity>?
    private let purposes: Set<LogPurpose>?
    private let criticalOnly: Bool
    private let eventTypes: Set<String>?
    private let actions: Set<String>?
    private let sourceFiles: Set<String>?
    private let printer: Printer
    private let logger: Logger?
    private let subsystem: String?
    private let defaultCategory: String?

    /// Creates a console interceptor with severity-based filtering.
    /// - Parameters:
    ///   - severities: Accepted severity levels. If nil, all severities are accepted.
    ///   - purposes: Accepted purposes. If nil, all purposes are accepted.
    ///   - criticalOnly: If `true`, only critical events are logged. Defaults to `false`.
    ///   - eventTypes: Accepted event types (domains).
    ///   - actions: Accepted event actions.
    ///   - sourceFiles: Accepted source file names from payload metadata.
    ///   - subsystem: OSLog subsystem identifier. If provided, OSLog is used instead of print. If nil, falls back to print. Defaults to `nil`.
    ///   - defaultCategory: Default OSLog category when subsystem is provided. If nil, uses event.domain as category. Defaults to `nil`.
    ///   - printer: Closure that outputs a formatted message. Defaults to ``Swift/print(_:)``. Ignored when subsystem is provided.
    public init(
        severities: [LogSeverity]? = nil,
        purposes: [LogPurpose]? = nil,
        criticalOnly: Bool = false,
        eventTypes: [String]? = nil,
        actions: [String]? = nil,
        sourceFiles: [String]? = nil,
        subsystem: String? = nil,
        defaultCategory: String? = nil,
        printer: @escaping Printer = { Swift.print($0) }
    ) {
        self.logTypes = nil
        self.severities = ConsoleInterceptor.normalize(severities)
        self.purposes = ConsoleInterceptor.normalize(purposes)
        self.criticalOnly = criticalOnly
        self.eventTypes = ConsoleInterceptor.normalize(eventTypes)
        self.actions = ConsoleInterceptor.normalize(actions)
        self.sourceFiles = ConsoleInterceptor.normalize(sourceFiles)
        self.subsystem = subsystem
        self.defaultCategory = defaultCategory
        self.printer = printer

        // Create logger upfront when subsystem and defaultCategory are both provided
        if let subsystem = subsystem, let defaultCategory = defaultCategory {
            self.logger = Logger(subsystem: subsystem, category: defaultCategory)
        } else {
            self.logger = nil
        }
    }

    /// Handles a log event by formatting it and printing it on the ``LoggingActor``.
    /// - Parameter logEvent: Event to handle.
    public func handle(_ logEvent: LogEvent) async throws {
        guard shouldHandle(logEvent) else { return }

        if subsystem != nil {
            logWithOSLog(logEvent)
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

    /// Logs an event using OSLog with appropriate subsystem and category.
    ///
    /// The category is determined by `defaultCategory`:
    /// - If `defaultCategory` is `nil`: uses `event.domain` as category (e.g., "auth", "network", "ui")
    /// - If `defaultCategory` is provided: uses the specified default category
    ///
    /// Using domain as category allows filtering logs by business area in Console.app:
    /// - `subsystem:com.app category:auth` - all authentication logs
    /// - `subsystem:com.app category:network` - all network logs
    ///
    /// - Parameter event: Event to log.
    private func logWithOSLog(_ event: LogEvent) {
        guard let subsystem = subsystem else {
            // This shouldn't happen as we check subsystem in handle(), but provide fallback
            let formattedMessage = format(event)
            let currentPrinter = printer
            Task {
                await LoggingActor.shared.print(formattedMessage, using: currentPrinter)
            }
            return
        }

        // Determine the logger to use based on configuration
        let effectiveLogger: Logger
        if let logger = logger {
            // Use pre-created logger with default category
            effectiveLogger = logger
        } else {
            // Use domain as category for better log organization
            // This allows filtering by business domain in Console.app
            effectiveLogger = Logger(subsystem: subsystem, category: event.domain)
        }

        let osLogLevel = event.severity.osLogType
        let message = formatForOSLog(event)

        effectiveLogger.log(level: osLogLevel, "\(message)")
    }

    /// Formats the log event for OSLog output.
    /// - Parameter event: Event to format.
    /// - Returns: Formatted message string.
    private func formatForOSLog(_ event: LogEvent) -> String {
        var parts: [String] = []

        // Add severity and criticality icons
        parts.append("\(event.severity.rawValue) \(event.purpose.rawValue) \(event.criticalityIcon)")

        // Add eventID if available
        if !event.eventID.isEmpty && event.eventID != "app.event" {
            parts.append("[\(event.eventID)]")
        }

        // Add message
        parts.append(event.message)

        // Add correlation ID if present
        if let correlationID = event.correlationID {
            parts.append("[correlation: \(correlationID.uuidString)]")
        }

        // Add payload metadata
        if !event.payload.isEmpty {
            let sourceFile = event.payload["source_file"]
            let sourceFunction = event.payload["source_function"]
            let sourceLine = event.payload["source_line"]

            let filteredPayload = event.payload.filter {
                $0.key != "source_file" && $0.key != "source_function" && $0.key != "source_line"
                    && $0.key != "domain" && $0.key != "action"
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
        // Check severity filter
        if let severities, !severities.contains(event.severity) { return false }

        // Check purpose filter (new)
        if let purposes, !purposes.contains(event.purpose) { return false }



        if criticalOnly && !event.isCritical { return false }

        // Check domain filter (prefer direct property over payload)
        if let eventTypes {
            if !eventTypes.contains(event.domain) {
                // Fallback to payload for backward compatibility
                if let value = event.payload["event_type"], !eventTypes.contains(value) {
                    return false
                } else if event.payload["event_type"] == nil {
                    return false
                }
            }
        }

        // Check action filter (prefer direct property over payload)
        if let actions {
            if !actions.contains(event.action) {
                // Fallback to payload for backward compatibility
                if let value = event.payload["event_action"], !actions.contains(value) {
                    return false
                } else if event.payload["event_action"] == nil {
                    return false
                }
            }
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

        // Add severity, purpose and criticality icons
        parts.append("\(event.severity.rawValue) \(event.purpose.rawValue) \(event.criticalityIcon)")

        // Add eventID if available
        if !event.eventID.isEmpty && event.eventID != "app.event" {
            parts.append("[\(event.eventID)]")
        }

        // Add message
        parts.append(event.message)

        // Add correlation ID if present
        if let correlationID = event.correlationID {
            parts.append("[correlation: \(correlationID.uuidString)]")
        }

        if !event.payload.isEmpty {
            // Extract source information
            let sourceFile = event.payload["source_file"]
            let sourceFunction = event.payload["source_function"]
            let sourceLine = event.payload["source_line"]

            // Filter out source keys and event metadata from payload
            let filteredPayload = event.payload.filter {
                $0.key != "source_file" && $0.key != "source_function" && $0.key != "source_line"
                    && $0.key != "event_type" && $0.key != "event_action"
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

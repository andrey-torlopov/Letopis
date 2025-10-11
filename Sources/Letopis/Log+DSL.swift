import Foundation

// MARK: - DSL Extension (Optional API)

/// Optional DSL extension for Log that provides a fluent builder API.
///
/// This extension is provided for users who prefer a more expressive, chainable syntax.
/// For most use cases, the direct methods on `Letopis` (info, warning, error, etc.) are recommended.
///
/// Example usage:
/// ```swift
/// logger.log()
///     .event("user_action")
///     .action("button_tap")
///     .payload(["screen": "home"])
///     .critical()
///     .sensitive(keys: ["user_id"])
///     .info("User tapped button")
/// ```
public extension Log {
    /// Sets the event type using a protocol-conforming type.
    /// - Parameter type: Event type conforming to ``EventTypeProtocol``.
    /// - Returns: Self for chaining.
    @discardableResult
    func event<T: EventTypeProtocol>(_ type: T) -> Log {
        setEventType(type.value)
    }

    /// Sets the event type using a string value.
    /// - Parameter value: Event type as a string.
    /// - Returns: Self for chaining.
    @discardableResult
    func event(_ value: String) -> Log {
        setEventType(value)
    }

    /// Sets the event action using a protocol-conforming type.
    /// - Parameter action: Event action conforming to ``EventActionProtocol``.
    /// - Returns: Self for chaining.
    @discardableResult
    func action<T: EventActionProtocol>(_ action: T) -> Log {
        setEventAction(action.value)
    }

    /// Sets the event action using a string value.
    /// - Parameter value: Event action as a string.
    /// - Returns: Self for chaining.
    @discardableResult
    func action(_ value: String) -> Log {
        setEventAction(value)
    }

    /// Adds or merges additional metadata to the log payload.
    /// - Parameter payload: Dictionary of key-value pairs to add to the payload.
    /// - Returns: Self for chaining.
    @discardableResult
    func payload(_ payload: [String: String]) -> Log {
        self.payload.merge(payload) { _, new in new }
        return self
    }

    /// Marks the log event as critical, requiring immediate attention.
    /// - Returns: Self for chaining.
    @discardableResult
    func critical() -> Log {
        self.isCritical = true
        return self
    }

    /// Enables masking for all globally configured sensitive keys using partial strategy.
    /// - Returns: Self for chaining.
    @discardableResult
    func sensitive() -> Log {
        shouldUseSensitive = true
        return self
    }

    /// Enables masking for specific keys with a given strategy.
    /// - Parameters:
    ///   - keys: Array of keys to mask in the payload.
    ///   - strategy: Masking strategy to use (defaults to .partial).
    /// - Returns: Self for chaining.
    @discardableResult
    func sensitive(keys: [String], strategy: SensitiveDataStrategy = .partial) -> Log {
        shouldUseSensitive = true
        for key in keys {
            customSensitiveKeys[key] = strategy
        }
        return self
    }

    /// Enables masking for a specific key with a given strategy.
    /// - Parameters:
    ///   - key: Key to mask in the payload.
    ///   - strategy: Masking strategy to use (defaults to .partial).
    /// - Returns: Self for chaining.
    @discardableResult
    func sensitive(key: String, strategy: SensitiveDataStrategy = .partial) -> Log {
        shouldUseSensitive = true
        customSensitiveKeys[key] = strategy
        return self
    }

    /// Captures source code location metadata for debugging purposes.
    /// - Parameters:
    ///   - file: Source file path (automatically captured).
    ///   - function: Function name (automatically captured).
    ///   - line: Line number (automatically captured).
    /// - Returns: Self for chaining.
    @discardableResult
    func source(file: String = #file, function: String = #function, line: Int = #line) -> Log {
        let fileName = (file as NSString).lastPathComponent
        sourceInfo = SourceInfo(
            fileName: fileName,
            function: function,
            line: String(line)
        )
        return self
    }
}

// MARK: - DSL Entry Points Extension

/// Convenience extensions for creating Log instances from Letopis using DSL syntax.
///
/// These extensions provide entry points to the optional DSL API.
/// For most use cases, prefer direct methods like `info()`, `warning()`, `error()` etc.
public extension Letopis {
    /// Creates a new Log builder instance.
    /// - Returns: A new ``Log`` builder.
    func log() -> Log {
        Log(logger: self)
    }

    /// Creates a Log builder and sets the event type using a protocol-conforming type.
    /// - Parameter event: Event type conforming to ``EventTypeProtocol``.
    /// - Returns: A ``Log`` builder with the event type set.
    @discardableResult
    func event<T: EventTypeProtocol>(_ event: T) -> Log {
        log().event(event)
    }

    /// Creates a Log builder and sets the event type using a string value.
    /// - Parameter value: Event type as a string.
    /// - Returns: A ``Log`` builder with the event type set.
    @discardableResult
    func event(_ value: String) -> Log {
        log().event(value)
    }

    /// Creates a Log builder and sets the event action using a protocol-conforming type.
    /// - Parameter action: Event action conforming to ``EventActionProtocol``.
    /// - Returns: A ``Log`` builder with the event action set.
    @discardableResult
    func action<T: EventActionProtocol>(_ action: T) -> Log {
        log().action(action)
    }

    /// Creates a Log builder and sets the event action using a string value.
    /// - Parameter value: Event action as a string.
    /// - Returns: A ``Log`` builder with the event action set.
    @discardableResult
    func action(_ value: String) -> Log {
        log().action(value)
    }
}

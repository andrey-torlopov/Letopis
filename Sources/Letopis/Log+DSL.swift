import Foundation

// MARK: - DSL Extension (Optional API)

/// Optional DSL extension for Log that provides a fluent builder API.
///
/// This extension is provided for users who prefer a more expressive, chainable syntax.
/// For most use cases, the direct methods like `.info()`, `.warning()`, `.error()` are recommended.
///
/// Example usage:
/// ```swift
/// logger.log()
///     .domain("auth")
///     .action("login_failed")
///     .purpose(.operational)
///     .payload(["reason": "invalid_credentials"])
///     .critical()
///     .sensitive(keys: ["user_id"])
///     .error("User login failed")
/// ```
public extension Log {
    /// Sets the purpose of the log event.
    /// - Parameter purpose: Purpose of the event.
    /// - Returns: Self for chaining.
    @discardableResult
    func purpose(_ purpose: LogPurpose) -> Log {
        self.purpose = purpose
        return self
    }

    /// Sets the domain using a protocol-conforming type.
    /// - Parameter domain: Domain conforming to ``DomainProtocol``.
    /// - Returns: Self for chaining.
    @discardableResult
    func domain<T: DomainProtocol>(_ domain: T) -> Log {
        self.domain = domain.value
        return self
    }

    /// Sets the domain using a string value.
    /// - Parameter domain: Domain name (e.g., "auth", "payments", "network").
    /// - Returns: Self for chaining.
    @discardableResult
    func domain(_ domain: String) -> Log {
        self.domain = domain
        return self
    }

    /// Sets the action using a protocol-conforming type.
    /// - Parameter action: Action conforming to ``ActionProtocol``.
    /// - Returns: Self for chaining.
    @discardableResult
    func action<T: ActionProtocol>(_ action: T) -> Log {
        self.action = action.value
        return self
    }

    /// Sets the action using a string value.
    /// - Parameter action: Action name (e.g., "login_failed", "payment_processed").
    /// - Returns: Self for chaining.
    @discardableResult
    func action(_ action: String) -> Log {
        self.action = action
        return self
    }

    /// Sets the correlation ID for tracking related events.
    /// - Parameter correlationID: UUID for correlation.
    /// - Returns: Self for chaining.
    @discardableResult
    func correlationID(_ correlationID: UUID) -> Log {
        self.correlationID = correlationID
        return self
    }

    /// Sets the domain and action together using protocol-conforming types.
    /// - Parameters:
    ///   - domain: Domain conforming to ``DomainProtocol``.
    ///   - action: Action conforming to ``ActionProtocol``.
    /// - Returns: Self for chaining.
    @discardableResult
    func event<D: DomainProtocol, A: ActionProtocol>(domain: D, action: A) -> Log {
        self.domain = domain.value
        self.action = action.value
        return self
    }

    /// Sets the domain and action together using string values.
    /// - Parameters:
    ///   - domain: Domain name.
    ///   - action: Action name.
    /// - Returns: Self for chaining.
    @discardableResult
    func event(domain: String, action: String) -> Log {
        self.domain = domain
        self.action = action
        return self
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

    /// Disable masking for all globally configured sensitive keys using partial strategy.
    /// - Returns: Self for chaining.
    @discardableResult
    func notSensitive() -> Log {
        shouldUseSensitive = false
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
            customSensitiveKeys[key.lowercased()] = strategy
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
        customSensitiveKeys[key.lowercased()] = strategy
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



    /// Creates a Log builder and sets the domain using a protocol-conforming type.
    /// - Parameter domain: Domain conforming to ``DomainProtocol``.
    /// - Returns: A ``Log`` builder with the domain set.
    @discardableResult
    func domain<T: DomainProtocol>(_ domain: T) -> Log {
        log().domain(domain.value)
    }

    /// Creates a Log builder and sets the domain using a string value.
    /// - Parameter value: Domain as a string.
    /// - Returns: A ``Log`` builder with the domain set.
    @discardableResult
    func domain(_ value: String) -> Log {
        log().domain(value)
    }

    /// Creates a Log builder and sets the action using a protocol-conforming type.
    /// - Parameter action: Event action conforming to ``ActionProtocol``.
    /// - Returns: A ``Log`` builder with the action set.
    @discardableResult
    func action<T: ActionProtocol>(_ action: T) -> Log {
        log().action(action.value)
    }

    /// Creates a Log builder and sets the action using a string value.
    /// - Parameter value: Action as a string.
    /// - Returns: A ``Log`` builder with the action set.
    @discardableResult
    func action(_ value: String) -> Log {
        log().action(value)
    }
}

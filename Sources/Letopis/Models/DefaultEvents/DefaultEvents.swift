/// Development and debugging domains for developer tooling.
public enum DefaultDomain: String, DomainProtocol, Sendable {
    case empty = "empty"
}

/// Development action types for debugging and performance analysis.
public enum DefaultAction: String, ActionProtocol, Sendable {
    case empty = "empty"
}

/// Network domains for different network protocols and operations.
public enum NetworkDomain: String, DomainProtocol, Sendable {
    /// Network operations
    case network = "network"

    /// API calls
    case api = "api"

    /// WebSocket connections
    case websocket = "websocket"
}

/// Network action types representing different stages of network operations.
public enum NetworkAction: String, ActionProtocol, Sendable {
    /// Network request started
    case start = "start"

    /// Request completed successfully
    case success = "success"

    /// Request failed
    case failure = "failure"

    /// Retrying failed request
    case retry = "retry"

    /// Request cancelled
    case cancel = "cancel"

    /// Request timed out
    case timeout = "timeout"

    /// Connection established
    case connected = "connected"

    /// Connection closed
    case disconnected = "disconnected"

    /// Data received
    case dataReceived = "data_received"

    /// Data sent
    case dataSent = "data_sent"
}

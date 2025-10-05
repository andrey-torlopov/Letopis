/// Network event types for different network protocols and operations.
public enum NetworkEventType: String, EventTypeProtocol, Sendable {
    /// HTTP/HTTPS requests
    case http = "http_request"

    /// WebSocket connections
    case websocket = "websocket"

    /// GraphQL queries and mutations
    case graphql = "graphql"

    /// gRPC calls
    case grpc = "grpc"

    /// Generic API calls
    case api = "api"
}

/// Network action types representing different stages of network operations.
public enum NetworkAction: String, EventActionProtocol, Sendable {
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

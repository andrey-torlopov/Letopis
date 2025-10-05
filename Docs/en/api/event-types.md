# Event Types & Actions

# Event Types and Actions

## Built-in Default Types

Letopis provides a set of ready-to-use event types and actions for common scenarios:

### UserEvents - User Interactions

```swift
public enum UserEvents: String, EventTypeProtocol, Sendable {
    case tap = "user_tap"
    case swipe = "user_swipe"
    case input = "user_input"
    case navigation = "user_navigation"
    case form = "user_form"
    case gesture = "user_gesture"
}

public enum UserAction: String, EventActionProtocol, Sendable {
    case click, longPress, doubleClick, scroll
    case typeText, submit
    case swipeLeft, swipeRight, swipeUp, swipeDown
    case pullToRefresh, pinch, rotate
}
```

### NetworkEvents - Network Operations

```swift
public enum NetworkEvents: String, EventTypeProtocol, Sendable {
    case http = "http_request"
    case websocket = "websocket"
    case graphql = "graphql"
    case grpc = "grpc"
    case api = "api"
}

public enum NetworkAction: String, EventActionProtocol, Sendable {
    case start, success, failure, retry, cancel, timeout
    case connected, disconnected
    case dataReceived, dataSent
}
```

### ErrorEvents - Error Handling

```swift
public enum ErrorEvents: String, EventTypeProtocol, Sendable {
    case validation = "validation_error"
    case network = "network_error"
    case parsing = "parsing_error"
    case business = "business_error"
    case system = "system_error"
    case auth = "auth_error"
    case database = "database_error"
    case fileSystem = "file_system_error"
}

public enum ErrorAction: String, EventActionProtocol, Sendable {
    case occurred, recovered, retrying, fatal
    case ignored, logged, handledByUser
}
```

### Using Default Types

```swift
// Logging user action
logger
    .event(UserEvents.tap)
    .action(UserAction.click)
    .payload(["button": "submit"])
    .info("User clicked button")

// Logging network request
logger
    .event(NetworkEvents.http)
    .action(NetworkAction.success)
    .payload(["endpoint": "/api/users"])
    .info("Request successful")

// Logging error
logger
    .event(ErrorEvents.network)
    .action(ErrorAction.retrying)
    .priority(.critical)
    .error("Connection error")
```

## Custom Event Types

You can create your own event types by conforming to the protocols:

```swift
enum CustomEventType: String, EventTypeProtocol {
    case authentication = "auth"
    case dataSync = "data_sync"
    case featureFlag = "feature_flag"
}

enum CustomAction: String, EventActionProtocol {
    case enable = "enable"
    case disable = "disable"
    case refresh = "refresh"
}
```

## Using Custom Types

```swift
logger
    .event(CustomEventType.authentication)
    .action(CustomAction.enable)
    .info("Two-factor authentication enabled")
```

## Example: Screen Actions

```swift
public enum ScreenAction: String, EventActionProtocol, Sendable {
    case open
    case close
}

public enum AppEventType: String, EventTypeProtocol, Sendable {
    case uiAction = "ui_action"
    case businessLogic = "business_logic"
}
```

## Best Practices

- Use enums with `String` raw values for type safety
- Make types conform to `Sendable` when working with actors
- Choose descriptive names that reflect your domain
- Keep event taxonomies consistent across your application

---

[Back to Documentation Index](../index.md)

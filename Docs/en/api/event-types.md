# Event Types & Actions

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

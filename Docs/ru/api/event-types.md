## Пользовательские типы событий

# Типы событий и действий

## Встроенные дефолтные типы

Letopis предоставляет набор готовых типов событий и действий для типичных сценариев:

### UserEvents - События пользователя

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

### NetworkEvents - Сетевые события

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

### ErrorEvents - События ошибок

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

### Пример использования дефолтных типов

```swift
// Логирование действия пользователя
logger
    .event(UserEvents.tap)
    .action(UserAction.click)
    .payload(["button": "submit"])
    .info("Пользователь нажал кнопку")

// Логирование сетевого запроса
logger
    .event(NetworkEvents.http)
    .action(NetworkAction.success)
    .payload(["endpoint": "/api/users"])
    .info("Запрос выполнен успешно")

// Логирование ошибки
logger
    .event(ErrorEvents.network)
    .action(ErrorAction.retrying)
    .critical()
    .error("Ошибка подключения")
```

## Пользовательские типы событий

Вы также можете создавать собственные типы событий, соответствуя протоколам:

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

## Использование пользовательских типов

```swift
logger
    .event(CustomEventType.authentication)
    .action(CustomAction.enable)
    .info("Двухфакторная аутентификация включена")
```

## Пример: Действия экрана

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

## Лучшие практики

- Используйте перечисления со строковыми значениями для типобезопасности
- Делайте типы соответствующими `Sendable` при работе с акторами
- Выбирайте описательные имена, отражающие вашу предметную область
- Поддерживайте согласованность таксономии событий во всем приложении

---

[Назад к индексу документации](../index.md)

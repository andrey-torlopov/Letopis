# Домены и действия

Letopis использует модель **домен + действие** для структурирования событий логирования. Домены представляют бизнес-области или подсистемы, а действия описывают конкретные операции внутри этих доменов.

## Встроенные домены и действия

Letopis предоставляет готовые домены и действия для типичных сценариев:

### UserDomain - Действия пользователя

```swift
public enum UserDomain: String, DomainProtocol, Sendable {
    case ui = "ui"
    case input = "user_input"
    case navigation = "user_navigation"
    case gesture = "user_gesture"
}

public enum UserAction: String, ActionProtocol, Sendable {
    case click, longPress, doubleClick, scroll
    case typeText, submit
    case swipeLeft, swipeRight, swipeUp, swipeDown
    case pullToRefresh, pinch, rotate
}
```

### NetworkDomain - Сетевые операции

```swift
public enum NetworkDomain: String, DomainProtocol, Sendable {
    case network = "network"
    case api = "api"
    case websocket = "websocket"
}

public enum NetworkAction: String, ActionProtocol, Sendable {
    case start, success, failure, retry, cancel, timeout
    case connected, disconnected
    case dataReceived, dataSent
}
```

### ErrorDomain - Обработка ошибок

```swift
public enum ErrorDomain: String, DomainProtocol, Sendable {
    case validation = "validation"
    case network = "network"
    case parsing = "parsing"
    case business = "business"
    case system = "system"
    case auth = "auth"
    case database = "database"
}

public enum ErrorAction: String, ActionProtocol, Sendable {
    case occurred, recovered, retrying, fatal
    case ignored, logged, handledByUser
}
```

### LifecycleDomain - События жизненного цикла

```swift
public enum LifecycleDomain: String, DomainProtocol, Sendable {
    case screen = "screen"
    case app = "app"
    case component = "component"
    case session = "session"
}

public enum LifecycleAction: String, ActionProtocol, Sendable {
    case willAppear, didAppear
    case willDisappear, didDisappear
    case willLoad, didLoad
    case willDestroy, didDestroy
}
```

### Использование встроенных доменов

```swift
// Логирование действия пользователя
logger.log()
    .domain(UserDomain.ui)
    .action(UserAction.click)
    .payload(["button": "submit"])
    .info("Пользователь нажал кнопку")

// Логирование сетевого запроса
logger.log()
    .domain(NetworkDomain.api)
    .action(NetworkAction.success)
    .payload(["endpoint": "/api/users"])
    .info("Запрос выполнен успешно")

// Логирование ошибки
logger.log()
    .domain(ErrorDomain.network)
    .action(ErrorAction.retrying)
    .critical()
    .error("Ошибка подключения")

// Логирование события жизненного цикла
logger.log()
    .domain(LifecycleDomain.screen)
    .action(LifecycleAction.didAppear)
    .payload(["screen_name": "profile"])
    .info("Экран отобразился")
```

## Пользовательские домены и действия

Вы можете создавать собственные домены и действия, соответствуя протоколам:

```swift
// Определите пользовательский домен
enum PaymentDomain: String, DomainProtocol {
    case payment = "payment"
    case subscription = "subscription"
    case billing = "billing"
}

// Определите пользовательские действия
enum PaymentAction: String, ActionProtocol {
    case initiated = "initiated"
    case processing = "processing"
    case completed = "completed"
    case failed = "failed"
    case refunded = "refunded"
}
```

## Использование пользовательских доменов и действий

```swift
logger.log()
    .domain(PaymentDomain.payment)
    .action(PaymentAction.completed)
    .payload(["amount": "99.99", "currency": "USD"])
    .info("Платеж выполнен успешно")
```

## Строковые домены и действия

Для быстрого прототипирования или простых случаев можно использовать строки напрямую:

```swift
logger.log()
    .domain("auth")
    .action("login_success")
    .payload(["user_id": "12345"])
    .info("Пользователь вошел в систему")
```

## Лучшие практики

- Используйте перечисления со строковыми значениями для типобезопасности
- Делайте типы соответствующими `Sendable` при работе с акторами
- Выбирайте описательные имена, отражающие вашу предметную область
- Поддерживайте согласованность таксономии событий во всем приложении

---

[Назад к индексу документации](../index.md)

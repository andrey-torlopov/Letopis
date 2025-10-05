# Быстрый старт

Это руководство поможет вам начать работу с Letopis за несколько минут.

## Импорт библиотеки

```swift
import Letopis
```

## Использование встроенных типов событий

Letopis предоставляет готовые типы событий для типичных сценариев:

```swift
// Используйте встроенные типы
import Letopis

// UserEvents - для действий пользователя
// NetworkEvents - для сетевых запросов
// ErrorEvents - для ошибок

// Или создайте собственные типы
enum AppEventType: String, EventTypeProtocol {
    case userAction = "user_action"
    case apiCall = "api_call"
    case error = "error"
    case system = "system"
}

// Действия
enum AppEventAction: String, EventActionProtocol {
    case view = "view"
    case fetch = "fetch"
    case networkFailure = "network_failure"
}
```

## Инициализация логгера

Настройте логгер с консольным интерцептором для разработки:

```swift
private let logger = Letopis(
    interceptors: [
        ConsoleInterceptor(
            // Можно указать события которые мы хотим явно прослушивать
            // Иначе будем обрабатывать все
            logTypes: [.info, .error],
            eventTypes: ["user_action", "api_call", "error"],
            priorities: [.default, .critical]
        )
    ]
)
```

## Примеры использования

### Быстрый старт с консольным логгером

```swift
// Используйте готовый статический логгер для быстрой отладки
Letopis.console.log("Быстрое сообщение для отладки")
Letopis.console.log("Ошибка", level: .error, event: "network")
```

### Логирование с встроенными типами

```swift
// Используйте встроенные типы событий
logger
    .event(UserEvents.tap)
    .action(UserAction.click)
    .payload(["button": "submit", "screen": "profile"])
    .info("Пользователь нажал кнопку")

// Сетевой запрос
logger
    .event(NetworkEvents.http)
    .action(NetworkAction.success)
    .payload(["endpoint": "/api/users"])
    .info("Запрос выполнен успешно")
```

### Логирование с собственными типами

```swift
logger
    .event(AppEventType.userAction)
    .action(AppEventAction.view)
    .payload(["user_id": "12345", "screen": "profile"])
    .source() // Добавляет информацию о файле и строке кода
    .info("Пользователь открыл экран профиля")
```

### Логирование API вызовов

```swift
logger
    .event(AppEventType.apiCall)
    .action(AppEventAction.fetch)
    .payload(["endpoint": "/api/users/12345", "method": "GET"])
    .info("Загрузка данных пользователя")
```

### Логирование ошибок с критическим приоритетом

```swift
logger
    .event(AppEventType.error)
    .action(AppEventAction.networkFailure)
    .critical()
    .payload(["error_code": "500", "retry_count": "3"])
    .error("Не удалось загрузить данные пользователя")
```

### Debug сообщения

```swift
logger
    .event(AppEventType.system)
    .debug("Внутренний кэш обновлен")
```

**Примечание:** В этом примере консольный интерцептор показывает только info и error сообщения, связанные с действиями пользователя, API вызовами и ошибками. Debug сообщения и другие типы событий фильтруются.

## Прямые вызовы

Если билдер избыточен, можно использовать прямые методы:

```swift
// Логирование успешной покупки
logger.info(
    "Покупка завершена успешно",
    isCritical: true,
    payload: ["product_id": "premium_plan", "amount": "9.99"],
    eventType: .analytics,
    eventAction: .purchase
)

// Логирование ошибки
logger.error(
    "Сетевой запрос не выполнен",
    isCritical: true,
    payload: ["url": "https://api.example.com/data", "status_code": "404"],
    eventType: .error,
    eventAction: .networkFailure
)
```

## Следующие шаги

- Изучите [ключевые возможности](features.md) библиотеки
- Узнайте больше об [архитектуре](architecture.md)
- Изучите [продвинутые примеры](examples/basic.md)
- Ознакомьтесь с [интерцепторами](advanced/interceptors.md)

---

[Вернуться к главному README](../../README-ru.md) | [Установка](installation.md)

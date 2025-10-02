## Простое логирование

```swift
import Letopis

let logger = Letopis(interceptors: [ConsoleInterceptor()])

logger.info("Приложение запущено")
logger.warning("Предупреждение о малом количестве памяти")
logger.error("Не удалось загрузить данные")
logger.debug("Кеш очищен")
```

## С типами событий

```swift
enum AppEventType: String, EventTypeProtocol {
    case userAction = "user_action"
    case apiCall = "api_call"
    case error = "error"
    case system = "system"
}

logger
    .event(AppEventType.userAction)
    .info("Пользователь нажал кнопку входа")
```

## С действиями

```swift
enum AppEventAction: String, EventActionProtocol {
    case view = "view"
    case fetch = "fetch"
    case networkFailure = "network_failure"
}

logger
    .event(AppEventType.apiCall)
    .action(AppEventAction.fetch)
    .info("Получение профиля пользователя")
```

## С полезной нагрузкой

```swift
logger
    .event(AppEventType.userAction)
    .payload(["user_id": "12345", "screen": "profile"])
    .info("Пользователь просмотрел профиль")
```

## С информацией об источнике

```swift
logger
    .event(AppEventType.error)
    .source() // Добавляет информацию о файле, функции и строке
    .error("Неожиданное значение nil")
```

## Полный пример

```swift
logger
    .event(AppEventType.apiCall)
    .action(AppEventAction.fetch)
    .priority(.critical)
    .payload([
        "endpoint": "/api/users/12345",
        "method": "GET",
        "retry_count": "3"
    ])
    .source()
    .error("Запрос API не выполнен после повторных попыток")
```

## Логирование ошибок

```swift
do {
    try performNetworkRequest()
} catch {
    logger
        .event(AppEventType.error)
        .priority(.critical)
        .error(error)
}
```

## Фильтрованный вывод в консоль

```swift
let logger = Letopis(
    interceptors: [
        ConsoleInterceptor(
            logTypes: [.info, .error], // Только info и error
            eventTypes: ["user_action", "api_call"], // Только эти типы
            priorities: [.critical] // Только критический приоритет
        )
    ])

// Это будет залогировано
logger.event("user_action").priority(.critical).info("Вход в систему")

// Это будет отфильтровано (тип debug)
logger.event("system").debug("Кеш обновлен")

// Это будет отфильтровано (приоритет default)
logger.event("user_action").info("Кнопка нажата")
```

---

[Назад к индексу документации](../index.md)

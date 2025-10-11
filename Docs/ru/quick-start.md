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

### Стандартный API (рекомендуется)

Основной способ логирования - использование прямых методов с опциональными параметрами:

```swift
// Простое информационное сообщение
logger.info("Приложение запущено")

// С метаданными
logger.info(
    "Пользователь открыл экран профиля",
    payload: ["user_id": "12345", "screen": "profile"]
)

// С типом события и действием
logger.info(
    "Пользователь открыл экран профиля",
    payload: ["user_id": "12345", "screen": "profile"],
    eventType: AppEventType.userAction,
    eventAction: AppEventAction.view
)

// Логирование предупреждений
logger.warning(
    "Приближение к лимиту API",
    payload: ["remaining": "10", "limit": "100"]
)

// Логирование ошибок (критично по умолчанию)
logger.error(
    "Не удалось загрузить данные пользователя",
    payload: ["error_code": "500", "retry_count": "3"],
    eventType: AppEventType.error,
    eventAction: AppEventAction.networkFailure
)

// Отладочные сообщения с информацией о местоположении в коде
logger.debug("Внутренний кэш обновлен", includeSource: true)
// Автоматически добавляет файл, функцию и номер строки в лог

// События аналитики
logger.analytics(
    "Покупка завершена успешно",
    payload: ["product_id": "premium_plan", "amount": "9.99"]
)
```

### Опциональный DSL API

Для пользователей, предпочитающих цепочечный синтаксис, доступен DSL API:

```swift
// Используйте встроенные типы событий
logger.log()
    .event(UserEvents.tap)
    .action(UserAction.click)
    .payload(["button": "submit", "screen": "profile"])
    .info("Пользователь нажал кнопку")

// Сетевой запрос
logger.log()
    .event(NetworkEvents.http)
    .action(NetworkAction.success)
    .payload(["endpoint": "/api/users"])
    .info("Запрос выполнен успешно")

// Логирование с собственными типами
logger.log()
    .event(AppEventType.userAction)
    .action(AppEventAction.view)
    .payload(["user_id": "12345", "screen": "profile"])
    .source() // Добавляет информацию о файле и строке кода
    .info("Пользователь открыл экран профиля")

// Логирование ошибок с критическим приоритетом
logger.log()
    .event(AppEventType.error)
    .action(AppEventAction.networkFailure)
    .critical()
    .payload(["error_code": "500", "retry_count": "3"])
    .error("Не удалось загрузить данные пользователя")
```

**Примечание:** В этом примере консольный интерцептор показывает только info и error сообщения, связанные с действиями пользователя, API вызовами и ошибками. Debug сообщения и другие типы событий фильтруются.

## Следующие шаги

- Изучите [ключевые возможности](features.md) библиотеки
- Узнайте больше об [архитектуре](architecture.md)
- Изучите [продвинутые примеры](examples/basic.md)
- Ознакомьтесь с [интерцепторами](advanced/interceptors.md)

---

[Вернуться к главному README](../../README-ru.md) | [Установка](installation.md)

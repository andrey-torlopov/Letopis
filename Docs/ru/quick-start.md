# Быстрый старт

Это руководство поможет вам начать работу с Letopis за несколько минут.

## Импорт библиотеки

```swift
import Letopis
```

## Использование встроенных доменов и действий

Letopis предоставляет готовые домены и действия для типичных сценариев:

```swift
import Letopis

// Встроенные домены:
// - UserDomain: ui, input, navigation, gesture
// - NetworkDomain: network, api, websocket
// - ErrorDomain: validation, network, parsing, business, system, auth, database
// - LifecycleDomain: screen, app, component, session

// Встроенные действия для каждого домена:
// - UserAction: click, longPress, scroll, submit, swipeLeft и т.д.
// - NetworkAction: start, success, failure, retry, timeout и т.д.
// - ErrorAction: occurred, recovered, retrying, fatal и т.д.
// - LifecycleAction: willAppear, didAppear, willLoad, didLoad и т.д.

// Вы также можете создавать собственные домены и действия
enum PaymentDomain: String, DomainProtocol {
    case payment = "payment"
    case subscription = "subscription"
}

enum PaymentAction: String, ActionProtocol {
    case initiated = "initiated"
    case completed = "completed"
    case failed = "failed"
}
```

## Инициализация логгера

Настройте логгер с консольным интерцептором для разработки:

```swift
private let logger = Letopis(
    interceptors: [
        ConsoleInterceptor(
            // Фильтр по уровню важности
            severities: [.info, .error, .warning],
            // Фильтр по назначению
            purposes: [.operational, .analytics],
            // Фильтр по доменам (типам событий)
            eventTypes: ["ui", "network", "payment"],
            // Фильтр по действиям
            actions: ["click", "success", "failed"]
        )
    ],
    // Настройка глобальных чувствительных ключей для автоматического маскирования
    sensitiveKeys: ["password", "token", "api_key", "ssn"]
)
```

## Примеры использования

### API прямых методов (быстро и просто)

Для быстрого логирования без метаданных используйте прямые методы:

```swift
// Простые сообщения
logger.info("Приложение запущено")
logger.warning("Приближение к лимиту API")
logger.error("Не удалось загрузить данные пользователя")
logger.debug("Внутренний кэш обновлен")

// С базовой полезной нагрузкой
logger.info(
    "Пользователь открыл экран профиля",
    payload: ["user_id": "12345", "screen": "profile"]
)

// С доменом и действием (используя строки)
logger.info(
    "Пользователь открыл экран профиля",
    domain: "ui",
    action: "screen_opened",
    payload: ["screen": "profile"]
)

// С доменом и действием на основе протоколов
logger.info(
    "Запрос API выполнен",
    domain: NetworkDomain.api,
    action: NetworkAction.success,
    payload: ["endpoint": "/users"]
)
```

### DSL API (рекомендуется для богатого логирования)

Для выразительного структурированного логирования с метаданными используйте fluent DSL:

```swift
// Используйте встроенные домены и действия
logger.log()
    .domain(UserDomain.ui)
    .action(UserAction.click)
    .payload(["button": "submit", "screen": "profile"])
    .info("Пользователь нажал кнопку")

// Сетевой запрос
logger.log()
    .domain(NetworkDomain.api)
    .action(NetworkAction.success)
    .payload(["endpoint": "/api/users"])
    .info("Запрос выполнен успешно")

// События жизненного цикла
logger.log()
    .domain(LifecycleDomain.screen)
    .action(LifecycleAction.didAppear)
    .payload(["screen_name": "profile"])
    .info("Экран отобразился")

// Логирование с информацией об источнике
logger.log()
    .domain(UserDomain.ui)
    .action(UserAction.click)
    .payload(["button": "checkout"])
    .source() // Добавляет файл, функцию и номер строки
    .info("Пользователь нажал кнопку оформления заказа")

// Логирование критических ошибок
logger.log()
    .domain(ErrorDomain.network)
    .action(ErrorAction.fatal)
    .critical()
    .payload(["error_code": "500", "retry_count": "3"])
    .error("Не удалось загрузить данные пользователя")

// Строковые домены для пользовательских событий
logger.log()
    .domain("payment")
    .action("completed")
    .payload(["amount": "99.99", "currency": "USD"])
    .info("Платеж обработан успешно")

// Маскирование чувствительных данных (включено по умолчанию)
logger.log()
    .domain("auth")
    .action("login_success")
    .payload(["user_id": "12345", "token": "abc123xyz"])
    .info("Пользователь вошел в систему")
// Вывод: user_id=12345, token=a***z (token автоматически замаскирован)
```

**Примечание:** Консольный интерцептор фильтрует события на основе настроенных уровней важности, назначений, доменов и действий. События, не соответствующие фильтрам, игнорируются.

## Следующие шаги

- Изучите [ключевые возможности](features.md) библиотеки
- Узнайте больше об [архитектуре](architecture.md)
- Изучите [продвинутые примеры](examples/basic.md)
- Ознакомьтесь с [интерцепторами](advanced/interceptors.md)

---

[Вернуться к главному README](../../README-ru.md) | [Установка](installation.md)

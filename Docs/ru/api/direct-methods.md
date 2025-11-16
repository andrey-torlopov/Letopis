# Прямые методы логирования — Опционально

API прямых методов предоставляет простой и прямой способ логирования сообщений без церемоний паттерна билдера. Используйте этот **опциональный подход**, когда вам нужно быстрое логирование без обширных метаданных.

## Когда использовать прямые методы

Прямые методы полезны, когда:

- Вам нужно быстро залогировать простое сообщение
- Вам не нужны обширные метаданные или контекст
- Вы мигрируете с другой системы логирования
- Критична производительность (немного меньше накладных расходов, чем у DSL)

> **Примечание:** Для большинства сценариев рекомендуется [API билдера Log (DSL)](log-builder.md), так как он обеспечивает лучшую структуру и читаемость.

## Доступные методы

Все методы принимают необязательные аргументы `isCritical`, `payload`, `eventType` и `eventAction`, которые объединяются в финальную полезную нагрузку.

### `info(_:isCritical:payload:eventType:eventAction:)`

Логирование информационных сообщений:

```swift
logger.info(
    "Покупка успешно завершена",
    isCritical: false,
    payload: ["product_id": "premium_plan", "amount": "9.99", "currency": "USD"],
    eventType: .analytics,
    eventAction: .purchase)
```

### `warning(_:isCritical:payload:eventType:eventAction:)`

Логирование предупреждений:

```swift
logger.warning(
    "Приближение к лимиту API",
    isCritical: true,
    payload: ["remaining_requests": "10", "reset_time": "60s"])
```

### `error(_:isCritical:payload:eventType:eventAction:)`

Логирование сообщений об ошибках или объектов Error (по умолчанию `isCritical: true`):

```swift
// Со строкой
logger.error(
    "Сбой сетевого запроса",
    isCritical: true,
    payload: ["url": "https://api.example.com/data", "status_code": "404"],
    eventType: .error,
    eventAction: .networkFailure)

// С объектом Error
do {
    try riskyOperation()
} catch {
    logger.error(error, isCritical: true)
}
```

### `debug(_:isCritical:payload:eventType:eventAction:)`

Логирование отладочной информации:

```swift
logger.debug(
    "Состояние кеша",
    payload: ["entries": "150", "size": "2.5MB"])
```

### `analytics(_:isCritical:payload:eventType:eventAction:)`

Логирование событий аналитики:

```swift
logger.analytics(
    "Пользователь зарегистрировался",
    payload: ["source": "email", "plan": "free"],
    eventType: .analytics)
```

## Методы быстрого доступа

Для быстрого логирования без создания пользовательских типов событий:

```swift
// Простой лог с уровнем
logger.log("Приложение запущено", level: .info)

// С критичностью
logger.log("Сбой платежа", level: .error, isCritical: true)

// С событием и действием
logger.log(
    "Действие пользователя", 
    level: .info, 
    event: "button_tap", 
    action: "checkout"
)

// Логирование ошибки
logger.log(networkError, isCritical: true, event: "network")
```

---

[Назад к индексу документации](../index.md)

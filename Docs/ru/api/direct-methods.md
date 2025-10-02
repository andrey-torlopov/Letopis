Если строитель избыточен, можно вызывать фасадные методы напрямую.

## Доступные методы

Все методы принимают необязательные аргументы `payload`, `eventType` и `eventAction`, которые объединяются в финальную полезную нагрузку.

### `info(_:priority:payload:eventType:eventAction:)`

Логирование информационных сообщений:

```swift
logger.info(
    "Покупка успешно завершена",
    priority: .critical,
    payload: ["product_id": "premium_plan", "amount": "9.99", "currency": "USD"],
    eventType: .analytics,
    eventAction: .purchase)
```

### `warning(_:priority:payload:eventType:eventAction:)`

Логирование предупреждений:

```swift
logger.warning(
    "Приближение к лимиту API",
    payload: ["remaining_requests": "10", "reset_time": "60s"])
```

### `error(_:priority:payload:eventType:eventAction:)`

Логирование сообщений об ошибках или объектов Error:

```swift
// Со строкой
logger.error(
    "Сбой сетевого запроса",
    priority: .critical,
    payload: ["url": "https://api.example.com/data", "status_code": "404"],
    eventType: .error,
    eventAction: .networkFailure)

// С объектом Error
do {
    try riskyOperation()
} catch {
    logger.error(error, priority: .critical)
}
```

### `debug(_:priority:payload:eventType:eventAction:)`

Логирование отладочной информации:

```swift
logger.debug(
    "Состояние кеша",
    payload: ["entries": "150", "size": "2.5MB"])
```

### `analytics(_:priority:payload:eventType:eventAction:)`

Логирование событий аналитики:

```swift
logger.analytics(
    "Пользователь зарегистрировался",
    payload: ["source": "email", "plan": "free"],
    eventType: .analytics)
```

## Когда использовать прямые методы

Прямые методы полезны, когда:

- Вам нужно быстро залогировать простое сообщение
- Вам не нужна гибкость строителя
- Вы мигрируете с другой системы логирования
- Критична производительность (немного меньше накладных расходов)

---

[Назад к индексу документации](../index.md)

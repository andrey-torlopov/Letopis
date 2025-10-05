Билдер `Log` предоставляет fluent интерфейс для построения событий логирования.

## Методы

### `action(_:)`

Устанавливает семантическое действие для события.

- Принимает любой тип, соответствующий `EventActionProtocol`, или строковый литерал

```swift
logger.action("user_click").info("Кнопка нажата")
```

### `event(_:)`

Устанавливает тип события.

- Принимает любой тип, соответствующий `EventTypeProtocol`, или строковый литерал

```swift
logger.event(AppEventType.userAction).info("Экран открыт")
```

### `payload(_:)`

Объединяет дополнительные пары ключ-значение в полезную нагрузку события.

```swift
logger
    .event(.apiCall)
    .payload(["endpoint": "/api/users", "method": "GET"])
    .info("Запрос API начат")
```

### `critical()`

Помечает событие как критичное, требующее немедленного внимания.

```swift
logger
    .event(.payment)
    .critical()
    .error("Сбой обработки платежа")
```

### `source(file:function:line:)`

Записывает информацию о месте вызова в полезную нагрузку. По умолчанию использует `#file`, `#function` и `#line`.

```swift
logger
    .source()
    .info("Отладочная информация с местоположением источника")
```

### `sensitive()` / `sensitive(keys:strategy:)`

Включает маскировку чувствительных данных в полезной нагрузке.

```swift
logger
    .payload(["email": "user@example.com", "card": "1234-5678"])
    .sensitive(keys: ["email", "card"])
    .info("Платеж обработан")
```

### Терминальные методы

Эти методы устанавливают тип события, сообщение и немедленно отправляют событие:

- `info(_:)` - Логирование информационного сообщения
- `warning(_:)` - Логирование предупреждения
- `error(_:)` или `error(_ error: Error, ...)` - Логирование ошибки
- `debug(_:)` - Логирование отладочного сообщения
- `analytics(_:)` - Логирование события аналитики

```swift
logger.event(.userAction).info("Пользователь вошел в систему")
logger.event(.system).warning("Мало памяти")
logger.event(.error).critical().error("Сбой сети")
logger.event(.debug).debug("Кеш обновлен")
logger.event(.analytics).analytics("Покупка завершена")
```

## Примеры использования

```swift
// Простой лог
logger.log().info("Приложение запущено")

// С типом события и действием
logger
    .event("user_action")
    .action("button_tap")
    .info("Пользователь нажал кнопку оформления заказа")

// Критичная ошибка с информацией об источнике
logger
    .event("payment")
    .source()
    .critical()
    .error("Таймаут платежного шлюза")

// Аналитика с данными
logger
    .event("purchase")
    .action("completed")
    .payload(["amount": "99.99", "currency": "USD"])
    .analytics("Покупка успешна")
```

---

[Назад к индексу документации](../index.md)

Для полного примера сетевого перехватчика с кешированием и мониторингом подключения см. [`Demo.swift`](../../../Sources/Letopis/Examples/Demo.swift).

## Продемонстрированные возможности

### Потокобезопасный перехватчик на основе актора

Безопасно обрабатывает сетевые логи в параллельных операциях.

### Умное кеширование

Сохраняет логи при отсутствии соединения и обрабатывает их при восстановлении подключения.

### Обработка на основе приоритета

Критические логи отправляются даже при плохих условиях сети.

### Мониторинг состояния сети

Различное поведение для:
- Онлайн
- Офлайн
- Плохое соединение

### Реальные сценарии

- Сбои сервера
- Логика повторных попыток
- Восстановление соединения

## Базовая реализация

```swift
actor NetworkInterceptor: LetopisInterceptor {
    private var cachedEvents: [LogEvent] = []
    private var isOnline: Bool = true
    
    func handle(_ logEvent: LogEvent) async {
        if isOnline {
            await sendToServer(logEvent)
        } else {
            cacheEvent(logEvent)
        }
    }
    
    func setOnline(_ online: Bool) {
        isOnline = online
        if online {
            Task {
                await processCachedEvents()
            }
        }
    }
    
    private func cacheEvent(_ event: LogEvent) {
        cachedEvents.append(event)
    }
    
    private func processCachedEvents() async {
        for event in cachedEvents {
            await sendToServer(event)
        }
        cachedEvents.removeAll()
    }
    
    private func sendToServer(_ event: LogEvent) async {
        // Реализация сетевого запроса
    }
}
```

## Использование

```swift
let networkInterceptor = NetworkInterceptor()
let logger = Letopis(interceptors: [networkInterceptor])

// Логирование событий
logger.info("Действие пользователя", priority: .critical)

// Обновление состояния сети
await networkInterceptor.setOnline(false)

// События будут кешироваться
logger.info("Событие в офлайне")

// Восстановление соединения
await networkInterceptor.setOnline(true)
// Кешированные события теперь отправлены
```

---

[Назад к индексу документации](../index.md)

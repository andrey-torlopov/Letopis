# LogMessage - Простой API для логирования

`LogMessage` предоставляет максимально простой интерфейс для логирования через Letopis. Просто создайте объект с параметрами и событие автоматически отправится.

## Философия

В отличие от API с методами или DSL-билдеров, `LogMessage` следует принципу "создал объект = отправил событие". Это похоже на паттерн `Mayday()` - просто заполните параметры и всё готово.

## Быстрый старт

### 1. Настройка при запуске приложения

```swift
import Letopis

// В AppDelegate или @main
LogDispatcher.configure(with: Letopis(
    interceptors: [ConsoleInterceptor()],
    healthCheckInterval: 30.0,
    sensitiveKeys: ["password", "token", "apiKey"]
))
```

### 2. Использование в коде

```swift
// Простое логирование - только severity и message
LogMessage(.debug, "Приложение запущено")
LogMessage(.info, "Сессия пользователя инициализирована")

// С domain и action
LogMessage(.notice, "Пользователь вошел в систему",
    domain: CommonDomain.auth,
    action: CommonAction.loggedIn
)

// Со всеми параметрами
LogMessage(.info, "Платеж обработан",
    domain: CommonDomain.business,
    action: CommonAction.completed,
    payload: ["amount": "99.99", "currency": "USD", "user_id": "12345"]
)

// Критическое событие
LogMessage(.error, "Сетевой запрос не удался",
    domain: CommonDomain.network,
    action: CommonAction.failed,
    isCritical: true,
    payload: ["url": "https://api.example.com"]
)

// Логирование ошибок
let error = NSError(domain: "com.app", code: 404)
LogMessage(.error, error,
    domain: CommonDomain.api,
    action: CommonAction.errorOccurred
)
```

## Доступные параметры

### Обязательные
- `severity: LogSeverity` - Уровень логирования (`.debug`, `.info`, `.notice`, `.warning`, `.error`, `.fault`)
- `message: String` - Сообщение, или `error: Error` для логирования ошибок

### Опциональные (с дефолтными значениями)
- `domain: DomainProtocol = DefaultDomain.empty` - Домен/подсистема
- `action: ActionProtocol = DefaultAction.empty` - Действие
- `purpose: LogPurpose = .operational` - Назначение события
- `isCritical: Bool = false` - Критичность события
- `payload: [String: String] = [:]` - Дополнительные данные
- `correlationID: UUID? = nil` - ID для связи событий

## Уровни логирования (LogSeverity)

```swift
LogMessage(.debug, "Детальная отладочная информация")    // Отладочная информация
LogMessage(.info, "Информационное сообщение")            // Информационное сообщение
LogMessage(.notice, "Заметное событие")                  // Заметное событие
LogMessage(.warning, "Предупреждение")                   // Предупреждение
LogMessage(.error, "Произошла ошибка")                   // Ошибка
LogMessage(.fault, "Критическая ошибка системы")         // Критическая ошибка системы
```

## Кастомные домены и действия

```swift
// Определите свои типы
enum PaymentDomain: String, DomainProtocol {
    case payments
    var value: String { rawValue }
}

enum PaymentAction: String, ActionProtocol {
    case initiated = "payment_initiated"
    case processing = "payment_processing"
    case succeeded = "payment_succeeded"
    case failed = "payment_failed"
    var value: String { rawValue }
}

// Используйте их
LogMessage(.info, "Платеж инициирован",
    domain: PaymentDomain.payments,
    action: PaymentAction.initiated,
    payload: ["amount": "149.99"]
)

LogMessage(.notice, "Платеж успешен",
    domain: PaymentDomain.payments,
    action: PaymentAction.succeeded,
    payload: ["transaction_id": "txn_123456"]
)
```

## Примеры из реальной жизни

### Аутентификация пользователя
```swift
LogMessage(.info, "Аутентификация пользователя начата",
    domain: CommonDomain.auth,
    action: CommonAction.started
)

LogMessage(.notice, "Учетные данные проверены",
    domain: CommonDomain.auth,
    action: CommonAction.validated
)

LogMessage(.notice, "Пользователь вошел в систему",
    domain: CommonDomain.auth,
    action: CommonAction.loggedIn,
    payload: ["user_id": "usr_12345", "method": "password"]
)
```

### Сетевые запросы
```swift
LogMessage(.debug, "API запрос инициирован",
    domain: CommonDomain.network,
    action: CommonAction.requestSent,
    payload: ["endpoint": "/api/v1/users", "method": "GET"]
)

LogMessage(.info, "Получен ответ API",
    domain: CommonDomain.network,
    action: CommonAction.responseReceived,
    payload: ["status": "200", "duration_ms": "245"]
)
```

### Обработка ошибок
```swift
let networkError = NSError(
    domain: "NetworkError",
    code: -1009,
    userInfo: [NSLocalizedDescriptionKey: "Отсутствует подключение к интернету."]
)

LogMessage(.error, networkError,
    domain: CommonDomain.network,
    action: CommonAction.failed,
    isCritical: true,
    payload: ["retry_count": "3"]
)
```

### Мониторинг производительности
```swift
LogMessage(.info, "Рендеринг экрана завершен",
    domain: CommonDomain.performance,
    action: CommonAction.measured,
    payload: ["screen": "HomeView", "render_time_ms": "42"]
)
```

## Тестирование

```swift
// Создайте mock interceptor
class MockInterceptor: LetopisInterceptor {
    var capturedEvents: [LogEvent] = []
    
    var name: String { "MockInterceptor" }
    
    func handle(_ event: LogEvent) async throws {
        capturedEvents.append(event)
    }
    
    func health() async -> Bool { true }
}

// Настройте mock в тестах
let mockInterceptor = MockInterceptor()
let mockLogger = Letopis(interceptors: [mockInterceptor])

LogDispatcher.reset()
LogDispatcher.configure(with: mockLogger)

// Выполните код, который логирует
LogMessage(.info, "Тестовое событие")

// Проверьте захваченные события
XCTAssertEqual(mockInterceptor.capturedEvents.count, 1)
XCTAssertEqual(mockInterceptor.capturedEvents[0].message, "Тестовое событие")
XCTAssertEqual(mockInterceptor.capturedEvents[0].severity, .info)

// Очистите после тестов
LogDispatcher.reset()
```

## Что происходит, если логгер не настроен?

В DEBUG режиме вы получите предупреждение в консоли:

```
⚠️ [Letopis] Cannot send log message - LogDispatcher is not configured!
   Message: [info] Пользователь вошел
   Configure LogDispatcher at app startup: LogDispatcher.configure(with: Letopis(...))
```

В RELEASE режиме события молча игнорируются.

## Доступ к созданному событию

```swift
let logMsg = LogMessage(.info, "Тестовое событие",
    domain: CommonDomain.app,
    action: CommonAction.started
)

// Доступ к созданному LogEvent
print(logMsg.logEvent.eventID)      // "app.started"
print(logMsg.logEvent.timestamp)    // 2024-01-01 10:00:00
print(logMsg.logEvent.severity)     // .info
```

## Когда использовать LogMessage?

- ✅ Когда нужна максимальная простота
- ✅ Когда достаточно указать параметры один раз
- ✅ Для быстрого логирования в любом месте кода
- ✅ Когда не нужен builder-паттерн или цепочки вызовов

## Альтернативы

- **Прямой Letopis** - Полный контроль через экземпляр `Letopis`
- **DSL (logger.log())** - Builder-паттерн с цепочками вызовов
- **Кастомные обертки** - Создайте свою собственную абстракцию

## См. также

- [Быстрый старт](quick-start.md)
- [Примеры](examples/)
- [API Reference](api/)

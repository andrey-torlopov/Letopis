# Опциональные хелперы

Letopis предоставляет опциональные вспомогательные утилиты для упрощения распространенных паттернов логирования. Эти хелперы построены поверх основного API логирования и являются полностью опциональными - вы можете использовать Letopis без них.

## Доступные хелперы

### 1. `@Logged` - Property Wrapper для логирования состояния

Автоматически логирует все операции чтения и записи свойств.

**Пример:**
```swift
class UserViewModel {
    let logger = Letopis.shared
    
    @Logged(wrappedValue: nil, "authToken", logger: logger)
    var authToken: String?
    
    // С кастомным domain и action
    @Logged(wrappedValue: nil, "userID", logger: logger, domain: "auth".asDomain, action: "state_change".asAction)
    var userID: String?
}

// Использование
viewModel.authToken = "abc123"  // Логирует: Property updated: old_value=nil, new_value=abc123
let token = viewModel.authToken  // Логирует: Property accessed: value=abc123
```

**Когда использовать:**
- Отслеживание изменений критичного состояния
- Отладка проблем с данными
- Аудит изменений значений

---

### 2. `@LoggedSet` - Property Wrapper только для записи

Логирует только операции записи. Лучшая производительность для часто читаемых свойств.

**Пример:**
```swift
class SettingsManager {
    let logger = Letopis.shared
    
    @LoggedSet(wrappedValue: "light", "theme", logger: logger)
    var currentTheme: String
}

// Использование
settings.currentTheme = "dark"  // Логируется
let theme = settings.currentTheme  // НЕ логируется
```

**Когда использовать:**
- Логирование только изменений
- Свойства с частым чтением (например, читается 1000 раз/сек, но меняется раз в минуту)

---

### 3. `LogLifecycle` - ViewModifier для SwiftUI

Автоматически логирует появление и исчезновение SwiftUI views.

**Пример:**
```swift
struct ProfileView: View {
    let logger = Letopis.shared
    
    var body: some View {
        Text("Profile")
            .logLifecycle("ProfileView", logger: logger)
    }
}

// С кастомным domain
struct DashboardView: View {
    var body: some View {
        Text("Dashboard")
            .logLifecycle("DashboardView", logger: .shared, domain: "analytics.screens".asDomain)
    }
}

// Использование модификатора напрямую для полного контроля
struct SettingsView: View {
    var body: some View {
        Text("Settings")
            .modifier(
                LogLifecycle(
                    name: "SettingsView",
                    logger: .shared,
                    domain: "ui.navigation".asDomain,
                    onAppearAction: "screen_shown".asAction,
                    onDisappearAction: "screen_hidden".asAction
                )
            )
    }
}
```

**Когда использовать:**
- Аналитика экранов
- Отслеживание навигации пользователя
- Отладка жизненного цикла

---

### 4. `logged()` - Scope-based логирование операций

Автоматически логирует начало, завершение и ошибки операций.

**Пример:**
```swift
class DataService {
    let logger = Letopis.shared
    
    // Async throwing операция
    func fetchUserData() async throws -> String {
        return try await Letopis.logged(
            "fetchUserData",
            logger: logger,
            domain: "api".asDomain,
            startAction: "request_started".asAction,
            completeAction: "request_completed".asAction,
            errorAction: "request_failed".asAction
        ) {
            try await apiClient.fetch()
        }
    }
    
    // Использование глобальной функции для удобства
    func syncData() async throws {
        try await logged("syncData", logger: logger, domain: "sync".asDomain) {
            try await Task.sleep(nanoseconds: 500_000_000)
        }
    }
    
    // Non-throwing async операция
    func loadCache() async -> [String] {
        return await logged("loadCache", logger: logger, domain: "cache".asDomain) {
            await cache.load()
        }
    }
    
    // Синхронная throwing операция
    func parseJSON(_ data: String) throws -> [String: Any] {
        return try logged("parseJSON", logger: logger, domain: "parsing".asDomain) {
            try JSONSerialization.jsonObject(with: data)
        }
    }
}
```

**Генерируемые логи:**
```
DEBUG [async] Operation started: operation=fetchUserData
DEBUG [async] Operation completed: operation=fetchUserData
// или
ERROR [async] Operation failed: operation=fetchUserData, error=Network timeout
```

**Когда использовать:**
- Асинхронные операции
- Отслеживание API вызовов
- Длительные операции
- Операции, подверженные ошибкам

---

### 5. Publisher Extensions - Логирование Combine

Автоматическое логирование для Combine publishers.

**Пример:**
```swift
import Combine

class NetworkManager {
    let logger = Letopis.shared
    private var cancellables = Set<AnyCancellable>()
    
    // Полное логирование (subscription, output, completion, cancel)
    func fetchData() {
        dataPublisher
            .logged("fetchData", logger: logger, domain: "network".asDomain)
            .sink { completion in
                // обработка completion
            } receiveValue: { value in
                // обработка value
            }
            .store(in: &cancellables)
    }
    
    // Логирование только ошибок
    func fetchWithErrorLogging() {
        dataPublisher
            .logErrors("fetchData", logger: logger)
            .sink { completion in
                // обработка completion
            } receiveValue: { value in
                // обработка value
            }
            .store(in: &cancellables)
    }
    
    // Логирование только lifecycle (без значений)
    func streamWithLifecycle() {
        dataStream
            .logLifecycle("dataStream", logger: logger)
            .sink { value in
                // обработка value
            }
            .store(in: &cancellables)
    }
    
    // Кастомные действия для разных событий
    func customPublisherLogging() {
        dataPublisher
            .logged(
                "customPublisher",
                logger: logger,
                domain: "custom".asDomain,
                subscribeAction: "observer_attached".asAction,
                outputAction: "data_received".asAction,
                completionAction: "stream_ended".asAction,
                logOutput: true
            )
            .sink { _ in }
            .store(in: &cancellables)
    }
}
```

**Когда использовать:**
- Отладка Combine цепочек
- Отслеживание реактивных потоков данных
- Аудит событий publisher'ов

---

## Интеграция с Letopis

Все хелперы используют единый API Letopis и поддерживают:

- ✅ Кастомные domain и action
- ✅ Payload с метаданными
- ✅ Маскирование чувствительных данных
- ✅ Correlation ID для связанных событий
- ✅ Все типы severity (debug, info, warning, error, fault)

## Best Practices

### 1. Создайте shared instance логгера

```swift
extension Letopis {
    static let shared = Letopis(
        interceptors: [ConsoleInterceptor()],
        sensitiveKeys: ["password", "token", "apiKey"]
    )
}
```

### 2. Используйте осмысленные имена

```swift
@Logged(wrappedValue: nil, "userAuthToken", logger: .shared)  // ✅ Хорошо
@Logged(wrappedValue: nil, "x", logger: .shared)              // ❌ Плохо
```

### 3. Выбирайте правильный domain

```swift
.logged("fetchUser", logger: .shared, domain: "api".asDomain)      // ✅ API вызовы
.logged("parseData", logger: .shared, domain: "parsing".asDomain)  // ✅ Обработка данных
.logged("saveCache", logger: .shared, domain: "cache".asDomain)    // ✅ Операции с кешем
```

### 4. Используйте @LoggedSet для частых операций

```swift
// Если свойство читается 1000 раз/сек, но меняется раз в минуту
@LoggedSet(wrappedValue: 0, "frameCount", logger: .shared)  // ✅ Логируем только изменения
```

### 5. Не перегружайте логирование

```swift
// ❌ Плохо: Логирование каждого обращения к массиву
@Logged(wrappedValue: [], "items", logger: .shared)
var items: [String]

// Каждая итерация логируется:
for item in viewModel.items { ... }  // Залогировано 100 раз!

// ✅ Лучше: Используйте @LoggedSet или логируйте вручную при необходимости
@LoggedSet(wrappedValue: [], "items", logger: .shared)
var items: [String]
```

## Советы по производительности

- **`@LoggedSet` быстрее `@Logged`** для часто читаемых свойств
- **`.logLifecycle()` не логирует каждый output** в Combine publishers
- **Всё логирование происходит асинхронно** через `Task.detached` - без блокировки
- **Используйте `.logErrors()` вместо `.logged()`** в Combine, когда интересуют только ошибки

## Полные примеры

Полные рабочие примеры всех хелперов см.:
- [`Sources/Letopis/Examples/HelpersExample.swift`](../../Sources/Letopis/Examples/HelpersExample.swift)

## Детали реализации

Все хелперы находятся в:
- [`Sources/Letopis/Helpers/Logged.swift`](../../Sources/Letopis/Helpers/Logged.swift) - Property wrappers
- [`Sources/Letopis/Helpers/LogLifecycle.swift`](../../Sources/Letopis/Helpers/LogLifecycle.swift) - SwiftUI lifecycle
- [`Sources/Letopis/Helpers/LoggedOperation.swift`](../../Sources/Letopis/Helpers/LoggedOperation.swift) - Логирование операций
- [`Sources/Letopis/Helpers/Publisher+Logging.swift`](../../Sources/Letopis/Helpers/Publisher+Logging.swift) - Расширения Combine

## Обзор

Перехватчики - это основной механизм расширения в Letopis. Они решают, что делать с событиями логирования: отправлять их по сети, сохранять, фильтровать или преобразовывать.

## Базовый протокол

Для соответствия `LetopisInterceptor` реализуйте единственный метод:

```swift
func handle(_ logEvent: LogEvent)
```

После вызова вы можете:

- Обрабатывать событие синхронно или асинхронно
- Отбросить его, если оно не соответствует вашим правилам
- Преобразовать полезную нагрузку и переслать в другую систему

## Консольный перехватчик

`ConsoleInterceptor` - это готовая к использованию реализация, которая фильтрует события по:

- Типу лога
- Приоритету
- Семантическим значениям
- Файлу-источнику

```swift
let consoleInterceptor = ConsoleInterceptor(
    logTypes: [.info, .error],
    eventTypes: ["user_action", "api_call"],
    priorities: [.default, .critical],
    sourceFiles: ["ViewController.swift"])
```

### Возможности

- Фильтры предоставляются как массивы и нормализуются в множества
- Форматирует события в строки
- Печатает с использованием замыкания `Printer` (по умолчанию `print`)
- Выполняется на `LoggingActor` для сериализованного вывода
- Подавляет вывод в не-DEBUG сборках

## Пользовательские перехватчики

### Пример: Перехватчик аналитики

```swift
final class AnalyticsInterceptor: LetopisInterceptor {
    private let analyticsService: AnalyticsService
    
    init(analyticsService: AnalyticsService) {
        self.analyticsService = analyticsService
    }
    
    func handle(_ logEvent: LogEvent) {
        // Отправлять только события аналитики и действий пользователя
        guard let eventType = logEvent.payload["event_type"],
              ["analytics", "user_action"].contains(eventType) else { return }
        
        let analyticsEvent = AnalyticsEvent(
            name: logEvent.message,
            properties: logEvent.payload,
            timestamp: logEvent.timestamp
        )
        
        analyticsService.track(analyticsEvent)
    }
}
```

### Пример: Перехватчик файлового хранилища

```swift
final class FileStorageInterceptor: LetopisInterceptor {
    private let fileManager: FileManager
    private let logFileURL: URL
    
    func handle(_ logEvent: LogEvent) {
        let jsonData = try? JSONEncoder().encode(logEvent)
        // Записать в файл...
    }
}
```

### Пример: Перехватчик базы данных

```swift
final class DatabaseInterceptor: LetopisInterceptor {
    private let database: Database
    
    func handle(_ logEvent: LogEvent) {
        database.insert(logEvent)
    }
}
```

## Советы по реализации

1. **Делайте перехватчики сфокусированными**: Каждый перехватчик должен иметь единственную ответственность
2. **Обрабатывайте ошибки грамотно**: Не позволяйте сбоям перехватчика ломать конвейер логирования
3. **Учитывайте производительность**: Избегайте блокирующих операций в методе handle
4. **Используйте акторы для потокобезопасности**: При управлении изменяемым состоянием используйте акторы Swift
5. **Тестируйте тщательно**: Пишите юнит-тесты для ваших перехватчиков

---

[Назад к индексу документации](../index.md)

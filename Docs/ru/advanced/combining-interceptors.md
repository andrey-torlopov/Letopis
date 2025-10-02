## Множественные перехватчики

`Letopis` поддерживает множественные перехватчики одновременно, позволяя вам комбинировать обработчики для каждого окружения.

## Настройка для продакшена

```swift
let logger = Letopis(
    interceptors: [
        ConsoleInterceptor(logTypes: [.error]), // Только ошибки в консоль
        AnalyticsInterceptor(analyticsService: mixpanel), // События пользователя в аналитику
        CrashReportingInterceptor(crashlytics: crashlytics), // Критические ошибки в отчеты о сбоях
        LocalStorageInterceptor(storage: coreDataStack) // Все события в локальную базу данных
    ])
```

## Настройка для разработки

```swift
#if DEBUG
let devLogger = Letopis(
    interceptors: [
        ConsoleInterceptor() // Все события в консоль для отладки
    ])
#endif
```

## Динамическое управление перехватчиками

Добавляйте перехватчики во время выполнения:

```swift
let logger = Letopis(interceptors: [ConsoleInterceptor()])

// Добавить сетевой перехватчик, когда пользователь входит в систему
logger.addInterceptor(NetworkInterceptor(apiClient: client))

// Добавить аналитику, когда пользователь принимает отслеживание
logger.addInterceptor(AnalyticsInterceptor(service: analytics))
```

## Поток событий

При вызове любого метода логирования:

1. Создается `LogEvent`
2. Событие передается каждому перехватчику по порядку
3. Каждый перехватчик обрабатывает событие независимо
4. Ни один перехватчик не блокирует других

## Комбинации перехватчиков

### Локальный + Удаленный

```swift
Letopis(interceptors: [
    LocalStorageInterceptor(), // Резервное копирование всех событий локально
    NetworkInterceptor() // Отправка на сервер при наличии соединения
])
```

### Консоль + Аналитика + Отчеты о сбоях

```swift
Letopis(interceptors: [
    ConsoleInterceptor(logTypes: [.debug, .info]),
    AnalyticsInterceptor(),
    CrashReportingInterceptor()])
```

### Маршрутизация на основе приоритета

```swift
Letopis(interceptors: [
    ConsoleInterceptor(), // Все события
    NetworkInterceptor(priorities: [.critical]), // Только критические в сеть
    FileInterceptor(logTypes: [.error]) // Только ошибки в файл
])
```

## Лучшие практики

1. **Порядок имеет значение**: Располагайте перехватчики в порядке важности
2. **Делайте перехватчики независимыми**: Не полагайтесь на порядок выполнения
3. **Обрабатывайте сбои грамотно**: Сбой одного перехватчика не должен влиять на другие
4. **Тестируйте комбинации**: Проверяйте, что перехватчики хорошо работают вместе
5. **Следите за производительностью**: Слишком много перехватчиков может повлиять на производительность

---

[Назад к индексу документации](../index.md)

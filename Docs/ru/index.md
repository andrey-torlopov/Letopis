# Документация Letopis

Добро пожаловать в полную документацию Letopis. Здесь вы найдете подробные руководства и справочники по всем возможностям.

Letopis предоставляет два взаимодополняющих API:
- **Стандартный API** (рекомендуется) — Прямые методы `info()`, `warning()`, `error()` для простого логирования
- **DSL API** (опционально) — Fluent паттерн билдера для выразительных цепочечных сценариев

## Содержание

### Начало работы
- [Установка](installation.md)
- [Быстрый старт](quick-start.md)

### Основные концепции
- [Ключевые возможности](features.md)
- [Обзор архитектуры](architecture.md)

### Справочник API
- [Прямые методы логирования](api/direct-methods.md) — **Рекомендуемый подход**
- [API билдера Log (DSL)](api/log-builder.md) — Опциональный fluent синтаксис
- [Типы событий и действия](api/event-types.md)

### Продвинутые темы
- [Интерцепторы](advanced/interceptors.md)
- [Приоритизация событий](advanced/prioritization.md)
- [Комбинирование интерцепторов](advanced/combining-interceptors.md)
- [Маскирование чувствительных данных](advanced/sensitive-data.md)

### Примеры
- [Примеры базового использования](examples/basic.md)
- [Сетевой интерцептор с кэшированием](examples/network-interceptor.md)
- [Собственные типы событий](examples/custom-events.md)
- [Примеры интеграции](examples/integration.md)

### Лучшие практики
- [Советы по внедрению](best-practices/adoption.md)
- [Тестирование интерцепторов](best-practices/testing.md)

---

[Вернуться к главному README](../../README-ru.md)

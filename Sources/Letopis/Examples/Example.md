# Example Files / Примеры файлов

**🇬🇧 English**

## Important Notice

The files located in the `Examples/` directory and some interceptor implementations are **example code only**. These files are provided for demonstration purposes and are used in unit tests to showcase the library's functionality.

**These example files:**
- ✅ Are safe to examine and learn from
- ✅ Demonstrate proper usage patterns
- ✅ Are used in automated tests
- ❌ **Do NOT affect the core library functionality**
- ❌ **Are NOT required for production use**

## Example Files Included

### `Sources/Letopis/Examples/HealthCheckExample.swift`
- Demonstrates the health check system in action
- Shows how interceptors can fail and recover
- Used for testing the health monitoring functionality

### `Sources/Letopis/Interceptors/NetworkInterceptor.swift`
- Example implementation of a network-based interceptor
- Demonstrates error handling and health checking
- Can simulate network failures for testing purposes
- **Note:** This is an example implementation, not a production-ready network client

## Usage in Tests

These examples are actively used in the test suite to verify that:
- Health check system works correctly
- Interceptors can handle failures gracefully
- Recovery mechanisms function as expected
- The library behaves correctly under various conditions

## Production Use

For production applications, you should:
1. Use the core library components (`Letopis`, `LetopisInterceptor` protocol, etc.)
2. Implement your own interceptors based on your specific needs
3. Refer to these examples for implementation patterns
4. Remove or ignore the example files as they are not needed in production

---

**🇷🇺 Русский**

## Важное примечание

Файлы, расположенные в директории `Examples/` и некоторые реализации интерцепторов являются **только примерами кода**. Эти файлы предоставлены для демонстрации возможностей библиотеки и используются в модульных тестах.

**Эти файлы-примеры:**
- ✅ Безопасны для изучения
- ✅ Демонстрируют правильные паттерны использования
- ✅ Используются в автоматических тестах
- ❌ **НЕ влияют на основную функциональность библиотеки**
- ❌ **НЕ требуются для продакшен использования**

## Включенные файлы-примеры

### `Sources/Letopis/Examples/HealthCheckExample.swift`
- Демонстрирует работу системы проверки здоровья
- Показывает, как интерцепторы могут падать и восстанавливаться
- Используется для тестирования функциональности мониторинга здоровья

### `Sources/Letopis/Interceptors/NetworkInterceptor.swift`
- Пример реализации сетевого интерцептора
- Демонстрирует обработку ошибок и проверку здоровья
- Может симулировать сетевые сбои для целей тестирования
- **Примечание:** Это пример реализации, а не готовый к продакшену сетевой клиент

## Использование в тестах

Эти примеры активно используются в тестах для проверки того, что:
- Система health check работает корректно
- Интерцепторы могут грамотно обрабатывать сбои
- Механизмы восстановления функционируют как ожидается
- Библиотека ведет себя корректно в различных условиях

## Использование в продакшене

Для продакшен приложений вам следует:
1. Использовать основные компоненты библиотеки (`Letopis`, протокол `LetopisInterceptor` и т.д.)
2. Реализовать собственные интерцепторы в соответствии с вашими потребностями
3. Обращаться к этим примерам для изучения паттернов реализации
4. Удалить или игнорировать файлы-примеры, так как они не нужны в продакшене


---

## File Structure / Структура файлов

```
Sources/Letopis/
├── Examples/                    # Example code / Примеры кода
│   └── HealthCheckExample.swift # Health check demo / Демо health check
├── Interceptors/
│   ├── LetopisInterceptor.swift      # Core protocol / Основной протокол
│   ├── ConsoleInterceptor.swift      # Production ready / Готов к продакшену
│   └── NetworkInterceptor.swift      # EXAMPLE ONLY / ТОЛЬКО ПРИМЕР
├── Models/
│   └── InterceptorHealthState.swift # Health tracking / Отслеживание здоровья
└── Letopis.swift                # Main logger class / Основной класс логгера
```

## Contributing / Вклад в проект

When contributing examples:
- Clearly mark them as examples in documentation
- Include them in the test suite
- Make sure they don't affect core functionality
- Keep them simple and educational

При добавлении примеров:
- Четко помечайте их как примеры в документации
- Включайте их в тестовый набор
- Убедитесь, что они не влияют на основную функциональность
- Делайте их простыми и образовательными

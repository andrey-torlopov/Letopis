# Architecture Overview

## Key Entities

### `Letopis`
The facade that creates events and fans them out to interceptors. It accepts an initial array of `LetopisInterceptor` and can be extended at runtime through `addInterceptor(_:)`.

### `Log`
A builder that lets you describe an event using chained calls before dispatching it.

### `LogEvent`
A DTO that contains:
- Identifier
- Timestamp
- Log type (`LogEventType`)
- Criticality flag (`isCritical: Bool`)
- Message
- Additional `payload` dictionary

### `EventTypeProtocol` / `ActionProtocol`
Protocols for semantic event classifiers. You can create your own types that conform to these protocols.

### `LetopisInterceptor`
A protocol for handlers that decide what to do with events (send them to the network, persist them, filter them, and so on).

## How It Works

1. **Event Creation**: Use the `Log` builder to create an event with all necessary metadata
2. **Event Dispatch**: The event is sent to all registered interceptors
3. **Interceptor Processing**: Each interceptor decides how to handle the event based on its logic
4. **Delivery**: Events are delivered to configured destinations (console, network, storage, etc.)

---

[Back to Documentation Index](index.md)

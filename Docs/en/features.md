# Key Features

## Unified logging entry point

The same facade sends events to both console and network, while interceptors let you connect any external services: analytics systems, monitoring tools, or custom backends. Developers work with a unified API without worrying about specific delivery channels.

## Extensible architecture through interceptors

Each interceptor can encapsulate its own filtering and routing logic, set individual priorities, and implement custom message delivery scenarios.

## Flexible network traffic management

Network interceptors can analyze connection state, decide whether to send events immediately or buffer them, and when overflow occurs — redirect data to external storage or libraries for deferred processing.

## Adaptation to external conditions

The logger dynamically adapts to network state and other environmental constraints, with behavior that can be finely tuned externally by adding custom interceptors without changing the core.

## Combining Logger and Analytics

Projects often have a separation between logger and analytics. For example:

```swift
analyticsFacade.sendEvent(.someEvent)
logger.log("Sent analytics with event .someEvent")
```

This results in wrapping analytics with logs. With Letopis, you can combine them by adding an interceptor:

```swift
logger.analytics(.someEvent, ...)
```

Now the event goes to analytics, console (if configured), and can be ignored by network loggers.

---

[Back to Documentation Index](index.md)

import Foundation

public class PublishedSubject<T> {
    public var latestValue: T?
    var state: State = .idle
    var subscribers: [Subscriber<T>] = []

    public init(_ value: T? = nil) {
        self.latestValue = value
    }

    public func subscribe(onEvent: @escaping ((Subscriber<T>.Event) -> Void)) -> Subscriber<T> {
        let subscriber = Subscriber(onEvent: onEvent)
        subscribers.append(subscriber)
        return subscriber
    }

    public func subscribe(onNext: ((T) -> Void)? = nil,
                          onError: ((Error) -> ())? = nil,
                          onComplete: (() -> Void)? = nil
    ) -> Subscriber<T> {
        let onEvent: ((Subscriber<T>.Event) -> Void) = {
            switch $0 {
            case .onComplete:
                onComplete?()
            case .onError(let error):
                onError?(error)
            case .onNext(let value):
                onNext?(value)
            }
        }
        return subscribe(onEvent: onEvent)
    }

    public func on(_ event: Event<T>) {
        // 1. change idle to subscribed
        // 2. notify every observers
        if let effect = state.handle(event) {
            process(effect)
        }
    }

    func process(_ effect: Effect) {
        switch effect {
        case .apply(let state):
            if case let .latestValue(value) = state {
                self.latestValue = value
            }
            self.state = state
            subscribers.forEach { subscriber in
                notify(subscriber, state: state)
            }
        }
    }

    func notify(_ subscriber: Subscriber<T>, state: State) {
        switch state {
        case .latestValue(let value):
            subscriber.onEvent(.onNext(value))
        case .error(let error):
            subscriber.onEvent(.onError(error))
        case .completed:
            subscriber.onEvent(.onComplete)
        case .idle:
            break
        }
    }

    enum State {
        case idle
        case latestValue(T)
        case error(Error)
        case completed

        var isFinished: Bool {
            switch self {
            case .completed, .error:
                return true
            case .idle, .latestValue:
                return false
            }
        }

        func handle(_ event: Event<T>) -> Effect? {
            guard isFinished == false else { return nil }
            switch event {
            case .tick:
                return nil
            case .completed:
                return .apply(.completed)
            case .next(let value):
                return .apply(.latestValue(value))
            case .error(let error):
                return .apply(.error(error))
            }
        }
    }

    enum Effect {
        case apply(State)
    }

    public static func from(_ array: [Event<T>]) -> (PublishedSubject<T>, () -> Void) {
        let subject = PublishedSubject<T>()
        var iterator = array.makeIterator()
        let next: (() -> Void) = {
            if let event = iterator.next() {
                subject.on(event)
            }
        }
        return (subject, next)
    }

    public static func concat(_ lhs: PublishedSubject<T>, _ rhs: PublishedSubject<T>) -> PublishedSubject<T> {
        let subject = PublishedSubject<T>()
        let sub1 = lhs.subscribe { event in
            switch event {
            case .onError(let error):
                subject.on(.error(error))
            case .onNext(let value):
                subject.on(.next(value))
            case .onComplete:
                let sub2 = rhs.subscribe { event in
                    switch event {
                    case .onError(let error):
                        subject.on(.error(error))
                    case .onNext(let value):
                        subject.on(.next(value))
                    case .onComplete:
                        subject.on(.completed)
                    }
                }
            }
        }
        return subject
    }

    public static func merge(_ lhs: PublishedSubject<T>, _ rhs: PublishedSubject<T>) -> PublishedSubject<T> {
        let subject = PublishedSubject<T>()
        let sub1 = lhs.subscribe { event in
            switch event {
            case .onError(let error):
                subject.on(.error(error))
            case .onNext(let value):
                subject.on(.next(value))
            case .onComplete:
                break
            }
        }

        let sub2 = rhs.subscribe { event in
            switch event {
            case .onError(let error):
                subject.on(.error(error))
            case .onNext(let value):
                subject.on(.next(value))
            case .onComplete:
                subject.on(.completed)
            }
        }
        return subject
    }
}

extension PublishedSubject where T == String {
    public static func from(_ string: T) -> (PublishedSubject<T>, () -> Void) {
        return PublishedSubject.from(Array(string).map { char in
            let value = "\(char)"
            switch value {
            case "-": return Event.tick
            case "|": return Event.completed
            default: return Event.next(value)
            }
        })
    }
}

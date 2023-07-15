import Foundation

public class Subscriber<T> {
    enum Event {
        case onNext(T)
        case onComplete
        case onError(Error)
    }

    var _onNext: ((T) -> Void)?
    var _onComplete: (() -> Void)?
    var _onError: ((Error) -> Void)?

    var events: [Event] = []

    init(onNext: ((T) -> Void)?,
         onComplete: (() -> Void)?,
         onError: ((Error) -> Void)?
    ) {
        _onNext = onNext
        _onComplete = onComplete
        _onError = onError
    }

    func onNext(_ value: T) {
        events.append(.onNext(value))
        _onNext?(value)
    }
    func onComplete() {
        events.append(.onComplete)
        _onComplete?()
    }
    func onError(_ error: Error) {
        events.append(.onError(error))
        _onError?(error)
    }
}

extension Subscriber.Event: CustomStringConvertible {
    var description: String {
        switch self {
        case .onComplete:
            return "onComplete"
        case .onNext(let value):
            return "onNext \(value)"
        case .onError(let error):
            return "onError \(error)"
        }
    }
}

extension Subscriber.Event: Equatable where T: Equatable {
    static func == (lhs: Subscriber<T>.Event, rhs: Subscriber<T>.Event) -> Bool {
        switch (lhs, rhs) {
        case let (.onNext(lhsValue), .onNext(rhsValue)):
            return lhsValue == rhsValue
        case (.onComplete, .onComplete):
            return true
        case (.onError(let lhsError), .onError(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}

public struct SubscriberEvent<T>: Equatable, CustomStringConvertible {
    public var description: String {
        return "\(id) \(event.description)"
    }

    public static func == (lhs: SubscriberEvent<T>, rhs: SubscriberEvent<T>) -> Bool {
        return lhs.description == rhs.description
    }

    var id: String
    var event: Subscriber<T>.Event
}

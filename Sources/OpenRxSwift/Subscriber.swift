import Foundation

struct Subscriber<T> {
    enum Event {
        case onNext(T)
        case onComplete
        case onError(Error)
    }

    var id: String
    var onNext: ((T) -> Void)?
    var onComplete: (() -> Void)?
    var onError: ((Error) -> Void)?
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

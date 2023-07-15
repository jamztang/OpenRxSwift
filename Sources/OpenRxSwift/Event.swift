import Foundation

public enum Event<T> {
    case tick
    case next(T)
    case error(Error)
    case completed
}

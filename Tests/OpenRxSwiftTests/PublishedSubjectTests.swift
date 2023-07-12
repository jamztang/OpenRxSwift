import XCTest
@testable import OpenRxSwift

final class PublishedSubjectTests: XCTestCase {

    var subject = PublishedSubject<Int>()

    func testSubscribe() {
        subject.subscribe("a")
        subject.on(.next(1))
        subject.subscribe("b")
        subject.on(.next(2))
        XCTAssertEqual(subject.events,
                       [
                        .init(id: "a", event: .onNext(1)),
                        .init(id: "a", event: .onNext(2)),
                        .init(id: "b", event: .onNext(2))
                       ])
    }

    func testComplete() {
        subject.subscribe("a")
        subject.on(.completed)
        subject.subscribe("b")
        subject.on(.next(1))
        subject.on(.error(SomeError.unexpected))

        XCTAssertEqual(subject.events,
                       [
                        .init(id: "a", event: .onComplete)
                       ])
    }

    func testError() {
        subject.subscribe("a")
        subject.on(.error(SomeError.unexpected))
        subject.subscribe("b")
        subject.on(.next(1))
        subject.on(.completed)
        XCTAssertEqual(subject.events,
                       [
                        .init(id: "a", event: .onError(SomeError.unexpected))
                       ])
    }

    enum SomeError: Swift.Error {
        case unexpected
    }
}

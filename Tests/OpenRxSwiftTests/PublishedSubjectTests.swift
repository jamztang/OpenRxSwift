import XCTest
@testable import OpenRxSwift

final class PublishedSubjectTests: XCTestCase {

    var subject = PublishedSubject<Int>()

    func testSubscribe() {
        let sub1 = subject.subscribe()
        subject.on(.next(1))
        let sub2 = subject.subscribe()
        subject.on(.next(2))
        XCTAssertEqual(sub1.events, [
            .onNext(1),
            .onNext(2)
        ])
        XCTAssertEqual(sub2.events, [
            .onNext(2)
        ])
    }

    func testComplete() {
        let sub1 = subject.subscribe()
        subject.on(.completed)
        let sub2 = subject.subscribe()
        subject.on(.next(1))
        subject.on(.error(SomeError.unexpected))

        XCTAssertEqual(sub1.events, [
            .onComplete
        ])
        XCTAssertEqual(sub2.events, [
        ])
    }

    func testError() {
        let sub1 = subject.subscribe()
        subject.on(.error(SomeError.unexpected))
        let sub2 = subject.subscribe()
        subject.on(.next(1))
        subject.on(.completed)

        XCTAssertEqual(sub1.events, [
            .onError(SomeError.unexpected)
        ])
        XCTAssertEqual(sub2.events, [
        ])
    }

    func testFromString() {
        let stream1 = "-1--2-|"
        let (subject, next) = PublishedSubject.from(stream1)
        let sub1 = subject.subscribe()

        XCTAssertEqual(subject.latestValue, nil)
        next()
        XCTAssertEqual(subject.latestValue, nil)
        next()
        XCTAssertEqual(subject.latestValue, "1")
        next()
        XCTAssertEqual(subject.latestValue, "1")
        next()
        XCTAssertEqual(subject.latestValue, "1")
        next()
        XCTAssertEqual(subject.latestValue, "2")
        next()
        XCTAssertEqual(subject.latestValue, "2")
        next()
        XCTAssertEqual(subject.latestValue, "2")

        XCTAssertEqual(sub1.events, [
            .onNext("1"),
            .onNext("2"),
            .onComplete
        ])
    }

    enum SomeError: Swift.Error {
        case unexpected
    }
}

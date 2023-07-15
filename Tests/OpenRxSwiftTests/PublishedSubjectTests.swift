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

    func testConcat() {
        let stream1 = "1---1--------1-|"
        let stream2 = "2-2-|"
//        let results = "1---1--------1-2-2-|"

        let (subject1, next1) = PublishedSubject.from(stream1)
        let (subject2, next2) = PublishedSubject.from(stream2)

        let stream3 = PublishedSubject.concat(subject1, subject2)
        let sub3 = stream3.subscribe()
        (0...stream1.utf16.count).forEach { _ in
            next1()
        }
        (0...stream2.utf16.count).forEach { _ in
            next2()
        }

        XCTAssertEqual(sub3.events, [
            .onNext("1"),
            .onNext("1"),
            .onNext("1"),
            .onNext("2"),
            .onNext("2"),
            .onComplete
        ])

    }

    func testMerge() {
        let stream1 = "a--b--c--d--e--|"
        let stream2 = "-------f--g----|"
        let results = "a--b--cf-dg-e--|"

        let (subject1, next1) = PublishedSubject.from(stream1)
        let (subject2, next2) = PublishedSubject.from(stream2)

        let stream3 = PublishedSubject.merge(subject1, subject2)
        let sub3 = stream3.subscribe()

        (0...stream1.utf16.count).forEach { _ in
            next1()
            next2()
        }

        let (subject4, next4) = PublishedSubject.from(results)
        let sub4 = subject4.subscribe()
        (0...results.utf16.count).forEach { _ in
            next4()
        }
        XCTAssertEqual(sub3.events, sub4.events)

        XCTAssertEqual(sub3.events, [
            .onNext("a"),
            .onNext("b"),
            .onNext("c"),
            .onNext("f"),
            .onNext("d"),
            .onNext("g"),
            .onNext("e"),
            .onComplete
        ])

    }

    enum SomeError: Swift.Error {
        case unexpected
    }
}

import XCTest
@testable import OpenRxSwift

final class ObservableTests: XCTestCase {

    func testCombineLatest() {
        let stream1 = "1---2--------3-4--5-|"
        let stream2 = "--a---b--c-d--------|"
        let results = "--A-B-C--D-E-F------|"

    }

    func testConcat() {
        let stream1 = "1---1--------1-|"
        let stream2 = "2-2-|"
        let results = "1---1--------1-2-2-|"
    }

    func testMerge() {
        let stream1 = "a--b--c--d--e--|"
        let stream2 = "-------f--g----|"
        let results = "a--b--cf-dg-e--|"
    }

    func testRace() {
        let stream1 = "--a-b-c----|"
        let stream2 = "-1-2-3-----|"
        let stream3 = "----0--0--0|"
        let results = "-1-2-3-----|"
    }

    func testStartWith() {
        let stream1 = "---2-3----|"
        let results = "1---2-3----|"
    }

    func testWithLatestFrom() {
        let stream1 = "-1--2-------3-4--5-|"
        let stream2 = "---a--b--c-d-------|"
        let results = "---A--------B-C--D-|"
    }

    func testZip() {
        let stream1 = "-1--2-------3-4--5-|"
        let stream2 = "---a--b--c-d-------|"
        let results = "---A--B-----C-D----|"
    }

}

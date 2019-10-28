/// This extension is copied from the pull request "Added support to serialize/deserialize BigInt in a manner similar
/// to BigUInt" Therefore:
///  Copyright © 2016-2017 Károly Lőrentey.
/// https://github.com/attaswift/BigInt/pull/61
/// Once the pull request is accepted into the framework, this class and its target has to be deleted.

@testable import BigInt
import Foundation
import XCTest

final class BigIntExtTests: XCTestCase {

    func testConversionToData() {
        func test(_ b: BigInt, _ d: Array<UInt8>, file: StaticString = #file, line: UInt = #line) {
            let expected = Data(d)
            let actual = b.serialize()
            XCTAssertEqual(actual, expected, file: file, line: line)
            XCTAssertEqual(BigInt(actual), b, file: file, line: line)
        }

        // Positive integers
        test(BigInt(), [])
        test(BigInt(1), [0x00, 0x01])
        test(BigInt(2), [0x00, 0x02])
        test(BigInt(0x0102030405060708), [0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08])
        test(BigInt(0x01) << 64 + BigInt(0x0203040506070809), [0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 09])

        // Negative integers
        test(BigInt(), [])
        test(BigInt(-1), [0x01, 0x01])
        test(BigInt(-2), [0x01, 0x02])
        test(BigInt(0x0102030405060708) * BigInt(-1), [0x01, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08])
        test((BigInt(0x01) << 64 + BigInt(0x0203040506070809)) * BigInt(-1), [0x01, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 09])

    }

    static let allTests = [
        ("testConversionToData", testConversionToData)
    ]
}


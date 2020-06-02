//
//  AppVersionTests.swift
//  CoronaContactTests
//

import XCTest
@testable import Stopp_Corona

class AppVersionTests: XCTestCase {

    func testLowerMajorAppVersion_isOlder() {
        // given
        let older = AppVersion(major: 2, minor: 5)
        let newer = AppVersion(major: 3, minor: 0)

        // then
        XCTAssertLessThan(older, newer)
    }

    func testLowerMinorAppVersion_isOlder_ifMajorIsEqual() {
        // given
        let older = AppVersion(major: 2, minor: 1)
        let newer = AppVersion(major: 2, minor: 5)

        // then
        XCTAssertLessThan(older, newer)
    }

}

//
//  AppVersionTests.swift
//  CoronaContact
//

import XCTest
@testable import Stopp_Corona

class AppVersionTests: XCTestCase {
    func testLowerMajorAppVersion_isOlder() {
        // given
        let older = AppVersion(major: 2, minor: 5, patch: 0)
        let newer = AppVersion(major: 3, minor: 0, patch: 0)

        // then
        XCTAssertLessThan(older, newer)
    }

    func testLowerMinorAppVersion_isOlder_ifMajorIsEqual() {
        // given
        let older = AppVersion(major: 2, minor: 1, patch: 4)
        let newer = AppVersion(major: 2, minor: 5, patch: 0)

        // then
        XCTAssertLessThan(older, newer)
    }

    func testLowerPatchAppVersion_isOlder_ifMajorAndMinorAreEqual() {
        // given
        let older = AppVersion(major: 2, minor: 1, patch: 1)
        let newer = AppVersion(major: 2, minor: 1, patch: 5)

        // then
        XCTAssertLessThan(older, newer)
    }

    func testAppVersion_initWithVersionString() {
        // given
        let fullString = "2.5.1"

        // when
        let version = AppVersion(versionString: fullString)

        // then
        XCTAssertEqual(version?.major, 2)
        XCTAssertEqual(version?.minor, 5)
        XCTAssertEqual(version?.patch, 1)
    }

    func testAppVersion_initWithPartialVersionString() {
        // given
        let partialString = "2"

        // when
        let version = AppVersion(versionString: partialString)

        // then
        XCTAssertEqual(version?.major, 2)
        XCTAssertEqual(version?.minor, 0)
        XCTAssertEqual(version?.patch, 0)
    }
}

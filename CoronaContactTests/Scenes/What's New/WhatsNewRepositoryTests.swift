//
//  WhatsNewRepositoryTests.swift
//  CoronaContact
//

import XCTest
@testable import Stopp_Corona

struct MockAppInfo: AppInfo {
    let appVersion: AppVersion
}

class WhatsNewRepositoryTests: XCTestCase {
    var sut: WhatsNewRepository!
    var mockAppInfo: MockAppInfo!

    override func setUp() {
        super.setUp()
        sut = WhatsNewRepository()
        mockAppInfo = MockAppInfo(appVersion: "3.0")
        sut.appInfo = mockAppInfo
    }

    override func tearDown() {
        sut = nil
        mockAppInfo = nil
        super.tearDown()
    }

    // MARK: - Helpers

    private func injectHistory(_ historyEntries: AppVersionHistory.AppVersionHistoryDictionary) {
        var history = AppVersionHistory()
        history.history = historyEntries
        sut.appVersionHistory = history
    }

    // MARK: - Tests

    func testIsWhatsNewAvailable_true() {
        // given
        sut.lastWhatsNewShown = "2.0"
        injectHistory(["3.0": "There's something new..."])

        // then
        XCTAssertTrue(sut.isWhatsNewAvailable)
    }

    func testIsWhatsNewAvailable_false() {
        // given
        sut.lastWhatsNewShown = "2.0"
        injectHistory(["1.0": "This was new in the old version..."])

        // then
        XCTAssertFalse(sut.isWhatsNewAvailable)
    }

    func testIsWhatsNewAvailable_falseOnFirstInstall() {
        // given
        sut.lastWhatsNewShown = .notPreviouslyInstalled
        injectHistory(["3.0": "There's something new..."])

        // then
        XCTAssertFalse(sut.isWhatsNewAvailable)
    }

    func testCurrentWhatsNewShown_updatesLastWhatsNewShown() {
        // given
        sut.lastWhatsNewShown = "2.0"

        // when
        sut.currentWhatsNewShown()

        // then
        XCTAssertEqual(sut.lastWhatsNewShown, "3.0")
    }

    func testIsWhatsNewAvailable_false_afterCurrentHasBeenShown() {
        // given
        sut.lastWhatsNewShown = "2.0"
        injectHistory(["3.0": "There's something new..."])

        // when
        sut.currentWhatsNewShown()

        // then
        XCTAssertFalse(sut.isWhatsNewAvailable)
    }
}

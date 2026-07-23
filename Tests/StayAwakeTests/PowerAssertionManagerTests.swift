import XCTest
@testable import StayAwake

@MainActor
final class PowerAssertionManagerTests: XCTestCase {
    func testStartAndStopKeepingAwake() {
        let manager = PowerAssertionManager()

        XCTAssertTrue(manager.isKeepingAwake, manager.errorMessage ?? "未能创建电源断言")

        manager.stopKeepingAwake()

        XCTAssertFalse(manager.isKeepingAwake)
        XCTAssertNil(manager.errorMessage)
    }
}

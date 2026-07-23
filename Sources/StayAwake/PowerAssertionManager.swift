import Foundation
import IOKit.pwr_mgt

/// 管理 macOS 的空闲睡眠电源断言。
///
/// 断言只会阻止由闲置触发的自动系统睡眠和显示器睡眠，
/// 不会阻止合盖、用户手动睡眠或电量耗尽导致的睡眠。
@MainActor
final class PowerAssertionManager: ObservableObject {
    @Published private(set) var isKeepingAwake = false
    @Published private(set) var errorMessage: String?

    private var systemSleepAssertion: IOPMAssertionID = 0
    private var displaySleepAssertion: IOPMAssertionID = 0

    init() {
        startKeepingAwake()
    }

    deinit {
        // deinit 不继承 MainActor；直接释放当前持有的断言，避免应用异常退出时残留。
        if systemSleepAssertion != 0 {
            IOPMAssertionRelease(systemSleepAssertion)
        }

        if displaySleepAssertion != 0 {
            IOPMAssertionRelease(displaySleepAssertion)
        }
    }

    func toggle() {
        isKeepingAwake ? stopKeepingAwake() : startKeepingAwake()
    }

    func startKeepingAwake() {
        guard !isKeepingAwake else { return }

        errorMessage = nil

        let systemResult = IOPMAssertionCreateWithName(
            kIOPMAssertionTypePreventUserIdleSystemSleep as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            "Stay Awake is preventing idle system sleep" as CFString,
            &systemSleepAssertion
        )

        guard systemResult == kIOReturnSuccess else {
            systemSleepAssertion = 0
            errorMessage = failureMessage(for: systemResult)
            return
        }

        let displayResult = IOPMAssertionCreateWithName(
            kIOPMAssertionTypePreventUserIdleDisplaySleep as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            "Stay Awake is preventing idle display sleep" as CFString,
            &displaySleepAssertion
        )

        guard displayResult == kIOReturnSuccess else {
            IOPMAssertionRelease(systemSleepAssertion)
            systemSleepAssertion = 0
            displaySleepAssertion = 0
            errorMessage = failureMessage(for: displayResult)
            return
        }

        isKeepingAwake = true
    }

    func stopKeepingAwake() {
        releaseAssertions()
        isKeepingAwake = false
        errorMessage = nil
    }

    private func releaseAssertions() {
        if systemSleepAssertion != 0 {
            IOPMAssertionRelease(systemSleepAssertion)
            systemSleepAssertion = 0
        }

        if displaySleepAssertion != 0 {
            IOPMAssertionRelease(displaySleepAssertion)
            displaySleepAssertion = 0
        }
    }

    private func failureMessage(for result: IOReturn) -> String {
        let code = String(UInt32(bitPattern: result), radix: 16, uppercase: true)
        return "无法创建电源断言（IOKit 错误 0x\(code)）。"
    }
}

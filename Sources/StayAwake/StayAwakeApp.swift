import AppKit
import SwiftUI

@main
struct StayAwakeApp: App {
    @StateObject private var powerManager = PowerAssertionManager()

    init() {
        // 这是一个纯菜单栏工具，不在 Dock 中显示图标。
        NSApplication.shared.setActivationPolicy(.accessory)
    }

    var body: some Scene {
        MenuBarExtra {
            MenuContent(powerManager: powerManager)
        } label: {
            Image(systemName: powerManager.isKeepingAwake ? "cup.and.saucer.fill" : "cup.and.saucer")
                .accessibilityLabel(powerManager.isKeepingAwake ? "Stay Awake：已保持唤醒" : "Stay Awake：已暂停")
        }
        .menuBarExtraStyle(.window)
    }
}
private struct MenuContent: View {
    @ObservedObject var powerManager: PowerAssertionManager

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label {
                Text(powerManager.isKeepingAwake ? "正在保持唤醒" : "已暂停保持唤醒")
                    .font(.headline)
            } icon: {
                Image(systemName: powerManager.isKeepingAwake ? "checkmark.circle.fill" : "pause.circle.fill")
                    .foregroundStyle(powerManager.isKeepingAwake ? .green : .secondary)
            }

            Text(powerManager.isKeepingAwake
                 ? "Mac 不会因闲置而自动睡眠或熄屏。"
                 : "Mac 将遵循系统默认的睡眠与熄屏设置。")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            if let errorMessage = powerManager.errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Divider()

            Button(powerManager.isKeepingAwake ? "暂停保持唤醒" : "开始保持唤醒") {
                powerManager.toggle()
            }
            .keyboardShortcut("k")

            Button("退出 Stay Awake") {
                powerManager.stopKeepingAwake()
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        }
        .padding(16)
        .frame(width: 280)
    }
}

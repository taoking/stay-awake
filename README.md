# Stay Awake

一个原生 macOS 菜单栏应用：运行期间阻止 Mac 自动进入系统睡眠或显示器睡眠，让其他应用与脚本持续运行。

发布后的可下载应用包将放在 [GitHub Releases](https://github.com/taoking/stay-awake/releases)。

## 设计目标

- 启动后自动开启保持唤醒。
- 可从菜单栏随时暂停或恢复。
- 退出应用时自动释放系统电源断言，恢复 macOS 默认节能策略。
- 不修改系统全局设置，不需要管理员权限。

## 开发与运行

需要 macOS 13 或更高版本以及 Xcode Command Line Tools。

```bash
swift build
swift run StayAwake
```

发布构建：

```bash
swift build -c release
```

生成可双击打开的应用包：

```bash
zsh scripts/build-app.sh
open 'dist/Stay Awake.app'
```

打包脚本会使用本机 ad-hoc 签名。首次打开未在 App Store 发布的本地应用时，若 macOS
显示安全提示，请在「系统设置 → 隐私与安全性」中确认打开。

运行测试：

```bash
swift test
```

## 工作方式

应用通过 IOKit 的电源管理断言创建 `PreventUserIdleSystemSleep` 和
`PreventUserIdleDisplaySleep` 两类断言。该机制仅阻止**空闲导致的**自动睡眠；
用户手动选择睡眠、合盖或系统强制休眠仍可能让电脑进入睡眠状态。

当菜单栏图标显示实心咖啡杯时，保持唤醒正在生效；点击图标可暂停、恢复或退出。

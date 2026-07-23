#!/bin/zsh
set -euo pipefail

script_dir="${0:A:h}"
project_dir="${script_dir:h}"
output_dir="${project_dir}/dist"
app_dir="${output_dir}/Stay Awake.app"

cd "$project_dir"
swift build -c release

rm -rf "$app_dir"
mkdir -p "$app_dir/Contents/MacOS"
cp ".build/release/StayAwake" "$app_dir/Contents/MacOS/StayAwake"
cp "Resources/Info.plist" "$app_dir/Contents/Info.plist"
codesign --force --deep --sign - "$app_dir"

echo "已生成：$app_dir"

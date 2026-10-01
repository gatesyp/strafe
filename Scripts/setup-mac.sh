#!/bin/bash
# Build and install strafe, then apply the macOS settings this fork relies on.
set -euo pipefail
cd "$(dirname "$0")/.."

./Scripts/bundle.sh
if pgrep -x strafe >/dev/null; then osascript -e 'tell application id "com.rileycx.strafe" to quit'; sleep 1; fi
rm -rf /Applications/strafe.app
mv build/strafe.app /Applications/

# strafe owns Ctrl+Left/Right, so macOS's animated "Move left/right a space" must let go.
for entry in "79 123" "81 124"; do
  set -- $entry
  defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add "$1" \
    "<dict><key>enabled</key><false/><key>value</key><dict><key>parameters</key><array><integer>65535</integer><integer>$2</integer><integer>8650752</integer></array><key>type</key><string>standard</string></dict></dict>"
done
/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u

# strafe follows app activation itself, so macOS's animated auto-switch must be off.
defaults write com.apple.dock workspaces-auto-swoosh -bool NO
killall Dock

open /Applications/strafe.app
open "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
cat <<'MSG'

Last step: in Privacy & Security > Accessibility, remove every strafe entry,
add /Applications/strafe.app with +, and turn it on. Then quit strafe from its
menu-bar icon and open it again. The event tap is only created at launch.
Every rebuild changes the ad-hoc signature, so repeat this after each rebuild.
MSG

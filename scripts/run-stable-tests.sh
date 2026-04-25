#!/usr/bin/env bash

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_PATH="$REPO_ROOT/WCS-Platform.xcodeproj"
SCHEME="WCS-Platform"
DESTINATION="platform=iOS Simulator,name=iPhone 17"
DERIVED_DATA_PATH="${DERIVED_DATA_PATH:-$HOME/Library/Developer/Xcode/DerivedData/WCSPlatformTests}"

if [[ ! -d "$PROJECT_PATH" ]]; then
  echo "error: expected project at $PROJECT_PATH"
  exit 1
fi

echo "==> Resetting simulator state"
xcrun simctl shutdown all || true
xcrun simctl erase all

echo "==> Running full stable test suite"
echo "    project: $PROJECT_PATH"
echo "    scheme: $SCHEME"
echo "    destination: $DESTINATION"
echo "    derived data: $DERIVED_DATA_PATH"

xcodebuild \
  -project "$PROJECT_PATH" \
  -scheme "$SCHEME" \
  -destination "$DESTINATION" \
  -derivedDataPath "$DERIVED_DATA_PATH" \
  -parallel-testing-enabled NO \
  test

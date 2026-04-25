#!/usr/bin/env bash

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_PATH="$REPO_ROOT/WCS-Platform.xcodeproj"
SCHEME="WCS-Platform"
CONFIGURATION="Release"
ARCHIVE_PATH="${ARCHIVE_PATH:-$REPO_ROOT/build/WCS-Platform-AppStore.xcarchive}"
EXPORT_PATH="${EXPORT_PATH:-$REPO_ROOT/build/AppStoreExport}"
EXPORT_OPTIONS_PLIST="${EXPORT_OPTIONS_PLIST:-$REPO_ROOT/scripts/ExportOptions-AppStore.plist}"

echo "==> Archiving App Store build"
echo "Project: $PROJECT_PATH"
echo "Scheme: $SCHEME"
echo "Configuration: $CONFIGURATION"
echo "Archive path: $ARCHIVE_PATH"

xcodebuild \
  -project "$PROJECT_PATH" \
  -scheme "$SCHEME" \
  -configuration "$CONFIGURATION" \
  -destination "generic/platform=iOS" \
  archive \
  -archivePath "$ARCHIVE_PATH"

echo "==> Exporting IPA (optional for CI/distribution)"
if [[ -f "$EXPORT_OPTIONS_PLIST" ]]; then
  xcodebuild \
    -exportArchive \
    -archivePath "$ARCHIVE_PATH" \
    -exportPath "$EXPORT_PATH" \
    -exportOptionsPlist "$EXPORT_OPTIONS_PLIST"
  echo "Export complete: $EXPORT_PATH"
else
  echo "Export options plist not found at $EXPORT_OPTIONS_PLIST"
  echo "Skipping export. Archive is ready for Xcode Organizer upload."
fi

echo "Done."

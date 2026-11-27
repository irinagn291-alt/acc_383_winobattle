#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
: "${GF_SIMULATOR_UDID:?Run the whole script through the factory simulator pool}"
label=${1:-iphone}
xcrun simctl boot "$GF_SIMULATOR_UDID"
xcrun simctl bootstatus "$GF_SIMULATOR_UDID" -b
qturn=1
rm -f "QA/retry-$label.request"
while :; do
  set +e
  xcodebuild -project Riacho.xcodeproj -scheme Riacho -configuration Development -destination "id=$GF_SIMULATOR_UDID" -parallel-testing-enabled NO -derivedDataPath Build/Derived -resultBundlePath "Evidence/$label-tests.xcresult" CODE_SIGNING_ALLOWED=YES CODE_SIGN_IDENTITY=- CODE_SIGNING_REQUIRED=NO ARCHS=arm64 ONLY_ACTIVE_ARCH=YES test > "Evidence/$label-tests.log" 2>&1
  outcome=$?
  set -e
  if [[ "$outcome" == 0 || "$qturn" == 3 ]]; then break; fi
  xcrun xcresulttool export attachments --path "Evidence/$label-tests.xcresult" --output-path "Evidence/$label-review-$qturn" > "Evidence/$label-review-$qturn.log" 2>&1 || true
  echo "QA failed; evidence exported. Waiting up to 180 seconds for retry-$label.request."
  qcut=$(( $(date +%s) + 180 ))
  while [[ ! -f "QA/retry-$label.request" && $(date +%s) -lt "$qcut" ]]; do sleep 1; done
  if [[ ! -f "QA/retry-$label.request" ]]; then break; fi
  rm -f "QA/retry-$label.request"
  mv "Evidence/$label-tests.xcresult" "Evidence/$label-attempt-$qturn.xcresult"
  cp "Evidence/$label-tests.log" "Evidence/$label-attempt-$qturn.log"
  qturn=$((qturn+1))
done
xcrun simctl launch "$GF_SIMULATOR_UDID" com.campeonatodobairro.app > "Evidence/$label-final-launch.log" 2>&1 || true
sleep 2
xcrun simctl io "$GF_SIMULATOR_UDID" screenshot "Evidence/$label-final.png" || true
container=$(xcrun simctl get_app_container "$GF_SIMULATOR_UDID" com.campeonatodobairro.app data 2>/dev/null || true)
if test -n "$container"; then
  cp "$container/Library/Application Support/neighborhood-v3.json" "Evidence/$label-persisted.json" || true
  find "$container/tmp" -name 'Certificate-*.pdf' -exec cp {} Evidence/ \;
fi
xcrun xcresulttool export attachments --path "Evidence/$label-tests.xcresult" --output-path "Evidence/$label-attachments" > "Evidence/$label-attachments.log" 2>&1 || true
exit "$outcome"

#!/usr/bin/env bash
# Retain native-crash evidence and retry a fresh engine process once on SIGABRT.
# Assertion failures, script/runtime errors and other exits always fail the gate.
set -u
log_root="${RUNNER_TEMP:-${TMPDIR:-/tmp}}"
log_file="$(mktemp "${log_root%/}/tomatocut-godot.XXXXXX.log")"
trap 'rm -f "$log_file"' EXIT
for attempt in 1 2; do
  "${TOMATOCUT_GODOT_BIN:-godot}" "$@" > "$log_file" 2>&1
  status=$?
  cat "$log_file"
  if ! python3 - "$log_file" <<'PY'
from pathlib import Path
import sys
text = Path(sys.argv[1]).read_text(errors='replace')
errors = [line for line in text.splitlines() if any(marker in line for marker in ['SCRIPT ERROR:', 'ERROR:', 'FAIL:'])]
if errors:
    message = 'Godot validation errors: ' + '\n'.join(errors[:5])
    print('::error::' + message.replace('%', '%25').replace('\r', '%0D').replace('\n', '%0A'))
sys.exit(1 if errors else 0)
PY
  then
    printf '::error::Godot reported a script, resource, runtime or assertion error; no retry.\n'
    exit 1
  fi
  if [ "$status" -eq 0 ]; then exit 0; fi
  kind=error
  if [ "$status" -eq 134 ] && [ "$attempt" -eq 1 ]; then kind=warning; fi
  python3 - "$log_file" "$kind" "$status" "$attempt" <<'PY'
from pathlib import Path
import sys
message = 'Godot exited %s on attempt %s. %s' % (sys.argv[3], sys.argv[4], '\n'.join(Path(sys.argv[1]).read_text(errors='replace').splitlines()[-15:]))
message = message.replace('%', '%25').replace('\r', '%0D').replace('\n', '%0A')
print('::%s::%s' % (sys.argv[2], message))
PY
  if [ "$status" -ne 134 ] || [ "$attempt" -eq 2 ]; then exit "$status"; fi
  printf 'Retrying once in a fresh Godot process after native SIGABRT.\n'
done

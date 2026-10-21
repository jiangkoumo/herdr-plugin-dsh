#!/bin/sh
# Open a sibling pane at the focused pane's cwd and start dsh-tui in it.
# mode: "new" (default) or "resume" (dsh-tui --resume).
#
# Herdr runs plugin commands with the plugin directory as cwd, so the caller's
# directory comes from HERDR_PLUGIN_CONTEXT_JSON.
set -eu

mode="${1:-new}"
herdr="${HERDR_BIN_PATH:-herdr}"

cwd=$(
    python3 - <<'PY'
import json, os
raw = os.environ.get("HERDR_PLUGIN_CONTEXT_JSON") or "{}"
try:
    ctx = json.loads(raw)
except Exception:
    ctx = {}
print(ctx.get("focused_pane_cwd") or ctx.get("workspace_cwd") or os.getcwd())
PY
)

if [ -n "${HERDR_PANE_ID:-}" ]; then
    out=$("$herdr" pane split --current --direction right --cwd "$cwd" --no-focus)
else
    out=$("$herdr" pane split --direction right --cwd "$cwd" --no-focus)
fi

pane=$(printf '%s' "$out" | python3 -c 'import json,sys; print(json.load(sys.stdin)["result"]["pane"]["pane_id"])')

case "$mode" in
    resume) cmd="dsh-tui --resume" ;;
    *) cmd="dsh-tui" ;;
esac

"$herdr" pane run "$pane" "$cmd"
printf '%s\n' "$pane"

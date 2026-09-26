# Adapted from adeism/OSkate arena/01a0cbce-oskate (commit 4bdcb144).
#!/usr/bin/env bash
# ---------------------------------------------------------------------------
#  OSkate harness -- build and run the headless test + benchmark suite.
#
#    tools/harness/check.sh                 # build and run everything
#    tools/harness/check.sh --slow          # include the exhaustive route search
#    tools/harness/check.sh --filter tricks # only tests whose name matches
#    tools/harness/check.sh --junit out.xml # also write a JUnit report
#    tools/harness/check.sh --tsan          # ThreadSanitizer on the audio race
#    tools/harness/check.sh --asan          # AddressSanitizer + UBSan
#
#  Exit code 0 = every test passed. The binary is built outside the repository
#  (default: $TMPDIR/opus-skate-harness) so nothing generated lands in git.
# ---------------------------------------------------------------------------
set -euo pipefail

root=$(cd "$(dirname "$0")/../.." && pwd)
cd "$root"

out=${OSKATE_HARNESS_BIN:-${TMPDIR:-/tmp}/opus-skate-harness}
mode=fast
runner_args=()
extra_cxx=()
jobs=${JOBS:-}

while [ $# -gt 0 ]; do
    case "$1" in
        --slow)      runner_args+=(--slow); shift ;;
        --filter)    runner_args+=(--filter "$2"); shift 2 ;;
        --repeat)    runner_args+=(--repeat "$2"); shift 2 ;;
        --no-bench)  runner_args+=(--no-bench); shift ;;
        --bench-only) runner_args+=(--bench-only); shift ;;
        --verbose)   runner_args+=(--verbose); shift ;;
        --monkey)    runner_args+=(--monkey "$2"); shift 2 ;;
        --junit)     runner_args+=(--junit "$2"); shift 2 ;;
        --tsan)      mode=tsan; shift ;;
        --asan)      mode=asan; shift ;;
        --out)       out=$2; shift 2 ;;
        --clean)     rm -f "$out"; echo "removed $out"; exit 0 ;;
        -h|--help)   sed -n '2,17p' "$0"; exit 0 ;;
        *)           echo "unknown option: $1" >&2; exit 2 ;;
    esac
done

case "$mode" in
    fast) cxx_flags=(-O2) ;;
    tsan) cxx_flags=(-O1 -g -fsanitize=thread) ;;
    asan) cxx_flags=(-O1 -g -fsanitize=address,undefined -fno-omit-frame-pointer) ;;
esac

exit $status

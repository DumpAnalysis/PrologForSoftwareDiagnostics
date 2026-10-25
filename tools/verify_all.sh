#!/bin/sh
# Replays every chapter's program blocks and transcripts through SWI-Prolog
# (tools/verify.py), then checks the shared module against the chapter
# definitions (tools/equivalence.py).  Run from the directory that holds
# src/ and tools/.  Requires swipl (9.0.4 was used for the manuscript).
#
# The complete output of every worker goes to build/verify_run.log.  Each
# chapter worker is validated on its own: it must exit 0 and print exactly
# one well-formed summary line naming the file it was given
# ("PASS src/NN-slug.md: N checks, 0 failures"), and no summary naming any
# other file; the check and failure counts are summed from those validated
# summaries only.  The equivalence worker must exit 0 and print its
# EQUIVALENCE SUMMARY line ending in PASS.  Any traceback, warning, error
# line or worker failure anywhere in the log fails the run.  The last line
# printed, and the last line of the log, is "RESULT: PASS (...)" or
# "RESULT: FAIL (...)" with every reason.  tools/wrapper_selftest.sh
# exercises this failure handling on stub workers.
set -u
cd "$(dirname "$0")/.."
LOG=build/verify_run.log
mkdir -p build
: > "$LOG"
{
  echo "verification run: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "swipl: $(swipl --version 2>&1)"
  echo "python: $(python3 --version 2>&1)"
} >> "$LOG"
reasons=""
expected=0
passes=0
fails=0
checks=0
failures=0
tmp=$(mktemp)
for f in src/[0-9]*.md src/B-shared-artifacts.md; do
  expected=$((expected + 1))
  echo "=== $f" >> "$LOG"
  python3 tools/verify.py "$f" > "$tmp" 2>&1
  rc=$?
  cat "$tmp" >> "$LOG"
  if [ "$rc" -ne 0 ]; then
    echo "WORKER FAILED: tools/verify.py $f exited $rc" >> "$LOG"
    reasons="$reasons; verify.py $f exited $rc"
  fi
  # exactly one well-formed summary, naming this file, and none naming another
  pat=$(printf '%s' "$f" | sed 's/[.[\*^$]/\\&/g')
  own=$(grep -ac "^\(PASS\|FAIL\) $pat: [0-9][0-9]* checks, [0-9][0-9]* failures$" "$tmp")
  any=$(grep -ac '^\(PASS\|FAIL\) src/' "$tmp")
  if [ "$own" -ne 1 ]; then
    reasons="$reasons; $f: $own summaries naming it (expected exactly 1)"
  fi
  if [ "$any" -ne "$own" ]; then
    reasons="$reasons; $f: $((any - own)) summaries naming another file or malformed"
  fi
  if [ "$own" -eq 1 ]; then
    line=$(grep -a "^\(PASS\|FAIL\) $pat: [0-9][0-9]* checks, [0-9][0-9]* failures$" "$tmp")
    c=$(printf '%s\n' "$line" | awk '{print $3}')
    n=$(printf '%s\n' "$line" | awk '{print $5}')
    checks=$((checks + c))
    failures=$((failures + n))
    case "$line" in
      PASS*) passes=$((passes + 1)) ;;
      *)     fails=$((fails + 1)) ;;
    esac
  fi
done
echo "--- equivalence (shared module vs chapter definitions) ---" >> "$LOG"
python3 tools/equivalence.py > "$tmp" 2>&1
rc=$?
cat "$tmp" >> "$LOG"
if [ "$rc" -ne 0 ]; then
  echo "WORKER FAILED: tools/equivalence.py exited $rc" >> "$LOG"
  reasons="$reasons; equivalence.py exited $rc"
fi
eqs=$(grep -ac '^EQUIVALENCE SUMMARY: .*PASS$' "$tmp")
[ "$eqs" -eq 1 ] || reasons="$reasons; $eqs passing equivalence summaries (expected exactly 1)"
rm -f "$tmp"
[ "$passes" -eq "$expected" ] || reasons="$reasons; $passes of $expected chapter files report PASS"
[ "$fails" -eq 0 ] || reasons="$reasons; $fails chapter files report FAIL"
[ "$failures" -eq 0 ] || reasons="$reasons; $failures checks failed"
if grep -aq 'Traceback\|^Warning\|^ERROR\|WORKER FAILED' "$LOG"; then
  reasons="$reasons; diagnostics in the log"
fi
summary="$expected files, $checks checks, $failures failures"
if [ -z "$reasons" ]; then
  result="RESULT: PASS ($summary)"
else
  result="RESULT: FAIL ($summary${reasons})"
fi
echo "$summary" | tee -a "$LOG"
echo "$result" | tee -a "$LOG"
[ -z "$reasons" ]

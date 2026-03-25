#!/usr/bin/env bash
# ============================================================
#  POMODORO
#  Waybar custom module — 25/5 with long break after 4
# ============================================================

STATE_FILE="/tmp/pomodoro_state"
PHASE_FILE="/tmp/pomodoro_phase"
COUNT_FILE="/tmp/pomodoro_count"
COOLDOWN_FILE="/tmp/pomodoro_cooldown"

# ── TIMINGS (seconds) ────────────────────────────────────────
WORK_TIME=$((25 * 60))
SHORT_BREAK=$((5 * 60))
LONG_BREAK=$((20 * 60))
POMODOROS_BEFORE_LONG=4
COOLDOWN=8

# ── HELPERS ──────────────────────────────────────────────────
get_phase() { [[ -f "$PHASE_FILE" ]] && cat "$PHASE_FILE" || echo "work"; }
get_count() { [[ -f "$COUNT_FILE" ]] && cat "$COUNT_FILE" || echo 0; }
set_phase() { echo "$1" >"$PHASE_FILE"; }
set_count() { echo "$1" >"$COUNT_FILE"; }
set_endtime() { echo "$(($(date +%s) + $1))" >"$STATE_FILE"; }

_notify() { notify-send -u "${1:-low}" "Pomodoro" "$2"; }

# ── PHASE TRANSITION ─────────────────────────────────────────
start_next_phase() {
  local phase count
  phase=$(get_phase)
  count=$(get_count)

  rm -f "$COOLDOWN_FILE"

  if [[ "$phase" == "work" ]]; then
    count=$((count + 1))
    set_count "$count"

    if ((count % POMODOROS_BEFORE_LONG == 0)); then
      set_phase "long"
      set_endtime "$LONG_BREAK"
      _notify normal "Long break! (20 min) — #$count"
    else
      set_phase "short"
      set_endtime "$SHORT_BREAK"
      _notify normal "Short break (5 min) — #$count"
    fi
  else
    set_phase "work"
    set_endtime "$WORK_TIME"
    _notify low "Back to work! (25 min)"
  fi
}

# ── COMMANDS ─────────────────────────────────────────────────
case "$1" in
toggle | start)
  if [[ -f "$STATE_FILE" || -f "$COOLDOWN_FILE" ]]; then
    rm -f "$STATE_FILE" "$PHASE_FILE" "$COUNT_FILE" "$COOLDOWN_FILE"
    _notify low "Timer stopped"
  else
    set_phase "work"
    set_count 0
    set_endtime "$WORK_TIME"
    _notify low "Focus time started — 25 min"
  fi
  exit 0
  ;;
stop | reset)
  rm -f "$STATE_FILE" "$PHASE_FILE" "$COUNT_FILE" "$COOLDOWN_FILE"
  _notify low "Timer reset"
  exit 0
  ;;
esac

# ── DISPLAY ──────────────────────────────────────────────────
if [[ ! -f "$STATE_FILE" && ! -f "$COOLDOWN_FILE" ]]; then
  echo '{"text":"Start","class":"idle"}'
  exit 0
fi

now=$(date +%s)

# Cooldown handling
if [[ -f "$COOLDOWN_FILE" ]]; then
  end=$(cat "$COOLDOWN_FILE")
  rem=$((end - now))
  if ((rem <= 0)); then
    start_next_phase
  else
    echo "{\"text\":\"↻\",\"tooltip\":\"Auto-restart in ${rem}s\"}"
    exit 0
  fi
fi

# Countdown
end_time=$(cat "$STATE_FILE")
remaining=$((end_time - now))
phase=$(get_phase)
count=$(get_count)

if ((remaining <= 0)); then
  echo "$((now + COOLDOWN))" >"$COOLDOWN_FILE"
  rm -f "$STATE_FILE"
  _notify normal "$phase finished — next phase starting soon"
  echo '{"text":"00:00","class":"finished"}'
  exit 0
fi

min=$((remaining / 60))
sec=$((remaining % 60))

case "$phase" in
work) icon="" class="work" tooltip="Work #$((count + 1))" ;;
short) icon="☕" class="break" tooltip="Short break" ;;
long) icon="🌴" class="long" tooltip="Long break" ;;
*) icon="?" class="error" tooltip="Unknown phase" ;;
esac

printf '{"text":"%s %02d:%02d","class":"%s","tooltip":"%s"}\n' \
  "$icon" "$min" "$sec" "$class" "$tooltip"

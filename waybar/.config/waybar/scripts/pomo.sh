#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────
# 「✦ POMODORO v2 ✦」   Classic 25/5 + long break after 4
# ─────────────────────────────────────────────────────────────────────
# Waybar custom module – real Pomodoro flow
# ─────────────────────────────────────────────────────────────────────

STATE_FILE="/tmp/pomodoro_state"       # current end timestamp
PHASE_FILE="/tmp/pomodoro_phase"       # "work" | "short" | "long"
COUNT_FILE="/tmp/pomodoro_count"       # how many pomodoros completed
COOLDOWN_FILE="/tmp/pomodoro_cooldown" # temporary pause after break ends

# ─── Timings (in seconds) ───────────────────────────────────────────────
WORK_TIME=$((25 * 60))  # 25 min
SHORT_BREAK=$((5 * 60)) # 5 min
LONG_BREAK=$((20 * 60)) # 20 min long break (after 4 pomodoros)
POMODOROS_BEFORE_LONG=4

# ─── Helper functions ───────────────────────────────────────────────────
get_phase() { [ -f "$PHASE_FILE" ] && cat "$PHASE_FILE" || echo "work"; }
get_count() { [ -f "$COUNT_FILE" ] && cat "$COUNT_FILE" || echo 0; }
set_phase() { echo "$1" >"$PHASE_FILE"; }
set_count() { echo "$1" >"$COUNT_FILE"; }
set_endtime() { echo "$(($(date +%s) + $1))" >"$STATE_FILE"; }

start_next_phase() {
  local current_phase=$(get_phase)
  local count=$(get_count)

  rm -f "$COOLDOWN_FILE"

  if [ "$current_phase" = "work" ]; then
    # Work just finished → start break
    count=$((count + 1))
    set_count "$count"

    if [ "$count" -ge "$POMODOROS_BEFORE_LONG" ] && [ $((count % POMODOROS_BEFORE_LONG)) -eq 0 ]; then
      set_phase "long"
      set_endtime "$LONG_BREAK"
      notify-send -u normal "Pomodoro" "Long break! (20 min) – #$count"
    else
      set_phase "short"
      set_endtime "$SHORT_BREAK"
      notify-send -u normal "Pomodoro" "Short break (5 min) – #$count"
    fi
  else
    # Break just finished → start new work
    set_phase "work"
    set_endtime "$WORK_TIME"
    notify-send -u low "Pomodoro" "Back to work! (25 min)"
  fi
}

# ─── Commands ───────────────────────────────────────────────────────────
case "$1" in
start | toggle)
  if [ -f "$STATE_FILE" ] || [ -f "$COOLDOWN_FILE" ]; then
    # running → stop everything
    rm -f "$STATE_FILE" "$PHASE_FILE" "$COUNT_FILE" "$COOLDOWN_FILE"
    notify-send "Pomodoro" "Timer stopped / reset"
  else
    # not running → start fresh work session
    set_phase "work"
    set_count 0
    set_endtime "$WORK_TIME"
    notify-send -u low "Pomodoro" "Focus time started — 25 min"
  fi
  exit 0
  ;;

stop | reset)
  rm -f "$STATE_FILE" "$PHASE_FILE" "$COUNT_FILE" "$COOLDOWN_FILE"
  notify-send "Pomodoro" "Timer reset"
  exit 0
  ;;
esac

# ─── Main display logic ─────────────────────────────────────────────────
if [ ! -f "$STATE_FILE" ] && [ ! -f "$COOLDOWN_FILE" ]; then
  echo '{"text":"Start","class":"idle"}'
  exit 0
fi

now=$(date +%s)

# Cooldown / auto-restart handling
if [ -f "$COOLDOWN_FILE" ]; then
  end=$(cat "$COOLDOWN_FILE")
  rem=$((end - now))
  if [ $rem -le 0 ]; then
    start_next_phase
  else
    echo '{"text":"↻","tooltip":"Auto-restart in '"$rem"'s"}'
    exit 0
  fi
fi

# Normal countdown
end_time=$(cat "$STATE_FILE")
remaining=$((end_time - now))

phase=$(get_phase)
count=$(get_count)

if [ $remaining -le 0 ]; then
  # Phase ended → move to next phase after short cooldown
  cooldown_end=$((now + 8)) # 8 seconds grace/auto-continue
  echo "$cooldown_end" >"$COOLDOWN_FILE"
  notify-send "Pomodoro" "$phase finished — next phase starting soon"
  echo '{"text":"00:00","class":"finished"}'
  exit 0
fi

min=$((remaining / 60))
sec=$((remaining % 60))

case "$phase" in
work) icon="" class="work" tooltip="Work #$((count + 1))" ;;
short) icon="☕" class="break" tooltip="Short break" ;;
long) icon="🌴" class="long" tooltip="Long break" ;;
*) icon="?" class="error" tooltip="Unknown phase" ;;
esac

printf '{"text":"%s %02d:%02d","class":"%s","tooltip":"%s"}\n' \
  "$icon" "$min" "$sec" "$class" "$tooltip"

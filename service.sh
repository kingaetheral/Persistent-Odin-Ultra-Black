#!/system/bin/sh
# OLED Ultra Black Keeper - boot service (runs as root via Magisk)

CONF=/data/adb/ultra_black_keeper/config.conf
LOG=/data/adb/ultra_black_keeper/keeper.log

log() { echo "$(date '+%m-%d %H:%M:%S') $1" >> "$LOG"; }

# Wait for the system to finish booting
until [ "$(getprop sys.boot_completed)" = "1" ]; do
  sleep 5
done
sleep 10  # let Settings/vendor services settle first

[ -f "$CONF" ] || { log "no config, exiting"; exit 0; }
. "$CONF"

: > "$LOG"
log "service started"

apply() {
  applied=0
  if [ -n "$SETTING_NAMESPACE" ] && [ -n "$SETTING_KEY" ]; then
    cur=$(settings get "$SETTING_NAMESPACE" "$SETTING_KEY" 2>/dev/null)
    if [ "$cur" != "$SETTING_VALUE" ]; then
      settings put "$SETTING_NAMESPACE" "$SETTING_KEY" "$SETTING_VALUE" \
        && log "settings: $SETTING_NAMESPACE/$SETTING_KEY $cur -> $SETTING_VALUE"
    fi
    applied=1
  fi
  if [ -n "$PROP_KEY" ]; then
    cur=$(getprop "$PROP_KEY")
    if [ "$cur" != "$PROP_VALUE" ]; then
      setprop "$PROP_KEY" "$PROP_VALUE" \
        && log "prop: $PROP_KEY $cur -> $PROP_VALUE"
    fi
    applied=1
  fi
  if [ -n "$SYSFS_PATH" ] && [ -e "$SYSFS_PATH" ]; then
    cur=$(cat "$SYSFS_PATH" 2>/dev/null)
    if [ "$cur" != "$SYSFS_VALUE" ]; then
      echo "$SYSFS_VALUE" > "$SYSFS_PATH" \
        && log "sysfs: $SYSFS_PATH $cur -> $SYSFS_VALUE"
    fi
    applied=1
  fi
  [ "$applied" = "0" ] && log "nothing configured - edit $CONF and run find_key.sh"
}

apply

# Optional watchdog: keep re-asserting the setting
if [ "${WATCHDOG_INTERVAL:-0}" -gt 0 ] 2>/dev/null; then
  log "watchdog active (every ${WATCHDOG_INTERVAL}s)"
  while true; do
    sleep "$WATCHDOG_INTERVAL"
    apply
  done
fi

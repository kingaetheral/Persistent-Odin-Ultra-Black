#!/system/bin/sh
# Finds which setting key the "OLED Ultra Black Mode" toggle changes.
# Run as root:  su -c "sh /data/adb/ultra_black_keeper/find_key.sh"

TMP=/data/local/tmp/ubk
mkdir -p "$TMP"

snap() {
  settings list system > "$TMP/system.$1" 2>/dev/null
  settings list global > "$TMP/global.$1" 2>/dev/null
  settings list secure > "$TMP/secure.$1" 2>/dev/null
  getprop           > "$TMP/props.$1"  2>/dev/null
}

echo ""
echo "== Ultra Black key finder =="
echo ""
echo "1) Make sure Ultra Black Mode is OFF in Settings."
printf "   Press Enter when ready... "
read x
snap before

echo ""
echo "2) Now toggle Ultra Black Mode ON in Settings."
printf "   Press Enter when done... "
read x
snap after

echo ""
echo "== Changes detected =="
for ns in system global secure props; do
  d=$(diff "$TMP/$ns.before" "$TMP/$ns.after" 2>/dev/null | grep '^[<>]')
  if [ -n "$d" ]; then
    echo ""
    echo "[$ns]"
    echo "$d"
  fi
done
echo ""
echo "Look for a line mentioning black/oled/mura or similar."
echo "Example:  > oled_ultra_black_mode=1   in [system]"
echo "Then edit /data/adb/ultra_black_keeper/config.conf:"
echo "  SETTING_NAMESPACE=system"
echo "  SETTING_KEY=oled_ultra_black_mode"
echo "  SETTING_VALUE=1"
echo "(or PROP_KEY=... if the change was in [props])"
echo "Reboot afterwards."
rm -rf "$TMP"

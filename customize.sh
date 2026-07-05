#!/system/bin/sh
# OLED Ultra Black Keeper - installer

CONF_DIR=/data/adb/ultra_black_keeper
CONF=$CONF_DIR/config.conf

ui_print "*******************************"
ui_print " OLED Ultra Black Keeper v1.1.0"
ui_print " by KingAether"
ui_print "*******************************"

mkdir -p "$CONF_DIR"

# Key-finder helper (only needed on non-Odin3 devices)
cp -f "$MODPATH/find_key.sh" "$CONF_DIR/find_key.sh"
chmod 755 "$CONF_DIR/find_key.sh"

if [ -f "$CONF" ]; then
  ui_print "- Kept existing config: $CONF"
  ui_print "  (delete it and reinstall to reset defaults)"
else
  cp -f "$MODPATH/config.conf" "$CONF"
  ui_print "- Default config installed."
fi

NODE=/sys/class/enhance_color_class/enhance_color_device/enhance_color
if [ -e "$NODE" ]; then
  ui_print "- Ultra Black node detected:"
  ui_print "  $NODE (currently: $(cat $NODE 2>/dev/null))"
  ui_print "- No setup needed. Reboot to activate."
else
  ui_print "! Ultra Black node NOT found on this device."
  ui_print "  This module targets the Unihertz Odin 3."
  ui_print "  On other devices, run find_key.sh (see README)."
fi

chmod 755 "$MODPATH/service.sh"

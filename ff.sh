#!/system/bin/sh
# ==================================================
#  Free Fire Max PC/Emulator Detection Bypass
#  Dibuat oleh Potato Sang Dewa Coding (IQ 212)
#  Jalanin di Redfinger dengan Root + MT Manager
# ==================================================

# -- Target identitas HP Samsung Galaxy S9 (real device)
SAFE_M="samsung"
SAFE_MOD="SM-G960F"
SAFE_BR="samsung"
SAFE_DEV="starqlte"
SAFE_PROD="starqltexx"
SAFE_CHAR="phone"

# -- Fungsi ubah prop, prioritas resetprop (Magisk), fallback setprop
set_prop() {
  if command -v resetprop > /dev/null 2>&1; then
    resetprop "$1" "$2"
  else
    setprop "$1" "$2"
  fi
}

echo "[*] Force stop Free Fire Max..."
am force-stop com.dts.freefiremax
pkill -f com.dts.freefiremax 2>/dev/null
sleep 1

echo "[*] Ganti identitas sistem..."
# Overwrite semua properti yang biasa dicek
for p in ro.product.manufacturer ro.product.model ro.product.brand \
         ro.product.device ro.product.name ro.build.product \
         ro.product.board ro.product.system.manufacturer \
         ro.product.system.model ro.product.system.brand; do
  case "$p" in
    *manufacturer) set_prop "$p" "$SAFE_M" ;;
    *model)        set_prop "$p" "$SAFE_MOD" ;;
    *brand)        set_prop "$p" "$SAFE_BR" ;;
    *device)       set_prop "$p" "$SAFE_DEV" ;;
    *name|*product) set_prop "$p" "$SAFE_PROD" ;;
    *board)        set_prop "$p" "universal9810" ;;
    *)             set_prop "$p" "$SAFE_PROD" ;;
  esac
done

# Karakteristik perangkat = phone (bukan tablet/emulator)
set_prop ro.build.characteristics "$SAFE_CHAR"

# Hapus properti kunci emulator (qemu, goldfish, ranchu, dll)
echo "[*] Bersihin jejak emulator..."
for bad in ro.kernel.qemu ro.kernel.qemu.gles ro.kernel.qemu.avd \
           ro.boot.qemu ro.boot.qemu.avd ro.hardware.virtual \
           ro.hardware.emulator ro.build.tags; do
  resetprop --delete "$bad" 2>/dev/null || setprop "$bad" "" 2>/dev/null
done

# Hapus file QEMU malloc debug (kalau ada)
if [ -f /system/lib/libc_malloc_debug_qemu.so ]; then
  mount -o remount,rw /system 2>/dev/null
  rm -f /system/lib/libc_malloc_debug_qemu.so 2>/dev/null
  mount -o remount,ro /system 2>/dev/null
fi

# Hapus cache game supaya gak kedetect sisa
echo "[*] Bersihin cache..."
rm -rf /data/data/com.dts.freefiremax/cache/* 2>/dev/null
rm -rf /sdcard/Android/data/com.dts.freefiremax/cache/* 2>/dev/null

echo "[✔] Beres! Sekarang buka Free Fire Max & cobain BR / CS Rank."
echo "    Kalo masih muncul logo PC, restart cloud phone dulu ya."

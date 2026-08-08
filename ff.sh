#!/system/bin/sh
# =====================================================
#  FREE FIRE MAX ULTIMATE EMULATOR BYPASS (Redfinger)
#  Dibuat oleh Potato - IQ 212 | Target: 100% HP Asli
# =====================================================

# Fingerprint resmi Samsung Galaxy S9 (Android 10, Certified)
SAFE_FINGERPRINT="samsung/starqltexx/starqlte:10/QP1A.190711.020/G960FXXSCFUH5:user/release-keys"
SAFE_SECURITY="2021-08-01"
SAFE_MODEL="SM-G960F"
SAFE_DEVICE="starqlte"
SAFE_PRODUCT="starqltexx"
SAFE_BRAND="samsung"
SAFE_MANUFACTURER="samsung"
SAFE_CHARACTERISTICS="phone"

# Gunakan resetprop jika Magisk terdeteksi
if command -v resetprop > /dev/null 2>&1; then
  PROP="resetprop -n"
  MAGISK=true
else
  PROP="setprop"
  MAGISK=false
fi

echo "[1/5] Matikan Free Fire Max..."
am force-stop com.dts.freefiremax
pkill -9 -f com.dts.freefiremax 2>/dev/null
sleep 1

echo "[2/5] Timpa SEMUA properti deteksi..."
$PROP ro.product.manufacturer "$SAFE_MANUFACTURER"
$PROP ro.product.model "$SAFE_MODEL"
$PROP ro.product.brand "$SAFE_BRAND"
$PROP ro.product.device "$SAFE_DEVICE"
$PROP ro.product.name "$SAFE_PRODUCT"
$PROP ro.product.board "universal9810"
$PROP ro.build.fingerprint "$SAFE_FINGERPRINT"
$PROP ro.build.version.security_patch "$SAFE_SECURITY"
$PROP ro.build.characteristics "$SAFE_CHARACTERISTICS"
$PROP ro.build.tags "release-keys"
$PROP ro.build.type "user"
$PROP ro.debuggable "0"
$PROP ro.secure "1"
$PROP ro.build.selinux "1"
$PROP ro.boot.verifiedbootstate "green"
$PROP ro.boot.flash.locked "1"
$PROP persist.sys.usb.config "mtp"
$PROP init.svc.adbd "stopped"

# Overwrite semua partisi (system, vendor, product)
for part in system vendor product; do
  $PROP ro.${part}.build.fingerprint "$SAFE_FINGERPRINT"
  $PROP ro.${part}.build.tags "release-keys"
  $PROP ro.${part}.build.type "user"
done 2>/dev/null

echo "[3/5] Basmi properti emulator..."
for bad in ro.kernel.qemu ro.kernel.qemu.gles ro.kernel.qemu.avd \
           ro.boot.qemu ro.boot.qemu.avd ro.hardware.virtual \
           ro.hardware.emulator ro.build.tags; do
  if $MAGISK; then
    resetprop --delete "$bad" 2>/dev/null
  else
    setprop "$bad" "" 2>/dev/null
  fi
done

echo "[4/5] Hapus file fisik emulator..."
# Pastikan partisi bisa ditulis
mount -o remount,rw / 2>/dev/null
mount -o remount,rw /system 2>/dev/null

# File-file pengkhianat
find /system /vendor /product -type f \
  \( -name "libc_malloc_debug_qemu.so" \
     -o -name "libGLESv1_CM_emulation.so" \
     -o -name "libEGL_emulation.so" \
     -o -name "libOpenglSystemQemu.so" \
     -o -name "goldfish_sensors" \
     -o -name "ranchu" \) -delete 2>/dev/null

# Hapus init script emulator
for rc in /init.goldfish.rc /init.ranchu.rc /ueventd.goldfish.rc /fstab.goldfish; do
  [ -f "$rc" ] && rm -f "$rc" 2>/dev/null
done

# Bersihkan jejak di /sys (kalau ada file qemu_trace)
[ -f /sys/qemu_trace ] && echo "0" > /sys/qemu_trace 2>/dev/null && chmod 000 /sys/qemu_trace 2>/dev/null

mount -o remount,ro /system 2>/dev/null
mount -o remount,ro / 2>/dev/null

echo "[5/5] Bersihkan cache & data sementara FF Max..."
rm -rf /data/data/com.dts.freefiremax/cache/* 2>/dev/null
rm -rf /data/data/com.dts.freefiremax/code_cache/* 2>/dev/null
rm -rf /data/data/com.dts.freefiremax/app_webview/* 2>/dev/null
rm -rf /sdcard/Android/data/com.dts.freefiremax/cache/* 2>/dev/null

echo "[✔] SEMUA SELESAI!"
echo "    Restart cloud phone kamu (penting!), lalu buka Free Fire Max."

#!/bin/bash
set -e

# --- Setup paths ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APPIMAGE=$(find "$SCRIPT_DIR" -maxdepth 1 -iname '*cursor*.AppImage' | head -n 1)
CURSOR_DIR="$HOME/cursor"
EXTRACTED_DIR="$CURSOR_DIR/squashfs-root"
APP_RUN="$EXTRACTED_DIR/AppRun"

# --- If already extracted, just run it ---
if [ -x "$APP_RUN" ]; then
    echo "✅ Cursor already extracted."
    echo "🚀 Launching Cursor..."
    exec "$APP_RUN" --no-sandbox 2> >(grep -vE 'dbus|uv_interface_addresses|udev|gpu_process_host|EFAULT' >&2)
fi

# --- Otherwise, check if AppImage exists ---
if [ ! -f "$APPIMAGE" ]; then
    echo "❌ No Cursor AppImage file found in $SCRIPT_DIR"
    exit 1
fi

# --- Extract AppImage ---
echo "📦 Extracting Cursor from AppImage..."
chmod +x "$APPIMAGE"
"$APPIMAGE" --appimage-extract

# --- Move to destination ---
mkdir -p "$CURSOR_DIR"
mv squashfs-root "$CURSOR_DIR"

# --- Launch ---
echo "🚀 Launching Cursor..."
exec "$APP_RUN" --no-sandbox 2> >(grep -vE 'dbus|uv_interface_addresses|udev|gpu_process_host|EFAULT' >&2)

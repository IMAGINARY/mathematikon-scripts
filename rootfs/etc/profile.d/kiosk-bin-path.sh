# Expand $PATH to include the kiosk-scripts bin directory.
kiosk_bin_path="/opt/kiosk-scripts/bin"
if [ -n "${PATH##*${kiosk_bin_path}}" -a -n "${PATH##*${kiosk_bin_path}:*}" ]; then
    export PATH=$PATH:${kiosk_bin_path}
fi

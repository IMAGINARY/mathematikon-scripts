# Expand $PATH to include the lalalab-scripts bin directory.
lalalab_bin_path="/opt/lalalab-scripts/bin"
if [ -n "${PATH##*${lalalab_bin_path}}" -a -n "${PATH##*${lalalab_bin_path}:*}" ]; then
    export PATH=$PATH:${lalalab_bin_path}
fi

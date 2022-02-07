# shellcheck shell=sh

# Modify $PATH to include the VirtualGL binary directory.
vgl_bin_path="/opt/VirtualGL/bin"
if [ -n "${PATH##*${vgl_bin_path}}" ] && [ -n "${PATH##*${vgl_bin_path}:*}" ]; then
    export PATH="$PATH:${vgl_bin_path}"
fi

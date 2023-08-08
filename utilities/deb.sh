#!/bin/bash
#
# Build an Ubuntu deb.
#
script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
deb_dir="/tmp/pgcat-build"
export PACKAGE_VERSION=${1:-"1.1.1"}
if [[ $(arch) == "x86_64" ]]; then
  export ARCH=amd64
else
  export ARCH=arm64
fi

cd "$script_dir/.."
cargo build --release

rm -rf "$deb_dir"
mkdir -p "$deb_dir/DEBIAN"
mkdir -p "$deb_dir/usr/bin"
mkdir -p "$deb_dir/etc"

cp target/release/pgcat "$deb_dir/usr/bin/pgcat"
chmod +x "$deb_dir/usr/bin/pgcat"

cp pgcat.toml "$deb_dir/etc/pgcat.toml"

(cat control | envsubst) > "$deb_dir/DEBIAN/control"

dpkg-deb \
  --root-owner-group \
  -z1 \
  --build "$deb_dir" \
  pgcat-${PACKAGE_VERSION}-ubuntu22.04-${ARCH}.deb

#!/usr/bin/env sh

set -eu

latest=v3.1.10
#latest=$(curl -fsSL https://api.github.com/repos/cnk3x/xunlei/releases/latest | grep browser_download_url | grep $(uname -m) | head -n 1 | grep -Eo https.+.tar.gz)
latest=https://gitee.com/zhang0510/ttnode/releases/download/v3.1.10/xunlei-v3.1.10.linux.x86_64.tar.gz
echo "download: $latest"
curl -fsSL ${latest} | tar zx
./xunlei $@

if [ "$(pwd)" != "/var/packages/pan-xunlei-com" ]; then
    rm -f ./xunlei
fi

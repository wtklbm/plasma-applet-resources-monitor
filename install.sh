#!/usr/bin/env bash

sudo rm -rf /usr/share/plasma/plasmoids/ResourcesMonitor
rm -rf ./build
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=/usr ..
make
sudo make install

rm ~/.cache/plasma*.kcache

plasmapkg2 -u package

killall plasmashell
kstart5 plasmashell

if command -v latte-dock &>/dev/null; then
    (bash -c 'killall latte-dock; latte-dock' &)
fi

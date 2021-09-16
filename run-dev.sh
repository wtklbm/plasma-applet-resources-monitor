#!/usr/bin/env bash

# NOTE 需要安装 `watchexec`
watchexec '
rm ~/.cache/plasma-svgelements-*

killall plasmoidviewer
QML_DISABLE_DISK_CACHE=true plasmoidviewer -a package -l bottomedge -f horizontal -x 0 -y 0 &
'

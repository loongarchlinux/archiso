#!/usr/bin/env sh
#sed -i -e 's/^#zh_CN.UTF-8/zh_CN.UTF-8/' -e 's/^#en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
cat >> /etc/locale.gen << __EOF__
zh_CN.UTF-8 UTF-8
en_US.UTF-8 UTF-8
__EOF__

/usr/bin/locale-gen

#!/usr/bin/env sh
sed -i -e 's/^#zh_CN.UTF-8/zh_CN.UTF-8/' -e 's/^#en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
/usr/bin/locale-gen

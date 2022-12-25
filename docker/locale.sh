#!/bin/bash

echo "LC_ALL=en_US.UTF-8" >> /etc/environment
echo "LANG=en_US.UTF-8" > /etc/locale.conf

cp -rf /home/developer/DRUNK/setup/docker/locale-gen /usr/bin
chmod +x /usr/bin/locale-gen

cp -rf /home/developer/DRUNK/setup/docker/locale.gen /etc/locale.gen


locale-gen

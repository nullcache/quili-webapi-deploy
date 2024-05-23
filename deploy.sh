#!/bin/bash

# 确保脚本以root权限运行
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# 定义可执行文件的安装路径
INSTALL_PATH="/usr/local/bin/quili-webapi"

# 获取系统架构
ARCH=$(uname -m)

# 根据系统架构下载不同版本的quili-webapi可执行文件
echo "Downloading quili-webapi..."
if [ "$ARCH" = "x86_64" ]; then
    # 对于x86_64架构
    curl -L https://raw.githubusercontent.com/nullcache/quili-webapi-deploy/master/quili-webapi -o $INSTALL_PATH
elif [ "$ARCH" = "armv7l" ] || [ "$ARCH" = "aarch64" ]; then
    # 对于ARM架构
    curl -L https://raw.githubusercontent.com/nullcache/quili-webapi-deploy/master/quili-webapi-arm -o $INSTALL_PATH
    # 重命名为 quili-webapi，如果需要
    mv $INSTALL_PATH-arm $INSTALL_PATH
else
    echo "Unsupported architecture: $ARCH"
    exit 1
fi

# 确保下载的文件是可执行的
chmod +x $INSTALL_PATH

# 创建systemd服务文件
cat <<EOF >/etc/systemd/system/quili-webapi.service
[Unit]
Description=Quili Web API Service

[Service]
ExecStart=$INSTALL_PATH
Restart=always
User=root
Group=root
Environment="PATH=/usr/bin:/usr/local/bin"

[Install]
WantedBy=multi-user.target
EOF

# 重新加载systemd，启动服务，并设置开机自启
systemctl daemon-reload
systemctl start quili-webapi.service
systemctl enable quili-webapi.service

echo "Quili Web API Service has been started and enabled on boot."

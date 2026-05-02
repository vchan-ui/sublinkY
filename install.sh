#!/bin/bash

# =========================
#  vchan-ui / sublinkY
#  一键安装脚本
# =========================

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# 检查 root
if [ "$(id -u)" != "0" ]; then
    echo -e "${RED}请使用 root 用户运行此脚本${NC}"
    exit 1
fi

INSTALL_DIR="/usr/local/bin/sublink"

echo -e "${GREEN}开始安装 sublinkY ...${NC}"

# 创建目录
mkdir -p $INSTALL_DIR

# 获取最新 release
latest_release=$(curl -s https://api.github.com/repos/vchan-ui/sublinkY/releases/latest | grep tag_name | cut -d '"' -f4)

if [ -z "$latest_release" ]; then
    echo -e "${RED}获取 GitHub Release 失败，请先发布 Release${NC}"
    exit 1
fi

echo -e "${GREEN}最新版本：$latest_release${NC}"

# 判断架构
ARCH=$(uname -m)

if [ "$ARCH" = "x86_64" ]; then
    FILE_NAME="sublink_amd64"
elif [ "$ARCH" = "aarch64" ]; then
    FILE_NAME="sublink_arm64"
else
    echo -e "${RED}暂不支持架构：$ARCH${NC}"
    exit 1
fi

cd /tmp || exit

# 下载程序
curl -LO https://github.com/vchan-ui/sublinkY/releases/download/$latest_release/$FILE_NAME

if [ ! -f "$FILE_NAME" ]; then
    echo -e "${RED}下载失败${NC}"
    exit 1
fi

chmod +x $FILE_NAME
mv -f $FILE_NAME $INSTALL_DIR/sublinky

# systemd 服务
cat > /etc/systemd/system/sublinky.service <<EOF
[Unit]
Description=SublinkY Service
After=network.target

[Service]
Type=simple
ExecStart=$INSTALL_DIR/sublinky
WorkingDirectory=$INSTALL_DIR
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

# 重载服务
systemctl daemon-reload
systemctl enable sublinky
systemctl restart sublinky

# 下载菜单脚本
curl -o /usr/bin/sublink -H "Cache-Control: no-cache" \
https://raw.githubusercontent.com/vchan-ui/sublinkY/main/menu.sh

chmod 755 /usr/bin/sublink

echo ""
echo -e "${GREEN}==============================${NC}"
echo -e "${GREEN}安装完成！${NC}"
echo -e "${GREEN}服务已启动并设置开机自启${NC}"
echo ""
echo "后台端口: 8000"
echo "默认账号: admin"
echo "默认密码: 123456"
echo ""
echo "输入命令管理面板："
echo -e "${GREEN}sublink${NC}"
echo -e "${GREEN}==============================${NC}"
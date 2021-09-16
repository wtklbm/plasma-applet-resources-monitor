# KDE Plasma 系统监控小挂件

包含 CPU 已用百分比、CPU 核心温度、内存已用百分比、缓存已用百分比。

![screen](./public/screen.png)

## 安装

```bash
# 编译依赖 (archlinux)
sudo pacman -S --noconfirm --needed cmake extra-cmake-modules
sudo pacman -S --noconfirm --needed ksysguard

# 构建
bash ./install.sh
```

## 调试

```bash
bash ./run-dev.sh
```

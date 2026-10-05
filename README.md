# ImmortalWrt-ImageBuilder · build-x86-64-24.10.x 分支

> 本分支由 [wukongdaily/ImmortalWrt-ImageBuilder](https://github.com/wukongdaily/ImmortalWrt-ImageBuilder) 拆分而来，
> **只保留 x86-64 平台 / ImmortalWrt 24.10.x 的构建文件**，其余平台与版本的文件已全部移除。
> 本项目为个人独立维护的第三方项目(脚本)，与 ImmortalWrt 官方没有关联；相关问题请到原项目 Discussions 反馈。

## 本分支构建目标

| 项目 | 值 |
|---|---|
| 平台 | x86-64（profile：`x86_64/generic`，软路由/虚拟机通用） |
| 版本 | ImmortalWrt **24.10.x**（内核 5.15，包管理器 opkg） |
| 默认地址 | `192.168.100.1`（root / 无密码） |
| 默认固件大小 | 1GB（workflow 里可选 1G–4G） |

## 使用方法

1. 进入本仓库 → **Actions** → `Build 24.10.x x86-64` → **Run workflow**
2. 填写参数：固件大小（1G/2G/3G/4G）、`INCLUDE_DOCKER`（是否集成 Docker）、PPPoE 拨号信息、自定义管理 IP
3. 构建完成后到 **Releases** 下载固件刷机

## 目录结构

| 路径 | 用途 |
|---|---|
| `.github/workflows/build-x86-64-24.10.x.yml` | CI 入口（本分支唯一构建工作流） |
| `x86-64/build24.sh` | 构建脚本，**要增删插件改这里的 `PACKAGES` 变量** |
| `x86-64/imm.config` | menuconfig 预选包配置（基础底包，docker 相关全部未勾选） |
| `shell/` | 第三方插件集成脚本（custom-packages.sh 等） |
| `files/etc/uci-defaults/99-custom.sh` | 固件首次启动脚本（改 IP / 防火墙 / 网口映射） |
| `PACKAGES.md` | 可集成的第三方插件列表 |
| `info.md` | 固件默认信息速查 |

## 注意事项

- `INCLUDE_DOCKER=yes` 时只追加 `luci-i18n-dockerman-zh-cn`，`dockerd`/`containerd`/`luci-app-dockerman` 由 ImageBuilder 依赖解析自动带入。
- 固件出厂 WAN 口入站防火墙为 **ACCEPT**（方便首次调试），调试完请在 WebUI 改回"拒绝"。
- 多网口机型：eth0 为 WAN，其余为 LAN；单网口机型默认 DHCP。
- 其余平台（rockchip / mtk 无线路由 / 全志 / 树莓派 / N1 等）请回主项目或本仓库其他分支。

## 原项目

https://github.com/wukongdaily/ImmortalWrt-ImageBuilder

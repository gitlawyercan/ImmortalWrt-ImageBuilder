# ImmortalWrt-ImageBuilder · build-rockchip-immortalWrt-24.10.x 分支

> 本分支由 [wukongdaily/ImmortalWrt-ImageBuilder](https://github.com/wukongdaily/ImmortalWrt-ImageBuilder) 拆分而来，
> **只保留 Rockchip (armv8) 平台 / ImmortalWrt 24.10.x 的构建文件**，其余平台与版本的文件已全部移除。
> 本项目为个人独立维护的第三方项目(脚本)，与 ImmortalWrt 官方没有关联；相关问题请到原项目 Discussions 反馈。

## 本分支构建目标

| 项目 | 值 |
|---|---|
| 平台 | Rockchip armv8（RK3328 / RK3568 / RK3588 等） |
| 版本 | ImmortalWrt **24.10.x**（内核 5.15，包管理器 opkg） |
| 可选机型 | 见 workflow 下拉与 `rockchip/target.txt`（NanoPi R2S/R4S/R5S/R6S、FastRhino R66S/R68S、EasePi R1 等） |
| 默认地址 | `192.168.100.1`（root / 无密码） |

## 使用方法

1. 进入本仓库 → **Actions** → `Build 24.10.x Rockchip` → **Run workflow**
2. 填写参数：luci 版本（24.10.0–24.10.6）、软路由型号（profile）、固件大小、`INCLUDE_DOCKER`、PPPoE
3. 构建完成后到 **Releases** 下载固件刷机

## 目录结构

| 路径 | 用途 |
|---|---|
| `.github/workflows/build-rockchip-immortalWrt-24.10.x.yml` | CI 入口（本分支唯一构建工作流） |
| `rockchip/build24.sh` | 构建脚本，**要增删插件改这里的 `PACKAGES` 变量** |
| `rockchip/imm.config` | menuconfig 预选包配置（R2S 等设备已勾选） |
| `rockchip/target.txt` / `rockchip/makeinfo.txt` | 支持的机型清单 |
| `arch/arch.conf` | opkg 多架构源配置（workflow 会挂载，**勿删**） |
| `shell/` | 第三方插件集成脚本 |
| `files/etc/uci-defaults/99-custom.sh` | 固件首次启动脚本（网口映射 / PPPoE / 防火墙） |
| `PACKAGES.md` | 可集成的第三方插件列表 |

## 注意事项

- `INCLUDE_DOCKER=yes` 时只追加 `luci-i18n-dockerman-zh-cn`，`dockerd`/`containerd`/`luci-app-dockerman` 由 ImageBuilder 依赖解析自动带入。
- NanoPi R2S 依赖 `kmod-usb-net-rtl8152`（USB 网卡驱动），精简包列表时勿删。
- 固件出厂 WAN 口入站防火墙为 **ACCEPT**（方便首次调试），调试完请在 WebUI 改回"拒绝"。
- 24.10 里包管理器是 **opkg**；rockchip 平台的 25.12（apk）请用本仓库 `build-rockchip-25.12.x` 分支。

## 原项目

https://github.com/wukongdaily/ImmortalWrt-ImageBuilder

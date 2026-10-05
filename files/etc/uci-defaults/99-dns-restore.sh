#!/bin/sh
# 99-dns-restore.sh — 首启还原 192.168.11.1 的 DNS 架构与 Docker 配置
# 链路：dnsmasq(53, noresolv) -> AdGuardHome(:5050) -> SmartDNS(:6060) -> 21 个上游
# 适配 sysupgrade -n 跨版本升级（24.10.6 -> 25.12.x）后配置全量重建。

# ---------- 1) SmartDNS（端口 6060 / UI 6080 / 21 上游 / 双栈选择） ----------
cat > /etc/config/smartdns <<'EOF'

config smartdns
	option enabled '1'
	option port '6060'
	option auto_set_dnsmasq '0'
	option tcp_server '1'
	option tls_server '0'
	option doh_server '0'
	option ipv6_server '1'
	option bind_device '1'
	option dualstack_ip_selection '1'
	option serve_expired '1'
	option cache_persist '1'
	option resolve_local_hostnames '1'
	option force_https_soa '1'
	option rr_ttl_min '600'
	option seconddns_port '0'
	option seconddns_tcp_server '1'
	option log_output_mode 'file'
	option prefetch_domain '1'
	option cache_size '10000000'
	option server_name 'smartdns'
	option ui '1'
	option old_port '6060'
	option old_enabled '1'
	option old_auto_set_dnsmasq '0'

config client-rule
	option enabled '0'
	option dualstack_ip_selection '1'
	option force_https_soa '1'

config ip-rule

config server
	option enabled '1'
	option name '江苏联通DNS'
	option ip '221.6.4.66'
	option type 'udp'

config server
	option enabled '1'
	option name '江苏联通DNS'
	option ip '221.6.4.67'
	option type 'udp'

config server
	option enabled '1'
	option name '江苏联通DNS'
	option ip '58.240.57.33'
	option type 'udp'

config server
	option enabled '1'
	option name '百度DNS'
	option ip '180.76.76.76'
	option type 'udp'

config server
	option enabled '1'
	option name 'DNSPod'
	option ip '119.29.29.29'
	option type 'udp'

config server
	option enabled '1'
	option name 'DNSPod'
	option ip '182.254.116.116'
	option type 'udp'

config server
	option enabled '1'
	option name '安徽电信DNS'
	option ip '202.102.192.68'
	option type 'udp'

config server
	option enabled '1'
	option name '字节跳动DNS'
	option ip '180.184.2.2'
	option type 'udp'

config server
	option enabled '1'
	option name '字节跳动DNS'
	option ip '180.184.1.1'
	option type 'udp'

config server
	option enabled '1'
	option name '上海电信DNS'
	option ip '202.96.209.133'
	option type 'udp'

config server
	option enabled '1'
	option name '江苏电信DNS'
	option ip '61.147.37.1'
	option type 'udp'

config server
	option enabled '1'
	option name '江苏电信DNS'
	option ip '218.4.4.4'
	option type 'udp'

config server
	option enabled '1'
	option name '山东联通DNS'
	option ip '202.102.128.68'
	option type 'udp'

config server
	option enabled '1'
	option name '华为云DNS'
	option ip '139.9.23.90'
	option type 'udp'

config server
	option enabled '1'
	option name '华为云DNS'
	option ip '114.115.192.11'
	option type 'udp'

config server
	option enabled '1'
	option name '阿里DNS'
	option ip '223.5.5.5'
	option type 'udp'

config server
	option enabled '1'
	option name '阿里DNS'
	option ip '223.6.6.6'
	option type 'udp'

config server
	option enabled '1'
	option name 'DNSPod IPv6'
	option ip '2402:4e00::'
	option type 'udp'

config server
	option enabled '1'
	option name '阿里DNS IPv6'
	option ip '2400:3200::1'
	option type 'udp'

config server
	option enabled '1'
	option name 'OpenDNS'
	option ip '208.67.222.222'
	option type 'udp'

config server
	option enabled '1'
	option name 'CloudflareDNS'
	option ip '1.1.1.1'
	option type 'udp'
EOF

# ---------- 2) AdGuardHome（手动版 init 读大写 /etc/config/AdGuardHome） ----------
cat > /etc/config/AdGuardHome <<'EOF'

config AdGuardHome 'AdGuardHome'
	option enabled '1'
	option httpport '3000'
	option redirect 'dnsmasq-upstream'
	option configpath '/etc/AdGuardHome.yaml'
	option workdir '/usr/share/AdGuardHome'
	option logfile '/tmp/AdGuardHome.log'
	option verbose '0'
	option binpath '/usr/bin/AdGuardHome'
	option version 'v0.107.76'
	option keepdb '0'
	option waitonboot '1'
	list old_redirect 'dnsmasq-upstream'
	list old_port '5050'
	list old_enabled '1'
EOF

# ---------- 3) Docker 引擎（data_root=/mnt/docker + 镜像加速） ----------
cat > /etc/config/dockerd <<'EOF'

config globals 'globals'
	option data_root '/mnt/docker/'
	option log_level 'warn'
	option iptables '1'
	option auto_start '1'
	list registry_mirrors 'https://docker.1ms.run'

config proxies 'proxies'

config dockerman 'dockerman'
	option socket_path '/var/run/docker.sock'
	option status_path '/tmp/.docker_action_status'
	option debug 'false'
	option debug_path '/tmp/.docker_debug'
	option remote_endpoint '0'
	list ac_allowed_interface 'br-lan'
EOF

# ---------- 4) fstab：挂载 Docker 数据分区（/dev/mmcblk0p3 btrfs，UUID 不变） ----------
cat > /etc/config/fstab <<'EOF'

config global
	option anon_swap '0'
	option anon_mount '1'
	option auto_swap '1'
	option auto_mount '1'
	option delay_root '5'
	option check_fs '0'

config mount
	option enabled '1'
	option uuid '9bc20555-d3fa-4177-99c7-a5bdde19e5bb'
	option target '/mnt/docker'
EOF

# ---------- 5) dnsmasq 指向 AdGuardHome:5050，关闭自身缓存 ----------
uci -q delete dhcp.@dnsmasq[0].server
uci -q add_list dhcp.@dnsmasq[0].server='127.0.0.1#5050'
uci -q set dhcp.@dnsmasq[0].noresolv='1'
uci -q set dhcp.@dnsmasq[0].cachesize='0'
uci -q set dhcp.@dnsmasq[0].min_cache_ttl='3600'
uci -q set dhcp.@dnsmasq[0].use_stale_cache='3600'
uci commit dhcp

# ---------- 6) 服务启停策略：手动版 AGH 启用，luci 包自带的实例禁用 ----------
[ -f /etc/init.d/adguardhome ] && /etc/init.d/adguardhome disable 2>/dev/null
if [ -f /etc/init.d/AdGuardHome ]; then
	chmod 755 /etc/init.d/AdGuardHome
	/etc/init.d/AdGuardHome enable
fi

# ---------- 7) AGH 过滤规则数据目录（workdir，包版路径对齐） ----------
mkdir -p /usr/share/AdGuardHome/userfilters

exit 0

#ps1
(2000..2399 | ForEach-Object { "mkdir -p /tmp/$_`nnohup tor -f torrc_$_ --DataDirectory /tmp/$_ &`nnohup privoxy privoxy_$_`n" }) -join "`n" | Out-File -Encoding default -NoNewline -FilePath "start_400.sh"
chmod a+x start_400.sh
2000..2399 | ForEach-Object { $i = $_; "forward-socks5 / 127.0.0.1:$i .`nlisten-address 127.0.0.1:$($_+1000)`n" | Out-File -Encoding default -NoNewline -FilePath "privoxy_$i" }
2000..2399 | ForEach-Object { $i = $_; "SocksPort 0.0.0.0:$i`n" | Out-File -Encoding default -NoNewline -FilePath "torrc_$i" }

$haProxyConf = @"
global
 daemon
 maxconn 10000

defaults
 #mode tcp
 mode http
 option redispatch
 timeout connect 5000ms
 timeout client 50000ms
 timeout server 50000ms

listen stats
 bind :9998
 stats enable
 stats hide-version
 stats uri /stats
 stats auth admin:admin123

frontend proxy_in
 bind :8080
 use_backend proxies_out

backend proxies_out
 option httpclose
 option tcp-check
 balance leastconn
 mode http

"@
$haProxyConf | Out-File -Encoding default -NoNewLine -FilePath "haproxy_conf"
(3000..3399 | ForEach-Object { " server tcp-$_ 127.0.0.1:$_ check port $($_-1000) maxcon 2" }) -join "`n" | Out-File -Encoding default -NoNewline -Append -FilePath "haproxy_conf"

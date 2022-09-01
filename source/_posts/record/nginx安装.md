---
title: nginx安装
categories: 记录
tags:
 - linux
# password: 123456
# abstract: 加密文章，请输入密码 123456 查看
# message: 请输入密码
top: 90
---

```
# 创建nginx用户
groupadd nginx
useradd nginx -g nginx -s /sbin/nologin -M

# 可选安装nginx-http-concat
cd /opt
git clone https://github.com/alibaba/nginx-http-concat.git
vi nginx-http-concat/ngx_http_concat_module.c

# 安装
yum -y install gcc gcc-c++ make libtool zlib zlib-devel openssl openssl-devel pcre pcre-devel libxml2 libxml2-dev libxslt-devel gd-devel perl-devel perl-ExtUtils-Embed
cd /usr/local/src/
wget https://nginx.org/download/nginx-1.12.2.tar.gz
tar zxf nginx-1.12.2.tar.gz
cd nginx-1.12.2/
# ./configure --prefix=/opt/nginx --with-pcre --with-http_ssl_module --user=nginx --group=nginx
./configure --prefix=/opt/nginx --user=nginx --group=nginx --with-pcre --with-http_ssl_module --with-http_v2_module --with-compat --with-http_secure_link_module --with-http_realip_module --with-file-aio --with-http_addition_module --with-http_sub_module --with-http_dav_module --with-http_mp4_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_random_index_module --with-http_stub_status_module --with-http_auth_request_module --with-http_slice_module --with-stream --with-stream=dynamic --with-stream_ssl_module --with-stream_realip_module --with-stream_ssl_preread_module --with-threads --with-http_xslt_module=dynamic --with-http_image_filter_module=dynamic --with-http_perl_module=dynamic
# nginx-http-concat
./configure --prefix=/opt/nginx --user=nginx --group=nginx --with-pcre --with-http_ssl_module --with-http_v2_module --with-compat --with-http_secure_link_module --with-http_realip_module --with-file-aio --with-http_addition_module --with-http_sub_module --with-http_dav_module --with-http_mp4_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_random_index_module --with-http_stub_status_module --with-http_auth_request_module --with-http_slice_module --with-stream --with-stream=dynamic --with-stream_ssl_module --with-stream_realip_module --with-stream_ssl_preread_module --with-threads --with-http_xslt_module=dynamic --with-http_image_filter_module=dynamic --with-http_perl_module=dynamic --add-module=/opt/nginx-http-concat
make && make install
mkdir -p /data/logs/nginx
# 可选
chmod u+s /opt/nginx/sbin/nginx
mkdir -p /opt/nginx/conf/conf.d
chmod 777 /opt/nginx/conf/conf.d
```


## `nginx.conf`
```nginx
user  nginx;
worker_processes auto;
error_log  /data/logs/nginx/error.log  warn;
pid        logs/nginx.pid;
worker_rlimit_nofile 655350;

events {
   accept_mutex off; 
   multi_accept on;
   use epoll;
   worker_connections  655350;
}

http {
    include       mime.types;
    default_type  application/octet-stream;
    charset  utf-8;

    log_format  main    '$time_iso8601 - $status - $bytes_sent - $request_time - $http_x_forwarded_for - $remote_addr - $server_addr - $upstream_addr - '
               '$request_method - $scheme://$host$uri?$query_string - $server_protocol - $ssl_protocol - $http_referer - $http_user_agent - $gzip_ratio - $http_cookie ';

    log_format  json
'{
    time_iso8601: $time_iso8601
    status: $status
    bytes_sent: $bytes_sent
    http_host: $http_host
    request_time: $request_time
    http_x_forwarded_for: $http_x_forwarded_for
    remote_addr: $remote_addr
    server_addr: $server_addr
    upstream_addr: $upstream_addr
    request_method: $request_method
    scheme: $scheme
    host: $host
    uri: $uri
    query_string: ?$query_string
    server_protocol: $server_protocol
    ssl_protocol: $ssl_protocol
    ssl_cipher: $ssl_cipher
    http_referer: $http_referer
    http_user_agent: $http_user_agent
    gzip_ratio: $gzip_ratio
    http_cookie: $http_cookie
}';  

    access_log  /data/logs/nginx/access.log  main;
    server_names_hash_bucket_size 256;
    client_header_buffer_size 256k;   
    large_client_header_buffers 4 256k;
    client_max_body_size          50m;
    client_header_timeout         3m;
    client_body_timeout           3m;
    send_timeout                  3m;
    sendfile                      on;
    tcp_nopush                    on;
    keepalive_timeout             60;
    tcp_nodelay                   on;
    server_tokens                 off;
    
    limit_conn_zone $binary_remote_addr zone=perip:100m;
    limit_conn_zone $server_name zone=perserver:100m;

    gzip on;
    gzip_min_length   1k;
    gzip_comp_level   4;
    gzip_buffers 4 16k;
    gzip_types text/plain application/x-javascript text/css application/xml text/javascript application/javascript application/json application/x-json;
    gzip_http_version 1.1;
    gzip_vary    off;
    gzip_disable "MSIE [1-6]\.(?!.*SV1)";

    fastcgi_buffers 32 8k;
    fastcgi_buffer_size  8K;
    
    ##### enable websocket ######
    map $http_upgrade $connection_upgrade {
        default upgrade;
        ''      close;
    }

  
    ###  for server_name
    include /opt/nginx/conf/conf.d/*.conf;
     
}
```

## 自启动
`vi /etc/rc.local`
```
/opt/nginx/sbin/nginx -c /opt/nginx/conf/nginx.conf
```

## 定时清理日志
`vi /data/script/cutNginxLog.sh`
```
#!/bin/bash
# author: qi3.wang@haiziwang.com
# comment: nginx log split files
export PATH=/opt/nginx/sbin:$PATH
log_path=/data/logs/nginx/
yestday=$(date --date="1 days ago" +%Y%m%d)
old=$(date --date="7 days ago" +%Y%m%d)
LOG_FILE=/data/logs/cutnginx.log

del_log(){
    cd $log_path/../nginx_log_backup/
    echo "[INFO] current directory: `pwd`" | tee -a $LOG_FILE
    echo "[INFO] delete $old log" | tee -a $LOG_FILE
    rm -rf $old
}
nginx_log(){
    cd $log_path
    mkdir -p $log_path/../nginx_log_backup/$yestday
    echo "[INFO] current directory: `pwd`" | tee -a $LOG_FILE
    echo "[INFO] backup $yestday log" | tee -a $LOG_FILE
    mv *.log $log_path/../nginx_log_backup/$yestday/
}

del_log
nginx_log
nginx -t && nginx -s reopen
```

`chmod u+x /data/script/cutNginxLog.sh`

`mkdir -p /data/logs/nginx_log_backup`

`crontab -e`
```
0 0 * * * /data/script/cutNginxLog.sh >/dev/null 2>&1
```


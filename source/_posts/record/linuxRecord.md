---
title: linxu常用命令
categories: 记录
tags:
 - linux
# password: 123456
# abstract: 加密文章，请输入密码 123456 查看
# message: 请输入密码
top: 99
---
## linux 查看内存占用前十的进程

```bash
ps aux|head -1;ps aux|grep -v PID|sort -rn -k +3|head
```

## linux 设置PS1
```bash
PS1='\[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u:\[\033[01;34m\]\W\[\033[00m\]\$'
```

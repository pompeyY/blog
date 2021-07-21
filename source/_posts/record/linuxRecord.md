---
title: linxu常用命令
categories: 记录
tags:
 - 其他
# password: 123456
# abstract: 加密文章，请输入密码 123456 查看
# message: 请输入密码
top: 99
---
## linux 查看内存占用前十的进程

```bash
ps aux|head -1;ps aux|grep -v PID|sort -rn -k +3|head
```

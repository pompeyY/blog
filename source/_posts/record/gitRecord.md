---
title: git常用命令
categories: 记录
tags:
 - 其他
# password: 123456
# abstract: 加密文章，请输入密码 123456 查看
# message: 请输入密码
top: 9
---
## git常用命令

```bash
  git tag                             # 查看tag
  git tag -a v1.0 -m 'some comments'  # 创建
  git push origin --tags              # 提交
```
<!-- > git branch -a 查看所有分支
> git branch -d 分支名   （删除本地分支） -->

### 同步远程分支
```bash
git remote update origin -p
```

### 在本地目录下关联远程repository 
```bash
git remote add origin git@github.com:git_username/repository_name.git
```

### 取消本地目录下关联的远程库
```bash
git remote remove origin
```

### git LF CRLF默认设置
```bash
git config --global core.autocrlf false
```

### git长期存储密码
```bash
git config --global credential.helper store
```

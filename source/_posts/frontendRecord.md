---
title: 前端日常记录
categories: record
tags:
 - other
# password: 123
top: 10
---

# 让移动端滑动更加顺畅

```CSS
  -webkit-overflow-scrolling: touch;
```

## 溢出…

```CSS
  /* 多行溢出 */
  overflow : hidden;
  text-overflow: ellipsis;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;

  /* 单行溢出*/
  overflow: hidden;
  white-space: nowrap;
  text-overflow: ellipsis;
```

<!-- [webpck HYPERLINK "https://segmentfault.com/q/1010000009360389"是不是不能编译这个属性 HYPERLINK "https://segmentfault.com/q/1010000009360389"-webkit-box-orient: vertical](https://segmentfault.com/q/1010000009360389)需要加上下面这段 -->
> 多行溢出不生效 可能情况webpack原因：
```CSS
  /*! autoprefixer: off */
  -webkit-box-orient: vertical;
  /* autoprefixer: on */

  /* 或者 */

  /*! autoprefixer: ignore next */
  -webkit-box-orient: vertical;
```

参考文档[https://segmentfault.com/q/1010000009360389](https://segmentfault.com/q/1010000009360389)

## 缩短网址[http://dwz.cn](http://dwz.cn/)

## IOS 问题

> Iphone 禁止浏览器弹性滚动
Iphone 禁止浏览器弹性滚动  给最外层的盒子上加上 touch-action:none;
如果还是不行就给body加个 height：100%;

```jsx
document.body.addEventListener('touchmove', function (e) {
  e.preventDefault() // 阻止默认的处理方式(阻止下拉滑动的效果)
}, {passive: false}) // passive 参数不能省略，用来兼容ios和android
```

> ios键盘弹出导致失去焦点问题
```jsx
  hanldeBlur = () => {
    setTimeout(function() {
    var scrollHeight = document.documentElement.scrollTop || document.body.scrollTop || 0;
    window.scrollTo(0, Math.max(scrollHeight - 1, 0));
    }, 100);
  }
```

`husky lint-staged`

这两个包在windows下安装必须用npm 不能用cnpm否则无效

> ios `active伪类失效` 解决方案
```HTML
  <body ontouchstart="" onmouseover="">
  <body>
```

> YYYY-MM-DD 这种日期格式在转换时 ios上会出问题 建议用 YYYY/MM/DD

> safari 在低版本对箭头函数的嵌套支持不好 会卡死


## Chrome 浏览器目标填写
```
  - -args --disable-web-security --enable-easy-off-store-extension-install --args --disable-web-security --user-data-dir
  - -args --disable-web-security --user-data-dir
```

## Nginx 常用配置:

```yaml
server {
  listen  80;
  
  #   server_name
  
  root /data/web/happy-pig;
  
  error_log /root/nginx_err.log;
  
  location / {
    
    try_files $uri @fallback;
    
  }
  
  location /happy_pig/api/ {
  
    proxy_set_header X-Real-IP $remote_addr;
    
    proxy_set_header X-Forward-For $proxy_add_x_forwarded_for;
    
    proxy_set_header Host $http_host;
    
    proxy_set_header X-Nginx-Proxy true;
    
    #       proxy_redirect   off;
    
    proxy_pass [http://127.0.0.1:8081](http://127.0.0.1:8081/);
    
  }
  
  location @fallback {
  
    rewrite .* /index.html break;
    
  }
  
}
```

eventloop： 讲解 [https://juejin.im/post/5c9a43175188252d876e5903](https://juejin.im/post/5c9a43175188252d876e5903)

**react项目启动用https的命令：**
```bash
  ($env:HTTPS = "true") -and (npm start)
```
## git常用命令
```bash
  git tag                             # 查看tag
  git tag -a v1.0 -m 'some comments'  # 创建
  git push origin --tags              # 提交
```
<!-- > git branch -a 查看所有分支
> git branch -d 分支名   （删除本地分支） -->

> 同步远程分支
```bash
git remote update origin -p
```

> 在本地目录下关联远程repository 
```bash
git remote add origin git@github.com:git_username/repository_name.git
```

> 取消本地目录下关联的远程库
```bash
git remote remove origin
```

> git LF CRLF默认设置
```bash
git config --global core.autocrlf false
```

> git长期存储密码
```bash
git config --global credential.helper store
```

---
title: Module Federation 总结
categories: 总结
tags:
 - 微前端
 - Module Federation
# password: 123456
# abstract: 加密文章，请输入密码 123456 查看
# message: 请输入密码
top: 98
---

## 什么是Module Federation（简称MF）

MF是webpack5的新特性，关于 module federation，webpack5 官方文档给出了相关说明，原文如下：

> Multiple separate builds should form a single application. These separate builds should not have dependencies between each other, so they can be developed and deployed individually. This is often known as Micro-Frontends, but is not limited to that.

解释如下：一个应用可以由多个独立的构建组成。这些独立的构建之间没有依赖关系，他们可以独立开发、部署。
上述解释，其实就是微前端的概念。
使用 module federation，我们可以在一个 javascript 应用中动态加载并运行另一个 javascript 应用的代码，并实现应用之间的依赖共享。

## MF 配置项
[社区MF配置案例](https://github.com/module-federation/module-federation-examples)
一个完整的 module federation 配置项，包含内容如下：
```javascript
  new ModuleFederationPlugin({
      name: 'xxx',
      filename: 'xxx',
      library: {
          type: 'xxx',
          name: 'xxx'
      },
      remotes: {
          app2: 'app2@xxxx',
          app3: 'app3@xxxx',
          ...
      },
      exposes: {
          './Button': './src/Button',
          ...
      },
      shared: {
          'react': {
              import: 'xxx',
              singleton: true,
              requiredVersion: 'xxx',
              strictVersion: 'xxx',
              shareScope: 'xxx',
              packageName: 'xxx',
              sharedKey: 'xxx',
              eager: true
          }
      },
      shareScope: 'xxx'
  })

```

- **name**
当前应用的别名。

- **filename**
入口文件名， remote 应用供 host 应用消费时，remote 应用提供的远程文件的文件名。

- **exposes**
remote 应用被 host 应用消费时，有哪些输出内容可以被 host 应用使用。
exposes 是一个对象， key 为输出内容在 host 应用中的相对路径，value 为输出内容的在当前应用的相对路径(也可以是绝对路径, 大部分情况应该写相对路径)。
```javascript
new ModuleFederationPlugin({
  ...,
  exposes: {
    './Button': '../src/component/Button'
  }
})

```
!**注意：** 如果我们在 host 应用中是 import('app2/Button'), 那么 exposes 中的 key 必须为 './Button'; 如果是 import('app2/shared/Button')， 那么 exposes 中的 key 必须为 './shared/Button'

- **library**
library 定义了 remote 应用如何将输出内容暴露给 host 应用。
配置项的值是一个对象，如 { type: 'xxx', name: 'xxx'} **type 默认值是var, name默认取的外层name值**
其中，name，暴露给外部应用的变量名； type，暴露变量的方式。
type 的值，和 output.libraryTarget 的值类似，可取的值有:
    - **var** : remote 的输出内容分配给一个通过 var 定义的变量；
    <img src='/images/moduleFederation/1.jpg' style='width: 800px'/> 
    - **window** : remote 的输出内容作为 window 对象的一个属性，属性名为 name 对应的值；
    <img src='/images/moduleFederation/2.jpg' style='width: 800px'/>
    - **assign**: remote 的输出内容分配给一个不通过 var 定义的变量；
    ```javascript
      app2 = (() => {
        ...
        return __webpack_require__(...);
      })();
    ```
    - **this**: remote 的输出内容作为当前上下文 this 的一个属性，属性名为 name 对应的值；
    ```javascript
      this["app2"] = (() => {
        ...
        return __webpack_require__(...);
      })()
    ```
    - **self**: remote 的输出内容作为 self 对象的一个属性，属性名为 name 对应的值；
    ```javascript
      self["app2"] = (() => {
        ...
        return __webpack_require__(...);
      })();
    ```
    - **commonjs**: remote 的输出内容作为 exports 的一个 属性，属性名为 name 对应的值；
    ```javascript
      exports["app2"] = (() => {
        ...
        return __webpack_require__(...);
      })();
    ```
    - **commonjs2**: remote 的输出内容作为 module.exports 的一个 属性，属性名为 name 对应的值；
    ```javascript
      module.exports["app2"] = (() => {
        ...
        return __webpack_require__(...);
      })();   
    ```
    - **amd**: remoteEntry.js 符合 AMD 规范；
    ```javascript
      define('app2', [], function() { return (() => {...})()});
    ```
    - **umd**: remoteEntry.js 符合 UMD 规范；
    ```javascript
      (function(root, factory){
        if(typeof exports === 'object' && typeof module === 'object')
            module.exports = factory();
        else if(typeof define === 'function' && define.amd)
            define([], factory);
        else if(typeof exports === 'object')
            exports["app2"] = factory();
        else
            root["app2"] = factory();
      }(window, function() {
          return (() => {...})()}
      )
    ```
    - **jsonp**: 将 remote 的输出内容包裹到一个 jsonp 包装容器中;
    ```javascript
      app2((() =>{...})())
    ```
    - **system**: remoteEntry.js 符合 Systemjs 规范；
    ```javascript
      System.register("app2", [], function(__WEBPACK_DYNAMIC_EXPORT__, __system_context__) {
        return {
          execute: function() {
        __WEBPACK_DYNAMIC_EXPORT__(...)
          }
        }
      }
    ```
- **remotes**
被当前 host 应用消费的 remote 应用。
remotes 是一个对象，key 值是一个要消费的应用的别名。如果我们在要 host 应用中使用 remote 应用的 button 组件时，我们的代码如下:
```javascript
  const RemoteButton = React.lazy(() => import('app2/button));
```
其中， import url 中的 app2 对应 remotes 配置项中的 key 值。
value 为 remote 应用的对外输出及url，**格式必须严格遵循: 'name@url'**。其中， name 对应 remote 应用中 library 中的 name 配置项， url 对应 remote 应用中 remoteEnter 文件的链接。
- **shared**
shared 配置项指示 remote 应用的输出内容和 host 应用可以共用哪些依赖。 **shared 要想生效，则 host 应用和 remote 应用的 shared 配置的依赖要一致**。
    - **import**
    共享依赖的实际的 package name。
    ```javascript
      {
        ...,
        shared: {
          'react-shared': {
              import: 'react'
            }
        }
      }
    ```
    如果未指定，默认为用户自定义的共享依赖名，即 react-shared。如果是这样的话，webpack 打包是会抛出异常的，因为实际上并没有 react-shared 这个包。
    - **singleton**
    是否开启单例模式。默认值为 false，即不开单例模式，如果值为 true，开启单例模式；值为 false，不开启单例模式。
    如何启用单例模式，那么 remote 应用组件和 host 应用共享的依赖只加载一次，且与版本无关。
    如果版本不一致，会给出警告。
    加载的依赖的版本为 remote 应用和 host 应用中，版本比较高的。
    不开启单例模式下，如果 remote 应用和 host 应用共享依赖的版本不一致，remote 应用和 host 应用需要分别各自加载依赖。
    - **requiredVersion**
    指定共享依赖的版本，默认值为当前应用的依赖版本。
    如果 requiredVersion 与实际应用的依赖的版本不一致，会给出警告。
    - **strictVersion**
    是否需要严格的版本控制，默认值为 false。
    单例模式下，如果 strictVersion 与实际应用的依赖的版本不一致，会抛出异常。
    - **shareKey**
    共享依赖的别名, 默认值值 shared 配置项的 key 值。
    - **shareScope**
    当前共享依赖的作用域名称，默认为 default
    打包之后会作为 `__webpack_require__.S` 的key, `__webpack_require__.S["default"]` 中的 default 即为 shareScope 指定的 default
    - **eager**
    共享依赖在打包过程中是否被分离为 async chunk，默认值为 false。
    eager 为 false， 共享依赖被单独分离为 async chunk； eager 为 true， 共享依赖会打包到 main、remoteEntry，不会被分离。
    如果设置为 true， 共享依赖其实是没有意义的，在某些场景下如果依赖单独分离成async chunk时报错，可以改为true。
- **shareScope**
所用共享依赖的作用域名称，默认为 default。
如果 shareScope 和 share["xxx"].shareScope 同时存在，share["xxx"].shareScope 的优先级更高。


## shared解析及常用配置
module federation 在初始化 shareScope 时，会比较 host 应用和 remote 应用之间共享依赖的版本，将 shareScope 中共享依赖的版本更新为较高版本。
在加载共享依赖时，如果发现实际需要的版本和 shareScope 中共享依赖的版本不一致时，会根据 share 配置项的不同做相应处理：
> 如果配置 singleton 为 ture，实际使用 shareScope 中的共享依赖，控制台会打印版本不一致警告；
> 如果配置 singleton 为 ture，且 strictVersion 为 ture，即需要保证版本必须一致，会抛出异常；
> 如果配置 singleton 为 false，那么应用不会使用 shareScope 中的共享依赖，而是加载应用自己的依赖；
综上，如果 host 应用和 remote 应用共享依赖的版本可以兼容，可将 singleton 配置为 ture；如果共享依赖版本不兼容，需要将 singleton 配置为 false。

shared参数常用配置：
```javascript
const deps = require("./package.json").dependencies;
  ...
new ModuleFederationPlugin({
  ...
  shared: {
    ...deps, // 所有dependencies 依赖共享
    moment: deps.moment, // 单独共享，如果版本不一致则各自用各自的依赖
    react: {  // react开启单例模式 strictVersion默认false 版本不一致会警告，不会报错，共享依赖的版本不一致时取较高版本
      singleton: true,
    },

    "react-dom": { // 和上面react 类似，requiredVersion 默认值为当前应用的依赖版本可以不写
      requiredVersion: deps["react-dom"],
      singleton: true,
    },
    react: { // 详细配置 看上面各配置项解析---不常用
      import: "react", // the "react" package will be used a provided and fallback module
      requiredVersion: deps.react,
      shareKey: "react", // under this name the shared module will be placed in the share scope
      shareScope: "default", // share scope with this name will be used
      singleton: true, // only a single version of the shared module is allowed
    },
  },
})

```

## MF工作原理浅析

### 正常情况下webpack构建应用
webpack 在构建过程中，会以 entry 配置项对应的入口文件为起点，收集整个应用中需要的所有模块，建立模块之间的依赖关系，生成一个模块依赖图。然后再将这个模块依赖图，切分为多个 chunk，输出到 output 配置项指定的位置。
通常情况下，一个完整的 webpack 构建，它的结构一般如下：
<img src='/images/moduleFederation/3.jpg' style='width: 800px'/>

最后的构建内容包括：main-chunk 和 async chunk。
**main-chunk** 为入口文件(通常为 index.js) 所在的 chunk，内部包含 runtime 模块、index 入口模块、第三方依赖模块(如 react、react-dom、antd 等)和内部组件模块(如 com-1、com-2 等)；
**async-chunk** 为异步 chunk，内部包含需要异步加载(懒加载)的模块。

现在以社区MF案例 [automatic-vendor-sharing](https://github.com/module-federation/module-federation-examples/tree/master/advanced-api/automatic-vendor-sharing)为例

<div style='widht: 800px;display: flex; align-items: center;justify-content: center;'>
    <img src="/images/moduleFederation/5.jpg" style='min-width: 300px'/>
    <div style='display: flex; flex-wrap: wrap;'>
      <div style='display: flex'>
        <img src="/images/moduleFederation/6.jpg" style='flex: 1'/>
        <img src="/images/moduleFederation/7.jpg" style='flex: 1'/>
      </div>
      <div style='display: flex'>
        <img src="/images/moduleFederation/8.jpg" style='flex: 1'/>
        <img src="/images/moduleFederation/9.jpg" style='flex: 1'/>
      </div>
    </div>
</div>

如果未使用 module federation 功能，那他们的 webpack 构建如下：
<img src='/images/moduleFederation/4.jpg' style='width: 800px'/>

> 看上图，我们会发现 在index.js 中，是通过 import("./bootstrap") 的方式导入 bootstrap.js 的，导致会生成一个包含 bootstrap、App、Button、React、React-dom 的 async chunk。webpack 在打包过程中，如果发现 async-chunk 中有第三方依赖(即 react、react-dom)，则会把第三方依赖从 async-chunk 中分离，构建一个新的 vendors-chunk。

**截取部分代码：**
```javascript
// main-chunk
(() => {
  // 用于缓存模块的执行方法。key 值对应模块的 id， value对应模块的执行方法。
  // webpack 在打包时，会把每一个模块处理为一个执行方法。当运行这个执行方法时，会执行模块对应的相关代码，并返回模块的输出
  var __webpack_modules__ = {
      ...
  };
  // 用于缓存模块的输出。key值对应模块的 id，value 对应模块的输出。
  var __webpack_module_cache__ = {};

  //用于获取模块的输出。源代码中的 "import xx from 'xxx'",最终会被转化为 __webpack_require__(...) 的形式。
  // __webpack_require__方法在获取模块输出时，会先根据模块 id 在__webpack_module_cache 中查找对应的输出。如果没有找到，就去 __webpack_modules__ 中获取模块的执行方法，然后运行模块的执行方法，获取模块的输出并缓存到 __webpack_module_cache 中。
  function __webpack_require__(moduleId) {
    if (__webpack_module_cache__[moduleId]) {
          return __webpack_module_cache__[moduleId].exports;
      }
      var module = __webpack_module_cache__[moduleId] = {
          exports: {}
      }
      __webpack_module__[moduleId](module, module.exports, __webpack_require);
      return module.exports;
  }
  
  ...
  
  // 重要：__webpack_require__.l 是一个方法，用于加载 async-chunk。__webpack_require__.l 会根据 async-chunk 对应的 url，通过动态添加 script 的方式，获取 async-chunk 对应的 js 文件，然后执行。
  __webpack_require__.l = (url, done, key, chunkId) => { ... }
  
  ...
  
  __webpack_require__.f.j = (chunkId, promises) => { ... }
  
  ...
  
  // 用于缓存 chunk。key 值对应 chunk 的 id，value 为 0。
  var installedChunks = { ... }


  //webpackJsonpCallback 是一个挂载到全局变量(window、global、self) 上的全局方法，用于安装 chunk。这个方法执行时，会把 chunk 内部包含的模块及模块的执行方法收集到 __webpack_modules__ 中。
  var webpackJsonpCallback = (parentChunkLoadingFunction, data) => { ... }
  
  var chunkLoadingGlobal = self["webpackChunk_automatic_vendor_sharing_app1"] = self["webpackChunk_automatic_vendor_sharing_app1"] || [];
  chunkLoadingGlobal.forEach(webpackJsonpCallback.bind(null, 0));
  chunkLoadingGlobal.push = webpackJsonpCallback.bind(null, chunkLoadingGlobal.push.bind(chunkLoadingGlobal));
  
  ...
  
  Promise.all(/* import() */[__webpack_require__.e(935), __webpack_require__.e(902)]).then(__webpack_require__.bind(__webpack_require__, 902));
})()
```
```javascript
  // vendors-chunk
  (self["webpackChunk_automatic_vendor_sharing_app1"] = self["webpackChunk_automatic_vendor_sharing_app1"] || []).push([[935],{
    "./node_modules/react-dom/cjs/react-dom.development.js": (__unused_webpack_module, exports, __webpack_require__) => { ... },
      ...

  }])
```
```javascript
  // async-chunk
  (self["webpackChunk_automatic_vendor_sharing_app1"] = self["webpackChunk_automatic_vendor_sharing_app1"] || []).push([[902],{
      "./src/App.js": (__unused_webpack_module, __webpack_exports__, __webpack_require__) => { ... },
      "./src/Button.js": (__unused_webpack_module, __webpack_exports__, __webpack_require__) => { ... },
      "./src/bootstrap.js": (__unused_webpack_module, __webpack_exports__, __webpack_require__) => { ... },
  }])
```
**webpack 构建的大致工作过程：**
1. 打开应用，加载 main-chunk 对应的 js 文件；
2. 执行 main-chunk.js， 定义 __webpack_modules__、__webpack_module_cache__、__webpack_require__、installedChunks、webpackJsonpCallback、__webpack_require__.l 等；
3. 执行入口模块 index 对应的代码；
4. 如果遇到依赖模块，通过 __webpack_require__ 方法获取依赖模块的输出(先从 __webpack_module_cache 中获取，如果没有，运行 __webpack_modules__ 中模块对应的执行方法 );
5. 如果遇到懒加载模块，通过 __webpack_modules__.l 方法获取对应的 async-chunk 并执行，然后获取相应的输出；

### 使用 module federation 的 webpack 构建

app1、app2 使用 module federation 功能以后，对应的 webpack 构建如下：
<img src='/images/moduleFederation/10.jpg' style='width: 800px'/>

> 在新的打包文件中，我们发现新增了 remoteEntry-chunk、包含 button 模块的 expose-chunk 以及包含 react 模块的 shared-chunk1 和 包含 react-dom 模块的 shared-chunk2。
> remoteEntry-chunk 内部主要包含 runtime 模块，expose-chunk 中包含可被 host 应用使用的 button 组件

出现上述情况，主要和 ModuleFederationPlugin 的 exposes、shared 配置项有关。
> 首先是 exposes 配置项。exposes 配置项定义了 remote 应用的哪些组件可以被 host 应用使用。webpack 打包时，会根据 exposes 配置项，生成一个 remoteEntry-chunk 和多个 expose-chunk。应用启动以后，host 应用就可以根据 remotes 配置项指定的 url 去加载 remote 应用的 remoteEntry-chunk 和 expose-chunk。
> 其次是 shared 配置项。shared 配置项定义了 host 应用和 remote 应用的 expose-chunk 之间可共享的依赖。shared 指定了共享的依赖为 react、react-dom，因此 react 模块和 react-dom 模块会被分离为新的 shared-chunk。

app1和app2的MF配置如下
<div style='widht: 800px;display: flex; align-items: center;justify-content: center;'>
  <img src="/images/moduleFederation/11.jpg" style='flex: 1'/>
  <img src="/images/moduleFederation/12.jpg" style='flex: 1'/>
</div>

通过前面打包之后的图片可以猜到module federation 实现应用间组件互用的原理。
就是 remote 应用生成一个 remoteEntry-chunk 和多个 expose-chunk。 host 应用启动后，通过 remotes 配置项指定的 url，去动态加载 remote 应用的 remoteEntry-chunk 和 expose-chunk，然后执行并渲染 remote 应用的组件。

在 一个常见的 webpack 构建如何工作 的构建结果中，我们可以发现多个 webpack 构建之间其实是相互隔离、无法互相访问的。那么 module federation 是如何打破这种隔离的呢？
答案是 **sharedScope** - 共享作用域。应用启动以后， host 应用和 remote 应用的 remote-chunk 之间会建立一个可共享的 sharedScope，内部包含可共享的依赖。

使用 module federation 功能以后，webpack 会在 app1 应用的 main-chunk 的 runtime 模块中添加一段逻辑：
```javascript
var __webpack_modules__ = {
	...
    // 运行执行方法时，会动态加载 app2 的 remoteEntry.js。  
    "webpack/container/reference/app2": (module, __webpack_exports, __webpack_require__) => {
         ...
         module.exports = new Promise((resolve, reject) => {
	     ...
	     __webpack_require__.l("http://localhost:3002/remoteEntry.js", (event) => {...}, "app2");
       }).then(() => app2);
    }
}

...

(() => {
    // S 是一个普通对象，用于存储 app1 中 shared 配置项指定的共享内容。
    __webpack_require__.S = {};
    
    // 方法用于初始化 app1 的 __webpack_require__.S 对象。
    __webpack_require__.I = (name, initScope) => {
    	...
        var scope = __webpack_require__.S[name];
        ...
        //会将 shared 配置项指定的共享依赖及获取方法添加到 __webpack_require__.S 中；
        var register = (name, version, factory) => {
            var versions = scope[name] = scope[name] || {};
            var activeVersion = versions[version];
            if(!activeVersion || !activeVersion.loaded && uniqueName > activeVersion.from) versions[version] = { get: factory, from: uniqueName }
        }
        
        //会加载 app2 提供的 remoteEntry.js，然后使用 app1 应用的 __webpack_require__.S 来初始化 app2 应用的 __webpack_require__.S 对象。
        var initExternal = (id) => {
            ...
            var module = __webpack_require__(id);
            if(!module) return;
            var initFn = (module) => module && module.init && module.init(__webpack_require__.S[name], initScope);
            if(module.then) return promises.push(module.then(initFn, handleError));
            var initResult = initFn(module);
            if(initResult && initResult.then) return promises.push(initResult.catch(handleError));
        }
        
        ...
        
        switch(name) {
            case "default": {
                register("react-dom", "17.0.1", () => Promise.all([__webpack_require__.e("vendors-node_modules_react-dom_index_js"), __webpack_require__.e("webpack_sharing_consume_default_react_react-_2997")]).then(() => () => __webpack_require__(/*! ./node_modules/react-dom/index.js */ "./node_modules/react-dom/index.js")));
                register("react", "17.0.1", () => Promise.all([__webpack_require__.e("vendors-node_modules_react_index_js"), __webpack_require__.e("node_modules_object-assign_index_js")]).then(() => () => __webpack_require__(/*! ./node_modules/react/index.js */ "./node_modules/react/index.js")));
                initExternal("webpack/container/reference/app2");
         }
         break;
      }
      ...
   }
    
})()
```

 app2 应用的 remote-chunk 的代码片段如下：
```javascript
  var app2 = (() => {
    ...
    var __webpack_modules = ({
        "webpack/container/entry/app2": (__unused_webpack_module, exports, __webpack_require__) => {
          ...
          var get = (module, getScope) => {...}

          // 这个方法会使用 app1 的 __webpack_require__.S 来初始化 app2 的 __webpack_require__.S。
          // 在初始化的时候，会对比 app1 、app2 中 react、react-dom 的版本，将 shareScope 中的共享依赖更新为两个应用里面较新的版本。
          // 即如果 app1 中 react 的版本高于 app2， 那么 __webpeck_require__.S[default].react的 from 和 init 属性对应 app1，实际使用时 react 是从 app1 中获取；反之__webpeck_require__.S[default].react的 from 和 init 属性对应 app2，实际使用时 react 是从 app2 中获取.
          var init = (shared, initScope) => {
              if (!__webpack_require__.S) return;
              var oldScope = __webpack_require__.S["default"];
              var name = "default";
              ...
              __webpack_require__.S[name] = shareScope;
            return __webpack_require__.I(name, initScope);
          }
          __webpack_require__.d(exports, {
              get: () => get;
              init: () => init
          });
        }
    
    })
    
    ... // 中间部分和 app1 的 main-chunk 的 runtime 基本相同
    return __webpack_require("webpack/container/entry/app2")

})()
```

以上依赖共享的实现逻辑，简要流程：
1. 打开应用 app1， 加载 main-chunk 对应的 js 文件；
2. 执行 main-chunk.js， 定义 __webpack_modules__、__webpack_module_cache__、__webpack_require__、installedChunks、webpackJsonpCallback、__webpack_require__.l、__webpack_require__.S、__webpack_require__.I 等；
3. 执行入口模块 index.js 对应的代码。执行时，会触发 __webpack_require__.I 的执行；
4. __webpack_require__.I 方法开始执行，首先通过 register 方法初始化 __webpack_require__.S 对象，然后通过 initExternal 方法去获取 app2 的 remoteEntry.js。获取 app2 的 remoteEntry.js 时，会返回一个 promise 对象，当 app2 的 remoteEntry.js 加载并执行完毕时， promise 的状态才会变为 resolved；
5. 动态加载 app2 应用 的 remoteEntry.js 并执行，返回一个包含 get、init 的全局变量 app2；
6. 步骤 4 中的 promise 对象的状态变为 resolved，注册的 callback 触发，开始执行 app2.init；
7. app2.init 方法执行，使用 app1 应用的 __webpack_require__.S 初始化 app1 应用的 __webpack_require__.S。

应用启动以后， app1 的结构如下：
<img src='/images/moduleFederation/13.jpg' style='width: 800px'/>

### 为什么 index.js 中需要以 import() 的方式引入 bootstrap.js ？
如果不使用```import()``这种写法会报错
1. 使用import()这种写法，入口文件会回打包进异步chunk
2. 在异步chunk中，会去加载所有需要的依赖，也就是依赖前置
3. 在加载的过程中发现依赖的远程remotes，会加载该remotes的js
4. remotes的js又会有各种依赖，根据MF的shared配置，将共享依赖放到之前提到的 shareScope 即共享作用域
5. 所有依赖以及chunk都加载完成之后，才会去执行bootstrap.js里面的module 进行正常渲染了

<img src='/images/moduleFederation/14.jpg' style='width: 500px'/>

---
title: 微前端总结
categories: 总结
tags:
 - 微前端
# password: 123456
# abstract: 加密文章，请输入密码 123456 查看
# message: 请输入密码
top: 98
---

<!-- ## aaa
![1.png](/images/microFrontEnd/1.png) -->

## 背景
从 [Micro Frontends](https://micro-frontends.org/) 官网可以了解到，微前端概念是从微服务概念扩展而来的，摒弃大型单体方式，将前端整体分解为小而简单的块，这些块可以独立开发、测试和部署，同时仍然聚合为一个产品出现在客户面前。可以理解微前端是一种将多个可独立交付的小型前端应用聚合为一个整体的架构风格。

**值得留意的几个点：**

- 微前端不是一门具体的技术，而是整合了技术、策略和方法，可能会以脚手架、辅助插件和规范约束这种生态圈形式展示出来，是一种宏观上的架构。这种架构目前有多种方案，都有利弊之处，但只要适用当前业务场景的就是好方案。
- 微前端并没有技术栈的约束。每一套微前端方案的设计，都是基于实际需求出发。如果是多团队统一使用了react技术栈，可能对微前端方案的跨技术栈使用并没有要求；如果是多团队同时使用了react和vue技术栈，可能就对微前端的跨技术栈要求比较高。

## 优势

1. **同步更新**
对比了npm包方式抽离，让我们意识到更新流程和效率的重要性。微前端由于是多个子应用的聚合，如果多个业务应用依赖同一个服务应用的功能模块，只需要更新服务应用，其他业务应用就可以立马更新，从而缩短了更新流程和节约了更新成本。

2. **简单、解耦的代码库**
每个单独的微前端项目的源代码库会远远小于一个单体前端项目的源代码库。这些小的代码库将会更易于开发。更值得一提的是，我们避免了不相关联的组件之间无意造成的不适当的耦合。通过增强应用程序的边界来减少这种意外耦合的情况的出现。

3. **独立部署**
与微服务一样，微前端的独立可部署性是关键。它减少了部署的范围，从而降低了相关风险。无论您的前端代码在何处托管，每个微前端都应该有自己的连续交付通道，该通道可以构建、测试并将其一直部署到生产环境中。我们应当能够在不考虑其他代码库或者是通道的情况下来部署每个微服务。

1. **多项目合并为一个单页应用**
很多微前端解决方案可以通过组织HTML或者组件化让多个项目之间合并到一块，成为一个单页应用，让体验更好。


## 微前端方案种类

**目前国内微前端方案大概分为：**

- **基座模式：** 通过搭建基座、配置中心来管理子应用。如基于SIngle Spa的偏通用的qiankun方案，也有基于本身团队业务量身定制的方案。
- **自组织模式：** 通过约定进行互调，但会遇到处理第三方依赖等问题。
- **去中心模式：** 脱离基座模式，每个应用之间都可以彼此分享资源。如基于**Webpack 5 Module Federation**实现的EMP微前端方案、或者**nebula微前端**解决方案，可以实现多个应用彼此共享资源分享。

## 现有微前端解决方案
### iframe
  众所周知，iframe是html提供的标签，能加载其他web应用的内容，并且它能兼容所有的浏览器，因此，你可以用它来加载任何你想要加载的web应用。iframe最大的特性就是提供了浏览器原生的硬隔离方案，不论是样式隔离、js 隔离这类问题统统都能被完美解决。**iframe虽然基本能做到微前端所要做的所有事情，但它的最大问题也在于他的隔离性无法被突破，导致应用间上下文无法被共享，随之带来开发体验、产品体验的问题。**
  **不足：**
  -  不是单页应用，会导致浏览器刷新 iframe url 状态丢失。
  -  弹框类的功能无法应用到整个大应用中，只能在对应的窗口内展示。
  -  由于可能应用间不是在相同的域内，主应用的 cookie 要透传到根域名都不同的子应用中才能实现免登录效果。
  -  每次子应用进入都是一次浏览器上下文重建、资源重新加载的过程，占用大量资源的同时也在极大地消耗资源。 经过以上思考，我个人也有了一些拓展总结：
  -  iframe的特性导致搜索引擎无法获取到其中的内容，进而无法实现应用的seo

### Web Components
  MDN对Web Components的定义是这样的：
  > 作为开发者，我们都知道尽可能多的重用代码是一个好主意。这对于自定义标记结构来说通常不是那么容易 — 想想复杂的HTML（以及相关的样式和脚本），有时您不得不写代码来呈现自定义UI控件，并且如果您不小心的话，多次使用它们会使您的页面变得一团糟。
  > Web Components旨在解决这些问题 — 它由三项主要技术组成，它们可以一起使用来创建封装功能的定制元素，可以在你喜欢的任何地方重用，不必担心代码冲突。
  
  **它的三项主要技术是指：**
  - **Custom elements（自定义元素）：**一组JavaScript API，允许您定义custom elements及其行为，然后可以在您的用户界面中按照需要使用它们。
  - **Shadow DOM（影子DOM）：** 一组JavaScript API，用于将封装的“影子”DOM树附加到元素（与主文档DOM分开呈现）并控制其关联的功能。通过这种方式，您可以保持元素的功能私有，这样它们就可以被脚本化和样式化，而不用担心与文档的其他部分发生冲突。
  - **HTML templates（HTML模板）：** ` <template> ` 和 ` <slot> ` 元素使您可以编写不在呈现页面中显示的标记模板。然后它们可以作为自定义元素结构的基础被多次重用。 通过以上描述，再结合微前端的概念. 

  **我们来看看Web Components是如何做到微前端：**
  - **技术栈无关：** Web Components是浏览器原生组件，那即是在任何框架中都可以使用。
  - **独立开发：** 使用Web Components开发的应用无需与其他应用间产生任何关联。
  - **应用间隔离：** Shadow DOM的特性，各个引入的微应用间可以达到相互隔离的效果。 综上所述，Web Components是有能力以组件加载的方式将微应用整合在一起作为微前端的一种手段，但不幸的是，Web Components是浏览器的新特性，所以它的兼容性不是很好，如果有兼容性要求的项目还是无法使用，具体请查看[can i use](https://caniuse.com/?search=WebComponents)。

### [MicroApp（京东开源）](https://zeroing.jd.com/micro-app/docs.html#/zh-cn/start)
  **类WebComponent：** 就是使用CustomElement结合自定义的ShadowDom实现WebComponent基本一致的功能。
  由于ShadowDom存在的问题，采用自定义的样式隔离和元素隔离实现ShadowDom类似的功能，然后将微前端应用封装在一个CustomElement中，从而模拟实现了一个类WebComponent组件，它的使用方式和兼容性与WebComponent一致，同时也避开了ShadowDom的问题。并且由于自定义ShadowDom的隔离特性，Micro App不需要像single-spa和qiankun一样要求子应用修改渲染逻辑并暴露出方法，也不需要修改webpack配置。
  通过上述方案封装了一个自定义标签micro-app，它的渲染机制和功能与WebComponent类似，开发者可以像使用web组件一样接入微前端。它可以兼容任何框架，在使用方式和数据通信上也更加组件化，这显著降低了基座应用的接入成本，并且由于元素隔离的属性，子应用的改动量也大大降低。  
  **这是该框架现有的功能对比图（仅供参考）**
  ![](/images/microFrontEnd/1.png)

  **不足：**
  - 多个项目之间不能共用相同的依赖
  - 应用级别的引用，不够灵活
  - 不够成熟

### qiankun
在微前端界，qiankun算得上是最早成型且知名度最广的框架了，它是真正意义上的单页微前端框架，那么qiankun到底有哪些特点呢，在其[官网](https://qiankun.umijs.org/zh/guide)中我找到了如下概括：
- 基于single-spa封装，提供了更加开箱即用的 API
- 技术栈无关，任意技术栈的应用均可 使用/接入，不论是 React/Vue/Angular/JQuery 还是其他等框架
- HTML Entry 接入方式，让你接入微应用像使用 iframe 一样简单
- 样式隔离，确保微应用之间样式互相不干扰
- JS 沙箱，确保微应用之间 全局变量/事件 不冲突
- 资源预加载，在浏览器空闲时间预加载未打开的微应用资源，加速微应用打开速度
- umi 插件，提供了 @umijs/plugin-qiankun 供 umi 应用一键切换成微前端架构系统 除了最后一点拓展以外，微前端想要达到的效果都已经达到。

**不足：**
  - 多个项目之间不能共用相同的依赖
  - 应用级别的引用，不够灵活

### EMP
[EMP](https://github.com/efoxTeam/emp)是由欢聚时代业务中台自主研发的最年轻的单页微前端解决方案
**功能：**
- 基于Webpack5的新特性**Module Federation**实现，达到第三方依赖共享，减少不必要的代码引入的目的。
- **每个微应用独立部署运行**，并通过cdn的方式引入主程序中，因此只需要部署一次，便可以提供给任何基于Module Federation的应用使用。并且此部分代码是远程引入，无需参与应用的打包。
- **动态更新微应用**：EMP是通过cdn加载微应用，因此每个微应用中的代码有变动时，无需重新打包发布新的整合应用便能加载到最新的微应用。
- **去中心化**，每个微应用间都可以引入其他的微应用，无中心应用的概念。
- **跨技术栈组件式调用**，提供了在主应用框架中可以调用其他框架组件的能力（目前已支持互相调用的框架及使用方式请参阅官方文档）。
- **按需加载**，开发者可以选择只加载微应用中需要的部分，而不是强制只能将整个应用全部加载（**这是与上面几种微前端解决方案中最大的不同**）。
- **应用间通信**，每一个应用都可以进行状态共享，就像在使用npm模块进行开发一样便捷。
- **生成对应技术栈模板**，它能像create-react-app一样，也能像create-vue-app一样，通过指令一键搭建好开发环境，减少开发者的负担。
- **远程拉取ts声明文件**，emp-cli中内置了拉取远程应用中代码声明文件的能力，让使用ts开发的开发者不再为代码报错而烦恼。

**不足：**
  - 是一套全新的脚手架，对现有项目改动较大，老项目迁移都必须用这个框架重构。
  - 没有实现js隔离
  - 使用时会有框架的限制。不过目前已经支持了主流框架。



### nebula
[nebula](https://code.haiziwang.com/b/nebula/cli)是由孩子王自主研发的微前端解决方案。
**功能：**
- 基于Webpack5的新特性**Module Federation**实现，达到第三方依赖共享，减少不必要的代码引入的目的。
- **每个微应用独立部署运行**，并通过cdn的方式引入主程序中，因此只需要部署一次，便可以提供给任何基于Module Federation的应用使用。并且此部分代码是远程引入，无需参与应用的打包。
- **动态更新微应用**：EMP是通过cdn加载微应用，因此每个微应用中的代码有变动时，无需重新打包发布新的整合应用便能加载到最新的微应用。
- **去中心化**，每个微应用间都可以引入其他的微应用，无中心应用的概念。
- **跨技术栈组件式调用**，提供了在主应用框架中可以调用其他框架组件的能力（目前已支持互相调用的框架及使用方式请参阅官方文档）。
- **按需加载**，开发者可以选择只加载微应用中需要的部分，而不是强制只能将整个应用全部加载。
- **远程拉取ts声明文件**，emp-cli中内置了拉取远程应用中代码声明文件的能力，让使用ts开发的开发者不再为代码报错而烦恼。

**与EMP的差异：**
- 由于公司使用的react脚手架是基于create-react-app的，所以迁移EMP成本较大，但是create-react-app并没有升级到WP5(Webpack5),用不了MF(Module Federation)功能，所以自己将create-react-app 现有版本的基础上升级到WP5(参考create-react-app WP5社区版升级)，后面CRA官方升级WP5之后，可以无缝切换回官方版本
- 暂时没有实现应用间通信，后面使用场景增加之后，可以添加。


## nebula使用

### 基础命令

1. 安装

```bash
npm install @nebula/cli -g --registry=https://npmneibu.haiziwang.com/
```

2. 初始化项目

```bash
nebula init
```

![](/images/microFrontEnd/2.jpg)

3. 其他命令

- 查看所有命令

```bash
nebula -h
```

![](/images/microFrontEnd/3.jpg)

- 创建项目ts文件(其中fileName可以改变d.ts中 declare后面的前缀 默认取package.json中的name， 既package name与MF中的fileName不相等时使用)

```bash
nebula tsc -n|--createName, -p|--createPath -f|--fileName  
```
- ts类型根据 nebula.config.js 同步

```bash
nebula tsf 
```
- ts类型远程同步

```bash
nebula tss <remoteUrl> -n|--saveName, -p|--savePath 
```

**依赖架构**

![](/images/microFrontEnd/4.jpg)


### nebula的公共基座

[项目base](https://code.haiziwang.com/b/nebula/base) 可以点击查看

> 基座需要在package.json配置 build:tsc 命令 用于创建ts声明文件 **MF的语法解释放在后面**

![](/images/microFrontEnd/5.jpg)

> 然后在craco.config.js当中将要导出 供其他应用使用的公共 变量、方法或者组件在plugins中配置

![](/images/microFrontEnd/6.jpg)

### nebula的子项目

真实线上使用项目 1.[聚客宝雇主端H5](https://code.haiziwang.com/b/sales-adviser-b-m)  2.[H5商业化](https://code.haiziwang.com/tools-web/business-h5)

用nebula 初始化过之后需要添加几个配置即可正常使用
1. 在package.json中添加一个script

```json
 "scripts": {
    "prestart": "nebula tsf",
  }
```

2. 在根目录新建nebula.config.js文件 文件中添加

```javascript
module.exports = {
  dts: [
    {
      saveName: 'nebulatBase.d.ts', // 保存的文件名称
      savePath: 'src/types',    // 保存文件的位置
      remoteUrl: 'https://fedcineibu.haiziwang.com/dts/nebula/nebulaBase.d.ts', // 远程ts地址
    }
  ]
}

```

3. 在craco.config.js中的plugins 添加MF配置即可

![](/images/microFrontEnd/7.jpg)




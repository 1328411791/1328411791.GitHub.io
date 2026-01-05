---
tags: [量化交易]
mermaid: true
date: 2025-10-18 16:17:11
---

# 踩坑

在使用 IBKR API 进行以及初步学习量化交易的过程中，我遇到了一些问题，特此记录下来以备后续参考。


# 环境配置

# 安装IBKR Gateway

安装官网上ibkr gateway应用（此应用作为沟通程序与IBKR服务器的桥梁），并配置好API访问权限。不使用TWS的原因是TWS功能过于复杂，且资源占用较高，ui有一种上世纪的美感。

地址：https://www.interactivebrokers.com/cn/trading/ibgateway-latest.php

![](https://pic.liahnu.top/img/202510181635896.png)


一些默认的配置
![](https://pic.liahnu.top/img/202510181638813.png)

推荐开一个ibkr的模拟账户进行测试，同时开一个子用户购买数据订阅服务，以免影响主账户的正常使用。

## 安装python库环境

## 安装 ib_async
ib_async 是一个第三方对接IBKR API的python库，功能完善且易用。

安装ib_async库，注意不是ib_insync，ib_insync已经被停止维护弃用，文档地址已经指引到ib_async中。

    官方文档：
    考虑到这一点，用户应该知道，原始ib_insync包是使用旧版TWS API构建的，不再更新。希望使用受支持的 Trader Workstation 版本实现ib_insync结构的用户应迁移到 ib_async 包 ，该包是由其原始开发人员之一对该包进行现代化实现。 


相关文档：
1. https://ib-api-reloaded.github.io/ib_async/notebooks.html
2. https://www.interactivebrokers.com/campus/ibkr-api-page/twsapi-doc/#non-tws-api-support

```python
pip install ib_async
```

## 安装官方api

部分应用可能需要安装官方api，这里提供官方api安装方法
https://www.interactivebrokers.com/campus/ibkr-api-page/twsapi-doc/#windows-install


盈透证券官方 API 仅通过其 Github 站点提供，而不是 Python 包索引 （PyPI），因为它是在不同的许可证下分发的。但是，您可以从提供的源代码构建一个轮子，然后安装轮子。这些是步骤：

1） 从 http://interactivebrokers.github.io/ 下载“API 最新” http://interactivebrokers.github.io/

2） 解压缩或安装（如果是.msi文件）下载。

3） 转到 tws-api/source/pythonclient/

4） 安装：

```shell
$  cd ~/TWS API/source/pythonclient
$  python3 setup.py install
```
在 TWS API\samples\Python 下有一些demo测试api是否已经安装


# 连接IBKR Gateway
使用ib_async连接IBKR Gateway，代码如下：

```python
    from ib_async import *
    ib = IB()
    ib.connect('127.0.0.1', 4002, clientId=991)
    logging.info("已连接到IBKR服务器")
```

注意：4002端口是IBKR Gateway的默认API端口，TWS的默认端口是7497。
端口可以在gateway的配置界面中查看和修改，clientId是用户自定义的一个标识符，可以随意设置，但同一时间只能有一个客户端使用同一个clientId连接到IBKR服务器，否则会导致连接失败。


## 常用api

    等我研究研究

## vnpy

vnpy是一个开源的量化交易框架，支持多种交易所和数据源，包括IBKR。它提供了丰富的功能和工具，适合用于构建和运行量化交易策略。

### 踩到的坑

1. vnpy-ib的安装，需要去clone vnpy-ib的的仓库，手动安装更新依赖，之后再安装protobuf

2. 使用vnpy-alpha的时候，需要安装alphalens依赖，使用pip install alphalens-reloaded安装最新版本，老版本的alphalens不兼容最新的python版本。

# 量化交易入门

量化交易的核心在于设计和实现一个有效的交易策略。

等我读一些文章再来写吧，我觉得对接api属于苦力活，难点还是在如何设计一个完善的交易策略上。这里简单的用tradeviewer的策略回测功能来验证一下交易策略的有效性。跑个demo策略。

## 某些神奇策略

记录一下从网上cp的或者不知道从哪来的策略

## SuperTrend + MME + 
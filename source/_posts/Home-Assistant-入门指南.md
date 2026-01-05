---
layout: p
title: Home Assistant 入门指南
date: 2025-05-26 00:33:48
tags: [nas]
---

# 使用飞牛os 安装 Home Assistant 

本人使用的设备是飞牛os，在应用商店中可以看到配置好的Home Assistant Docker 版本，点击下载，安装到需要的位置。安装完成后，配置相关账户和密码，地区即可进入页面。Home Assistant 本体就算安装完成了。

安装完成本体后，最好可以在DNS内配置Home Assistant 对应的域名解析，即`homeassistant.local`,解析到相关nas设备。方便后续配置时候提供网络域名服务。我这边使用的设备是Openwrt，在网络-DHCP/DNS 下方配置自定义挟持域名，解析到目标服务器。


# 配置相关插件

安装完成后，针对家庭情况（我这边基本上都是米家） 需要安装一些插件提供智能家居的接入服务。这边把我提供的一些推荐插件和地址列在下面

- hacs ha的应用市场索引 https://hacs.xyz/
- xiaomi-home 米家接入 https://github.com/XiaoMi/ha_xiaomi_home

## 安装米家接入

前往https://github.com/XiaoMi/ha_xiaomi_home 中的release中，下载最新的zip插件

点击nas中的文件管理，选择左侧中的应用文件，找到home-assistant文件夹，在里面的config文件夹下新建custom_components文件夹（如果有可以跳过），将下载好的zip插件解压到该文件夹夹。

回到home-assistant界面，点击设置-系统 在右上角点击重启home-assistant服务。

随后可以在设备与服务中，点击添加集成，搜索xiaomi-home就能找到相关插件。按照提示一步步绑定小米账号登内容。

注意：如果没有在前面配置DNS域名，这一步会跳转回homeassistant.local域名，提示找不到服务，需要手动将homeassistant.local前缀修改为服务地址。


## hacs 应用市场

https://hacs.xyz/docs 官方文档

**在线安装**

进入容器,执行相关在线安装脚本
```bash 
docker exec -it <name of the container running homeassistant> bash
wget -O - https://get.hacs.xyz | bash -
```



此操作需要访问github,如果你很不幸不能访问(dddd),就只能手动安装了

**手动安装**
https://github.com/hacs/integration/releases/ 前往这个界面下载最新的插件安装包

安装方式同上,放置于 config/custom_components 文件夹下,然后重启服务,就能在设备与服务，添加集成中看到hacs服务. 然后根据提示绑定相关账户,这块也要访问Github账户

![](https://pic.liahnu.top/img/202505260123795.png)

安装完成后就能在界面看到相关的插件了
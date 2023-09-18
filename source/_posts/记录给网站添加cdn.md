---
title: 记录给网站添加cdn
date: 2023-02-12 14:48:57
tags: [运维，CDN]
mermaid: true
---
# cdn介绍

内容分发网络（Content Delivery Network，简称 CDN）是利用最靠近每一位用户的服务器，更快、更可靠地将文件发送给用户分发网络。

总而言之，cdn可以加速不同地区的用户的访问，同时将网站中的静态资源缓存，以此减轻服务器的负担。

{% mermaid %}
graph LR;
USER1[用户1] -->|访问|CDN[CDN]
USER2[用户2] -->|访问|CDN
CDN -->|转发| D[源站]
{% endmermaid %}

# 服务器配置CDN
这里以腾讯云的为例
## 前往云服务器cdn管理器
在云中控制台中选择 **内容分发网络 CDN 控制台** ，购买或者领取相应的资源包

选择添加域名

![](https://gitee.com/liahnu/img/raw/master/202302112151151.png)


![](https://gitee.com/liahnu/img/raw/master/202302112151459.png)

加速区域选择中国境内，加速域名填写你需要加速的服务器。注意，在加速域名中，*.example.com和example.com是不同的，用户仅访问example.com有加速效果，若访问www.example.com或m.example.com没有加速效果，需要单独填写接入CDN加速后生效。

这里可能会需要验证域名的信息，这需要在域名DNS面板中的域名配置中添加参数的记录，然后点击验证
![](https://gitee.com/liahnu/img/raw/master/202302112200648.png)

类型选择网页小文件

### 源站配置
源站类型中，选择自有源，因为我的服务器中配置了https证书，所以选择https协议，源站地址填写你的服务器地址。

填写完成后，保存

## 设置缓存文件信息

![](https://gitee.com/liahnu/img/raw/master/202302112158598.png)

这里默认给了配置，如果没有什么需求，默认就可以

提交配置后，需要在域名的DNS管理面板中添加CNAME转发的参数

![](https://gitee.com/liahnu/img/raw/master/202302112201184.png)

在DNS配置中，添加记录雷系为CNAME的记录，主机记录是转发的三级域名名称，其中CNAME可以代替原先DNS指向源站的A类记录，记录值为是cdn面板中的主机记录。

![](https://gitee.com/liahnu/img/raw/master/202302112202269.png)

## 完成

配置完成后，等待3-5分钟，就可以在cdn面板中看到配置状态。可以使用站长工具中的ping工具，检测ping地址中是否有有cdn地址，若有，也可以说明配置成功。

![](https://gitee.com/liahnu/img/raw/master/202302112205576.png)



# 回源相关

## 回源是什么
cdn向后段源服务器请求资源并缓存，这个请求过程是周期性的，自动的，称为回源。 

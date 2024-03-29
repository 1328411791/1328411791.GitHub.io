---
layout: p
title: 记录一次处理kswapd0挖矿病毒
date: 2024-02-20 02:39:19
tags: [运维,挖矿病毒]
---

# 前言

睡觉起床发现阿里云给我发短信，提醒中病毒，然后登录服务器发现CPU占用率100%，查看进程发现kswapd0占用CPU，然后查看日志发现有存在的挖矿病毒。

处理步骤参考了这篇文章

[https://blog.csdn.net/qq_47831505/article/details/123939089](https://blog.csdn.net/qq_47831505/article/details/123939089)

[参考二](https://developer.aliyun.com/article/1252878?spm=a2c6h.14164896.0.0.65f347c5hwPYQR&scm=20140722.S_community@@%E6%96%87%E7%AB%A0@@1252878._.ID_1252878-RL_kswapd0%E8%BF%9B%E7%A8%8B%E5%AF%B9%E4%BA%8ECPU%E5%8D%A0%E6%9C%89%E7%8E%87%E9%AB%98%E7%9A%84%E6%83%85%E5%86%B5%E4%B8%8B%E6%8E%92%E6%9F%A5%E5%88%B0%E9%BB%91%E5%AE%A2%E6%A4%8D%E5%85%A5%E8%84%9A%E6%9C%AC-LOC_search~UND~community~UND~item-OR_ser-V_3-P0_0)

[参考三](https://developer.aliyun.com/article/1252879?spm=a2c6h.14164896.0.0.65f347c5hwPYQR&scm=20140722.S_community@@%E6%96%87%E7%AB%A0@@1252879._.ID_1252879-RL_kswapd0%E8%BF%9B%E7%A8%8B%E5%AF%B9%E4%BA%8ECPU%E5%8D%A0%E6%9C%89%E7%8E%87%E9%AB%98%E7%9A%84%E6%83%85%E5%86%B5%E4%B8%8B%E6%8E%92%E6%9F%A5%E5%88%B0%E9%BB%91%E5%AE%A2%E6%A4%8D%E5%85%A5%E8%84%9A%E6%9C%AC-LOC_search~UND~community~UND~item-OR_ser-V_3-P0_1)

# 处理步骤

打开阿里云的安全日记，可以看到具体的病毒文件路径，首先是查询了相关的信息，发现是个挖矿病毒。

![](https://pic.liahnu.top/img/202402200253489.png)

首先是用top命令查看CPU占用率最高的进程发现是kswapd0，先手动kill掉进程，基本可以确认是挖矿病毒。

![](https://pic.liahnu.top/img/202402200245127.png)

![](https://pic.liahnu.top/img/202402200248498.png)

打开对应的文件空间处理掉病毒文件

```shell
rm -rf ./.configrc5/
```

打开cron处理掉定时任务

![](https://pic.liahnu.top/img/202402200303946.png)

```shell
crontab -e -u root
```
**原文中仅仅删除cron文件是不够的，还需要处理rsync同步**

**注意** 这里的定时任务中最后有一个rsync命令，这个命令是用来同步文件的，但是这个命令是用来同步病毒文件的，因此在单纯删除文件后还会出发同步病毒，所以要删除掉对应的同步配置。

不然就会出现下面这个情况，一周后病毒会通过rsync命令同步回来，再次感染。
![](https://pic.liahnu.top/img/202402200305359.png)

同时，单纯的删除/tmp目录下的文件是不够的，因为病毒会自动在/tmp目录下重新生成文件，所以需要删除掉对应的同步任务。

**sync感染的cron文件**
![](https://pic.liahnu.top/img/202402200306127.png)

打开cron文件中的最后一行的隐藏文件，删除掉对应的rsync配置

进入ssh秘钥文件中，删除掉所有秘钥（确保安全）
    
```shell
cd /root/.ssh
rm -rf *
```

同时，kill掉启动的Sync进程，防止病毒再次通过Sync感染


## 事故产生的原因

个人分析是因为服务器的密码太简单，百分百在字典中，容易被黑客破解，然后上传了挖矿病毒。经过这次处理改用秘钥登录，同时密码设置为复杂密码，防止被爆破。
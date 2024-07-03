---
layout: p
title: 拯救安卓11中的System分区
date: 2024-05-06 22:48:06
tags: [搞机, 安卓, 系统]
---


# 前言

前段时间，打算给我的小米9刷一个澎湃的系统，但是在刷机的时候，发现了一个问题，就是在小米9中安卓11中的System分区容量不足，需要手动扩容。但是经过我的错误扩容操作后经过出现一点小失误，导致手机无法开机，只能进入fastboot模式。线刷系统过后进入系统提示System被破坏，这篇文章就是记录我是如何拯救安卓11中的System分区的（不想交钱9008）。


# 准备工作

1. 一台电脑（fastboot工具，recovery工具）
2. 一根数据线
3. 手机
4. 官方卡刷包线刷包

# 步骤

通过线刷recovey的方式，进入recovery模式，查看log，发现提示无法加载system-root分区。同时，使用fastboot flash命令无法将线刷包中的system.img刷入system分区。提示分区不存在，出现了异常操作，怀疑是System分区因为扩容或其他原因丢失。

在摸索的过程中，期初一直在`/dev/block/sda`目录下查找system分区，但是始终发现没有找到system分区。以为是安卓10后的动态System分区机制导致无法读取，后来在`/dev/block/sde`（将闪存分为了不同的磁盘）下找到了vender分区，同时看块号和分区id提示，缺少一个3.6G左右的分区，该分区应该就是缺失system分区。

在查阅系统的硬件时候发现，sda存储的是userdata数据，sde存储的是vender、system分区存储的是系统数据，sdf存储的是数据数据。本来以为在安卓10后，System分区修改为一个动态分区，在正常的dd中无法显示。后来才发现，system分区不存储在sda中，而是存储在sde中。

同样的，线刷包中存在gpt_main0.bin~gpt_main4.bin（5个块），gpt_backup0.bin~gpt_backup5.bin（4个块），其中gpt_main0.bin存储的是userdata分区表，gpt_main4.bin存储的是system分区和vender分区表，gpt_main5.bin存储的基带分区的分区表。通过dd命令将gpt_main4.bin和gpt_backup4.bin刷入sde中的头块和尾块，重启即可修复sde中的分区表。（注意分区表的分区名称和分区大小是否与原始对应）

参考命令，注意块的大小和位移
```shell
dd if=gpt_main4.bin of=/dev/block/sde bs=4096 seek=0 count=6
dd if=gpt_backup4.bin of=/dev/block/sde bs=4096 seek=0 count=5
```

重启后进recovey模式，发现system分区已经恢复，重新卡刷线刷rom即可。
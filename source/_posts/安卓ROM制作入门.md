---
layout: p
title: 安卓ROM制作入门
date: 2024-09-08 00:12:30
tags: [安卓,操作系统]
---

# 前言

    由于小米手机在rom制作圈中的地位，本文以小米手机为例，介绍安卓ROM制作的基本流程。

# 认识刷机包文件

在制作入门前，首先先来拆解一个刷机包文件，了解一下其中内部的结构。

现在的刷机包主要分为两类：
- 线刷包: 使用fastboot工具刷入
- 卡刷包: 使用recovery工具刷入
- 9008包: 使用9008工具刷入

但实际上，这三种包只是刷入方式和格式的区别，其内部结构是一样的。刷机包的本质是将打包好的img镜像，通过某种方式，刷入到手机指定的分区中。

下面来具体分析几个包文件的结构：

## miui_FUXI_OS1.0.8.0.UMCCNXM_14.0_240326_ENC 

    小米13的线刷卡刷合一包，作者为酷安的@白羊

**解压后的文件结构如下：** 已经删除了一些不必要的文件
```
│  刷机脚本.bat
│
├─bin
│  ├─android
│  │      busybox
│  │      zstd
│  │
│  ├─platform-tools-darwin
│  │  │  adb
│  │  │  dmtracedump
│  │  │  e2fsdroid
│  │  │  etc1tool
│  │  │  fastboot
│  │  │  hprof-conv
│  │  │  make_f2fs
│  │  │  make_f2fs_casefold
│  │  │  mke2fs
│  │  │  mke2fs.conf
│  │  │  NOTICE.txt
│  │  │  sload_f2fs
│  │  │  source.properties
│  │  │  sqlite3
│  │  │
│  │  └─lib64
│  │          libc++.dylib
│  │
│  ├─platform-tools-linux
│  │  │  adb
│  │  │  dmtracedump
│  │  │  e2fsdroid
│  │  │  etc1tool
│  │  │  fastboot
│  │  │  hprof-conv
│  │  │  make_f2fs
│  │  │  make_f2fs_casefold
│  │  │  mke2fs
│  │  │  mke2fs.conf
│  │  │  NOTICE.txt
│  │  │  sload_f2fs
│  │  │  source.properties
│  │  │  sqlite3
│  │  │
│  │  └─lib64
│  │          libc++.so
│  │
│  └─platform-tools-windows
│          adb.exe
│          AdbWinApi.dll
│          AdbWinUsbApi.dll
│          awk.exe
│          busybox.exe
│          cho.exe
│          curl.exe
│          cut.exe
│          dmtracedump.exe
│          etc1tool.exe
│          fastboot.exe
│          FstabQF.exe
│          hprof-conv.exe
│          libwinpthread-1.dll
│          make_f2fs.exe
│          make_f2fs_casefold.exe
│          mke2fs.conf
│          mke2fs.exe
│          NOTICE.txt
│          source.properties
│          sqlite3.exe
│          zstd.exe
│
├─images
│      abl.img
│      aop.img
│      aop_config.img
│      bluetooth.img
│      boot.img
│      boot_kernelsu.img
│      cpucp.img
│      cust.img
│      devcfg.img
│      dsp.img
│      dtbo.img
│      featenabler.img
│      hyp.img
│      imagefv.img
│      init_boot.img
│      init_boot_kernelsu.img
│      init_boot_magisk.img
│      keymaster.img
│      modem.img
│      multiimgqti.img
│      qupfw.img
│      recovery.img
│      recovery_twrp.img
│      shrm.img
│      super.img
│      tz.img
│      uefi.img
│      uefisecapp.img
│      vbmeta.img
│      vbmeta_system.img
│      vendor_boot.img
│      vendor_boot_less.img
│      xbl.img
│      xbl_config.img
│      xbl_ramdump.img
│
└─META-INF
    └─com
        ├─android
        │      metadata
        │      metadata.pb
        │      otacert
        │
        └─google
            └─android
                    update-binary
```

下面来解释一下文件夹中的文件的作用：

- bin.android: 里面存放了一些常用工具，在刷机包中放置了busybox和zstd

{% note success %}
- busybox: 一个类似于linux的工具集，可以在android中执行一些linux命令，如ls, cp等
- zstd: 一个压缩工具，用于解压缩刷机包中的压缩文件
{% endnote %}

- bin.platform-tools-darwin: 里面存放了一些macOS下的工具与依赖库
- bin.platform-tools-linux: 里面存放了一些linux下的工具与依赖库
- bin.platform-tools-windows: 里面存放了一些windows下的工具与依赖库

这部分主要是用在刷机脚本中，用于多平台的兼容。

{% note success %}
- adb: android调试桥，用于和手机进行通信
- fastboot: 一个刷机工具，用于刷入img文件
{% endnote %}

- images: 里面存放了一些img分区镜像文件，这些文件是刷机包的核心，是要刷入到手机的分区中的文件

## image 分区文件解析



{% note primary %}

这些镜像文件是刷机包的核心，是要刷入到手机的分区中的文件，每个文件对应一个分区，刷机包的制作就是将这些文件打包成一个刷机包文件。

{% endnote %}



---
title: 校园内vpn模拟登录
date: 2023-04-23 00:35:03
tags: [协议分析]
---

# 前言

使用学校webvpn时候，访问内网地址被加密为一串字符串，

例如：https://webvpn.gdou.edu.cn/http/77726476706e69737468656265737421a1a70fce77602606305adcf9/


# 加密流程

通过前端js代码，可以很清楚的找到加密函数

```js
var textRightAppend = function (text, mode) {
    var segmentByteSize = mode === 'utf8' ? 16 : 32

    if (text.length % segmentByteSize === 0) {
        return text
    }

    var appendLength = segmentByteSize - text.length % segmentByteSize
    var i = 0
    while (i++ < appendLength) {
        text += '0'
    }
    return text
}

var encrypt = function (text, key, iv) {
    var textLength = text.length
    text = textRightAppend(text, 'utf8')
    var keyBytes = utf8.toBytes(key)
    var ivBytes = utf8.toBytes(iv)
    var textBytes = utf8.toBytes(text)
    var aesCfb = new AesCfb(keyBytes, ivBytes, 16)
    var encryptBytes = aesCfb.encrypt(textBytes)
    return hex.fromBytes(ivBytes) + hex.fromBytes(encryptBytes).slice(0, textLength * 2)
}
```

其中 key = "wrdvpnisthebest!" iv = "wrdvpnisthebest!" 默认参数

加密方式根据函数猜测为Aes加密，模式为cfb方式
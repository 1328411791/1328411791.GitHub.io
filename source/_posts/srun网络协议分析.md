---
title: srun网络协议分析
date: 2023-03-08 20:30:16
tags: [网络分析]
---

# 前言

校园网最近更新，登录方式改用深澜网络协议进行登录。本文根据登录时数据包，对深澜网络协议进行分析。

# 请求分析

## 获取api请求

使用抓包软件对srun协议登录请求进行抓包

登录操作时候主要使用了以下几个请求

`
GET /cgi-bin/get_challenge?callback=jQuery1124038630846526307305_1678337618278&username=2021440113**&ip=10.202.47.26&_=1678337618280 
`

![](https://pic.liahnu.top/img/202303091302292.png)

`
GET /cgi-bin/srun_portal?callback=jQuery1124038630846526307305_1678337618278&action=login&username=2021440113**&password=%7BMD5%7D01d38ef19265ae9ff199cbafc98e6797&os=Windows+95&name=Windows&double_stack=0&
chksum=ffbaed27a7cbf48bcf7c227beae802def6f96901&info=%7BSRBX1%7DQJl6uFy9IkM3%2FI3HaaNP%2FgPkfZWn%2FLUH3ktAZuPhtrF%2BailDbmoRB7oaw4jfeE%2FKR9hTkSoyJ5de6TXw6IpyX8VGiLpiWy6MLBEfu4RdCyg2WSim%2FmIssMlh9cfzJygmNCSiFDNbWiE6uBnn&ac_id=1&ip=10.202.47.26&n=200&type=1&_=1678337618281 
`

![](https://pic.liahnu.top/img/202303091534989.png)

下面具体根据两个请求进行分析

## get_challenge 请求

根据请求，我们可以初步猜测出这个的参数

|  参数   | 示例值  | 注释 | 
|  :----:  | :----:  | :----: |
| callback | jQuery1124038630846526307305_1678337618278 | 应该是jquery的回调函数标志，可能由函数id+时间戳组成 |
| username | 2021440113** | 登录用户名 |
| ip | 10.202.47.26 | 登录网站源站ip |
| _ | 1678337618280 | 很明显是当前的时间戳 |

## srun_portal 请求

同样根据请求，我们可以初步猜测出这个请求的参数详情

|  参数   | 示例值  | 注释 |  
|  :----:  | :----:  | :----: |
| callback | jQuery1124038630846526307305_1678337618278 | 应该是jquery的回调函数标志，可能由函数id+时间戳组成 |
| password | {MD5}01d38ef19265ae9ff199cbafc98e6797 | 经过md5加密后的密码，但似乎不同于常规md5加密方法 |
| os | Windows+95 | 系统 |
| name | Windows | 同上，系统参数 |
| double_stack | 0 | 多次抓包后似乎是固定值 |
| chksum | ffbaed27a7cbf48bcf7c227beae802def6f96901 | 某种加密后的参数 |
| info | {SRBX1}QJl6uFy9IkM3%2FI3HaaNP%2FgPkfZWn%2FLUH3ktAZuPht rF%2BailDbmoRB7oaw4jfeE%2FKR9hTkSoyJ5de6TXw6Ipy X8VGiLpiWy6MLBEfu4RdCyg2WSim%2FmIssMlh9cfzJygmN CSiFDNbWiE6uBnn | 又是一段加密后的参数 |
| ac_id | 118 | 固定值，可能是加密方式，错误的ac_id可能会导致bas错误 |
| n | 200 | 固定值 |
| type | 1 | 固定值 |
| _ | 1678337618280 | 很明显是当前的时间戳 |

根据上面的基础分析，初步可以知道我们需要研究参数为 password，chksum，info字段


## js分析

根据上面的基础分析，在js的代码中寻找关键的代码信息

以下是寻找的相关代码(省略部分细节)
``` js
$('#login-account').click(function () {
        var username = $('#username').val().replace(/ /g, '');
        var password = $('#password').val();
        // 若页面不存在 domain，则 domain 为空
        var domain   = $('#domain').val();

        // 写入用户信息
        portal.userInfo.username = username;
        portal.userInfo.password = password;
        portal.userInfo.domain   = domain || '';

        // Portal 认证方法
        portal.login({
            // 认证方式为账号认证
            type: 'account',
            // 认证成功
            success: function () {
                // 若勾选记住密码
                if ($('#remember').prop('checked'))  portal.remember(true);
                // 若未勾选记住密码 或 不存在记住密码功能
                if (!$('#remember').prop('checked')) portal.remember(false);
                // 重定向至成功页
                portal.toSuccess();
            }
        });
    });
```
登录调用了portal.login() 方法
```js
{
    key: "login",
    value: function login() {
      var obj = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : {};
      this.setLog('正在进行登陆操作'); // 默认进行拦截
      this.loading.login = true; // 账号认证

      if (obj.type === 'account') _classPrivateFieldGet(this, _loginAccount).call(this, obj); // 短信认证 - 手机短信
    }
  }
```
接着调用了 this._loginAccount()方法
```js
var sendAuth = function sendAuth(host) {
          // 双栈认证时 IP 参数为空
          var ip = _this.portalInfo.doub && host ? '' : _this.userInfo.ip; // 获取 Token

          _classPrivateFieldGet(_assertThisInitialized(_this), _getToken).call(_assertThisInitialized(_this), host, ip, function (token) {
            // 用户密码 MD5 加密
            var hmd5 = md5(password, token); // 用户信息加密

            var i = _classPrivateFieldGet(_assertThisInitialized(_this), _encodeUserInfo).call(_assertThisInitialized(_this), {
              username: username,
              password: password,
              ip: ip,
              acid: ac_id,
              enc_ver: enc
            }, token);

            var str = token + username;
            str += token + hmd5;
            str += token + ac_id;
            str += token + ip;
            str += token + n;
            str += token + type;
            str += token + i; // 防止 IPv6 请求网络不通进行 try catch

            try {
              // 发起认证请求
              _this.ajax.jsonp({
                host: host,
                url: _classPrivateFieldGet(_assertThisInitialized(_this), _api).auth,
                params: {
                  action: 'login',
                  username: username,
                  password: _this.userInfo.otp ? '{OTP}' + password : '{MD5}' + hmd5,
                  os: _this.portalInfo.userDevice.device,
                  name: _this.portalInfo.userDevice.platform,
                  // 未开启双栈认证，参数为 0
                  // 开启双栈认证，向 Portal 当前页面 IP 认证时，参数为 1
                  // 开启双栈认证，向 Portal 另外一种 IP 认证时，参数为 0
                  double_stack: _this.portalInfo.doub && !host ? 1 : 0,
                  chksum: sha1(str),
                  info: i,
                  ac_id: ac_id,
                  ip: ip,
                  n: n,
                  type: type
                },
                success: function success(res) {
                  finishReq += 1; // IP 已经在线了 - 给出提示

                  if (res.suc_msg === 'ip_already_online_error' && obj.error) return _this.confirm({
                    message: _this.translate('ip_already_online_error'),
                    confirm: function confirm() {
                      if (obj.error) obj.error();
                    }
                  }); // 翻译后的认证成功信息

                  successMsg = _this.translate(res);
                },
                /* 常见错误代码 */
                error: function error(res) {
                  finishReq += 1; // 更改登录状态为结束

                  _this.loading.login = false; // 若所有请求均已完成

                  if (noPending()) authClose(); // 若 ecode 为 E2620 且开启了在线设备管理功能
                  // E2620: 超出允许的在线数目

                  if (res.ecode === 'E2620' && CREATER.useOnlineDeviceMgr) return _this.confirm({
                    message: _this.translate('E2620Tips'),
                    confirm: function confirm() {
                      _this.dialog.open('onlineDeviceMgr', function () {
                        _this.getOnlineDevice();
                      });
                    }
                  }); // IP 已经在线了 - 重新认证

                  if (res.error_msg === 'ip_already_online_error') return _this.reAuth(obj); // 需要查询日志的情况

                  if (res.error_msg === 'not_online_error') return _this.showLog();
                  if (res.error_msg === 'no_response_data_error') return _this.showLog();
                  if (res.error_msg === 'RD000') return _this.showLog(); // 若提示修改密码

                  if (res.error_msg === 'user_must_modify_password' || res.error === 'user_must_modify_password') return _this.confirm({
                    message: _this.translate(res),
                    confirmText: _this.translate('ToChangePassword'),
                    confirm: function confirm() {
                      return $('#forget').click();
                    },
                    cancel: function cancel() {}
                  }); // 错误提示

                  _this.confirm({
                    message: _this.translate(res),
                    confirm: function confirm() {
                      if (obj.error) obj.error(res);
                    }
                  });
                }
              });
            } catch (err) {
              finishReq += 1; // 更改登录状态为结束

              _this.loading.login = false; // 若所有请求均已完成

              if (noPending()) authClose(); // 因为 IPv6 网络问题导致的认证失败

              console.err('Network error', err);
            }
          });
        };
```
发现这边多了个token参数，经过与请求对比发现，token参数是get_challenge请求中的challenge参数

获取到token参数过后，将password和token进行md5加密（应该是使用了hmac算法），得到加密后的md5值
参考实现代码

```java
public static void main(String[] args) throws IOException {

    String token="9175d2a16f2339e60d5e1b4be4df16b1660f79d57009e7adf4422488a2a0439a";
    String password="1234567890";

    HMac hmac = new HMac(HmacAlgorithm.HmacMD5, token.getBytes());
    byte[] result = hmac.digest(password.getBytes());

    String s = HexUtil.encodeHexStr(result);
    System.out.println(s);
}

```
组合str
```js
var str = token + username;
str += token + hmd5;
str += token + ac_id;
str += token + ip;
str += token + n;
str += token + type;
str += token + i;
```

chksum是通过使用sha1(str)方法进行加密,str是它通过之前各个参数的拼接完成。sha1根据函数名可以猜测为sha1加密方法。

根据以上方法，我们就可以获得基础登录加密方法组装。

# 登录实践

这里提供一个已经写好的srun登录软件

[srun](https://github.com/zu1k/srun))

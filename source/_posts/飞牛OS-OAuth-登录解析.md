---
layout: p
title: 飞牛OS OAuth 登录解析
date: 2026-01-05 17:56:07
mermaid: true
tags: [NAS]
---

# 前言

众所周知，飞牛OS提供了一套系统搭建的OAuth服务，但是这套服务并不对外开放

# 登录处理流程

以飞牛影视处理

## OAuth协议处理

OAuth 2.0是一种授权框架，允许第三方应用程序在不获取用户凭证的情况下访问用户资源。以下是详细的处理流程：
```mermaid
sequenceDiagram
    participant Client as 第三方客户端应用
    participant User as 资源所有者（用户）
    participant AuthServer as 授权服务器
    participant ResourceServer as 资源服务器

    Client->>User: 展示登录界面，提示用户点击登录
    User->>Client: 点击登录按钮
    Client->>User: 重定向到授权服务器
    User->>AuthServer: 访问授权URL
    Note over AuthServer: /oauth/authorize?client_id=CLIENT_ID&redirect_uri=REDIRECT_URI&scope=profile&response_type=code
    AuthServer->>User: 显示登录页面
    User->>AuthServer: 输入用户名密码，完成认证
    AuthServer->>User: 显示授权确认页面，列出请求的权限
    User->>AuthServer: 确认授权
    AuthServer->>User: 重定向到客户端指定的URI
    User->>Client: 携带授权码访问重定向URI
    Note over Client: REDIRECT_URI?code=AUTHORIZATION_CODE
    Client->>AuthServer: 后端请求访问令牌
    Note over Client: POST /oauth/token参数：client_id, client_secret, code, grant_type=authorization_code, redirect_uri
    AuthServer->>Client: 返回访问令牌和刷新令牌
    Note over AuthServer: {  "access_token": "ACCESS_TOKEN",  "token_type": "Bearer",  "expires_in": 3600,  "refresh_token": "REFRESH_TOKEN"}
    Client->>ResourceServer: 使用访问令牌请求资源
    Note over Client: GET /api/user/profileHeaders: Authorization: Bearer ACCESS_TOKEN
    ResourceServer->>Client: 验证令牌并返回资源
    Note over ResourceServer: {  "id": "user123",  "name": "用户名",  "email": "user@example.com"}
    Client->>User: 显示用户信息，完成登录
```

## 飞牛的处理流程

### 1.点击NAS登录，跳转到登录页面
   
 URI: /signin?client_id=U1G8OGDF3Y&redirect_uri=http%3A%2F%2Fddns.liahnu.top%3A5666%2Fv%2Foauth%2Fresult 
 redirect_uri 是客户端指定的回调URI，用于接收授权码, 此处的回调地址为http://ddns.liahnu.top:5666/v/oauth/result 
 client_id 是客户端注册时获得的ID，用于标识客户端应用


### 2.用户在登录页面输入用户名密码，完成认证


登录后，请求该地址获取授权码
http://ddns.liahnu.top:5666/oauthapi/authorize

获取存储的token和userName
如果存在token，自动触发登录流程

**入参**
此处登录有两种方式，token和密码登录
token登录
```json
{
    "client_id":"U1G8OGDF3Y",
    "redirect_uri":"http://ddns.liahnu.top:5666/v/oauth/result",
    "response_type":"code",
    "state":"",
    "token":"token"
}
```



**出参**
```json
{"code":0,"msg":"success","data":{"redirect_uri":"http://ddns.liahnu.top:5666/v/oauth/result","code":"0wR117VN4Q"}}
```


### 3. 登录成功，重定向到回调地址
http://ddns.liahnu.top:5666/v/oauth/result?code=230pV9s-5w&state=undefined

带上了授权码code=230pV9s-5w 和状态码state=undefined

### 4. 客户端应用使用授权码请求访问令牌

http://ddns.liahnu.top:5666/v/api/v1/auth

POST /v/api/v1/auth 
**入参**
```json
{"source":"Trim-NAS","code":"wspXKEd05A"}
```

**成功回调**
```json
{"msg":"","code":0,"data":{"token":"4110c478503e46c4838ed69c0be79a8a"}}
```

从这换到了token参数，并把这个参数存储到cookie中，
Trim-MC-token：4110c478503e46c4838ed69c0be79a8a





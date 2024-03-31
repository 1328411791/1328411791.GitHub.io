---
layout: p
title: Redission中RateLimiter相关的使用
date: 2024-03-31 21:53:46
tags: [Java,Redis]
---


# Redission中RateLimiter相关的使用

## RateLimiter对象介绍

RateLimiter是一个限流器，可以用来限制某个操作的频率，比如限制某个接口的访问频率。RateLimiter是基于令牌桶算法实现的，它可以控制每秒的访问次数，可以设置每秒的访问次数，也可以设置每秒的访问次数和每次请求的令牌数。

```java
String redisKey = "rateLimiter";
RRateLimiter rateLimiter = redisson.getRateLimiter(redisKey);
```
定义一个Key去生成RateLimiter对象,RateLimiter对象是通过RedissonClient对象获取的，通过getRateLimiter方法获取，getRateLimiter方法有一个参数，是Key，用来生成RateLimiter对象。

关于如何限制速率。如果你希望限制特定用户的请求速率，那么可以使用用户的IP地址作为key。如果你希望限制特定方法的调用速率，那么可以使用方法名作为key。

``` java
// 设置限流策略
rateLimiter.trySetRate(annotation.rateType(), annotation.count(), annotation.period(), annotation.rateTimeUnit());
``` 

trySetRate方法用来设置限流策略，其中有四个参数：

- rateType是限流类型，有两种类型：OVERALL和PER_CLIENT，OVERALL表示OVERALL表示所有RateLimiter实例的总速率，PER_CLIENT表示是指在使用同一Redisson实例的所有RateLimiter实例的总速率
- rate是每次生成的令牌数，表示在指定的时间间隔内允许的操作次数。
- period是时间间隔，定义指定的时间间隔内允许的操作次数
- rateTimeUnit是时间单位，是生成令牌间隔时间的单位，可以是秒、分、时等

```java

// 获取令牌
boolean tryAcquire = rateLimiter.tryAcquire(permits, timeout, TimeUnit);
```

tryAcquire方法用来获取令牌，其中有三个参数：
- permits是请求的令牌数，也就是请求消耗的令牌数
- timeout是超时时间
- TimeUnit是时间单位

意思是在timeout时间内获取permits个令牌，当获取的数量可用的时候，才会获取成功。


### 如何理解请求的令牌数和生成的令牌数

- 请求的令牌数是指每次请求消耗的令牌数，比如设置每次请求消耗1个令牌，那么每次请求都会消耗1个令牌
- 生成的令牌数是指每隔多长时间生成一个令牌，比如设置每隔1秒生成1个令牌，那么每秒都会生成1个令牌

例如，设置每秒生成1个令牌，每次请求消耗1个令牌，那么每秒可以请求1次；设置每秒生成1个令牌，每次请求消耗2个令牌，那么每秒可以请求0.5次。


## 限流与AOP切面注解配合

大致在之前的AOP文章中。


# 具体的实现

rateLimiter在初始化后，会在redis中生成三个key，分别是：

- value: {limit:${key}}:value - 限流器的值
- ZSort: {limit:${key}}:permits - 限流器的令牌
- Hash: limit:${key} - 限流器的配置


**限流器的配置**

![](https://pic.liahnu.top/img/202403312224850.png)

- type: 限流类型
- rate: 生成的令牌数
- period: 生成令牌的时间间隔,这里的单位应该是毫秒

**限流器的令牌**

![](https://pic.liahnu.top/img/202403312231905.png)
- value: 一串生成的标准符
- score: 最近一次生成令牌的时间戳

**限流器的值**

- value: 存储着目前可用的令牌数


## 大致的流程

1. 初始化
2. 定义限流器
3. 尝试获取令牌





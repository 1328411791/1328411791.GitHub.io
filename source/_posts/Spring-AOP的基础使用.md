---
layout: p
title: Spring AOP的基础使用
date: 2024-01-17 18:17:36
tags: [Java]
---
# 基础简介

AOP，全称Aspect Oriented Programming，中文是“面向切面编程”，
是一种可以在不修改原来的核心代码的情况下给程序动态统一进行增强的一种技术。

SpringAOP: 批量对Spring容器中bean的方法做增强，并且这种增强不会与原来方法中的代码耦合

AOP最基本的运用是将原有的函数与附加函数进行解耦合操作，使其能够对原有代码进行增强；

# 简单使用

## Spring AOP 安装

```
<!-- 引入aop支持 -->
<dependency>
   <groupId>org.springframework.boot</groupId>
   <artifactId>spring-boot-starter-aop</artifactId>
</dependency>
```
## 引入切面组件，并注册为Bean

```java
@Component  
@Aspect  
public class AOPAspect {  

}
```
## 创建切点方法（@Pointcut）
我们需要知道哪些方法需要被增强，因此需要创建一个空方法加上@Pointcut注解来指定切点（也就是指出什么方法需要被增强）

切点主要有三种方式
- 切点表达式：表明应该做切面的方法
- 使用自定义注解：见下文

## 使用切点表达式方式

格式下文
```
execution([可见性]返回类型[声明类型].包名.类名.方法名(参数)[异常])，其中[]内的是可选的
* com.example.demo.service.*.start*()
```
例子中切点标记为 com.example.demo.service 包下所有类 、start开头的方法、无参数 任意返回值 



## 使用自定义注解做驱动

### 定义一个自定义注解

使用注解首先先要定义一个自定义注解

```java
@Retention(RetentionPolicy.RUNTIME)  
@Target(ElementType.METHOD) // 指定在方法上生效  
public @interface Invoke {  

}
```
Retention这个元注解定义了注解的保留策略，即注解在什么级别有效。它有三个参数：
- RetentionPolicy.SOURCE（注解只在源代码中保留，编译时会被忽略），
- RetentionPolicy.CLASS（注解在类文件中保留，但在运行时会被忽略），
- RetentionPolicy.RUNTIME（注解在类文件中保留，且在运行时可以通过反射机制获取）。

Target这个元注解定义了注解可以应用的目标。它的参数包括：
- ElementType.TYPE（可以应用于类、接口或枚举）
- ElementType.FIELD（可以应用于字段）
- ElementType.METHOD（可以应用于方法）

初次之外，常用的元注解还有：
@Documented：这个元注解表明，如果一个类型使用了被@Documented注解的注解，那么这个注解将被包含在JavaDoc中。
@Inherited：这个元注解表明，如果一个超类使用了被@Inherited注解的注解，那么它的子类将自动继承这个注解。
@Repeatable：这个元注解表明，被@Repeatable注解的注解可以在同一个声明上多次使用。

### 切面设置注解

在切点上指明切点为一个注解即可
```java
@Pointcut("@annotation(org.talang.wabackend.aop.annotation.RateLimiter)")
public void pointcut() {
}
```

### 从反射获取注解

在Spring AOP（面向切面编程）中，ProceedingJoinPoint是JoinPoint的一个子接口，它用于环绕通知（around advice）。

通过ProceedingJoinPoint参数,可以获取到对应注解的方法，从方法反射从而获取到

ProceedingJoinPoint提供了proceed()方法，这个方法就是用来触发目标方法执行的。

```java
public Object around(ProceedingJoinPoint joinPoint) throws Throwable {
    // 获取方法上的注解
    MethodSignature signature = (MethodSignature) joinPoint.getSignature();

    Method method = signature.getMethod();
    // 获取注解
    RateLimiter annotation = method.getAnnotation(RateLimiter.class);

    return joinPoint.proceed();
}
```


### 例子

下面是一个关于AOP关于限流策略相关功能
```java
@Target(ElementType.METHOD)
@Retention(java.lang.annotation.RetentionPolicy.RUNTIME)
public @interface RateLimiter {

    /**
     * 限流的key
     */
    @NotNull
    String key();

    /**
     * 限流的类型
     */
    RateType rateType() default RateType.OVERALL;

    /**
     * 限流的时间
     */
    int count() default 1;

    /**
     * 限流的次数
     */
    int period() default 1;

    /**
     * 限流的单位
     */
    RateIntervalUnit rateTimeUnit() default RateIntervalUnit.SECONDS;

    /**
     * 许可证获取数量
     */
    int permits() default 1;

    /**
     * 许可证获取超时时间
     */
    long timeout() default 3;

    /**
     * 许可证获取超时时间单位
     */
    TimeUnit timeUnit() default TimeUnit.SECONDS;


}
```

```java
@Slf4j
@Aspect
@Component
public class RedisRateLimiterAspect {

    private static final String LIMIT_KEY_PREFIX = "limit:";
    @Resource
    private Redisson redisson;

    @Pointcut("@annotation(org.talang.wabackend.aop.annotation.RateLimiter)")
    public void pointcut() {
    }

    @Around("pointcut()")
    public Object around(ProceedingJoinPoint joinPoint) throws Throwable {

        ServletRequestAttributes requestAttributes = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();

        String ip = requestAttributes.getRequest().getRemoteAddr();
        log.info("进入限流切面,ip:{}", ip);
        // 获取方法上的注解
        MethodSignature signature = (MethodSignature) joinPoint.getSignature();

        Method method = signature.getMethod();

        RateLimiter annotation = method.getAnnotation(RateLimiter.class);


        String key = annotation.key();

        String redisKey = LIMIT_KEY_PREFIX + key;
        RRateLimiter rateLimiter = redisson.getRateLimiter(redisKey);
        // 初始化

        rateLimiter.trySetRate(annotation.rateType(), annotation.count(), annotation.period(), annotation.rateTimeUnit());

        // 尝试获取锁
        boolean tryAcquire = rateLimiter.tryAcquire(annotation.permits(), annotation.timeout(), TimeUnit.SECONDS);
        if (!tryAcquire) {
            log.error("获取锁失败,IP:{},key:{}", ip, key);
            throw new BusinessException(BusinessErrorCode.RATE_LIMITER_ERROR, "获取锁失败,请稍后再试");

        }
        return joinPoint.proceed();
    }
}
```

## 在增强的方法指定通知类型

**通知类型：**即要在被增强函数执行的哪个时候执行（例子里用的是方法执行前执行，其实还有很多）
通知类型有以下几种类型：

- @Before：前置通知,在目标方法执行前执行
- @AfterReturning： 返回后通知，在目标方法执行后执行，如果出现异常不会执行
- @After：后置通知，在目标方法之后执行，无论是否出现异常都会执行
- @AfterThrowing：异常通知，在目标方法抛出异常后执行
- @Around：环绕通知，围绕着目标方法执行


---
layout: p
title: k8s基础知识入门
date: 2024-03-15 01:44:20
tags: [运维]
---

# 前言

k8s是一个开源的容器编排引擎，它可以自动化地部署、扩展和管理容器化的应用程序。k8s是由Google设计并捐赠给Cloud Native Computing Foundation（CNCF）的，它是一个开源的容器编排引擎，它可以自动化地部署、扩展和管理容器化的应用程序。

## Deployment

Deployment 会指挥 Kubernetes 如何创建和更新应用程序的实例。创建 Deployment 后，Kubernetes master 将应用程序实例调度到集群中的各个节点上。

创建应用程序实例后，Kubernetes Deployment 控制器会持续监视这些实例。 如果托管实例的节点关闭或被删除，则 Deployment 控制器会将该实例替换为集群中另一个节点上的实例。 这提供了一种自我修复机制来解决机器故障维护问题。

在没有 Kubernetes 这种编排系统之前，安装脚本通常用于启动应用程序，但它们不允许从机器故障中恢复。通过创建应用程序实例并使它们在节点之间运行， Kubernetes Deployments 提供了一种与众不同的应用程序管理方法。


### 例子
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: wa-backend
  labels:
    app: wa-backend
spec:
  replicas: 1
  selector:
    matchLabels:
      app: wa-backend
  template:
    metadata:
      labels:
        app: wa-backend
    spec:
      containers:
        - name: wa-backend
          image: talangtuandui-docker.pkg.coding.net/wawa/wa-backend/wa-backend:develop
          imagePullPolicy: Always
          ports:
            - containerPort: 5050
      imagePullSecrets:
        - name: coding-docker
```


## Pods

Pod 是 Kubernetes 抽象出来的，表示一组一个或多个应用程序容器（如 Docker），以及这些容器的一些共享资源。这些资源包括:

- 共享存储，当作卷
- 网络，作为唯一的集群 IP 地址
- 有关每个容器如何运行的信息，例如容器镜像版本或要使用的特定端口。

Pod 为特定于应用程序的“逻辑主机”建模，并且可以包含相对紧耦合的不同应用容器。例如，Pod 可能既包含带有 Node.js 应用的容器，也包含另一个不同的容器，用于提供 Node.js 网络服务器要发布的数据。Pod 中的容器共享 IP 地址和端口，**始终位于同一位置并且共同调度**，并在同一工作节点上的共享上下文中运行。

Pod是 Kubernetes 平台上的原子单元。 当我们在 Kubernetes 上创建 Deployment 时，该 Deployment 会在其中创建包含容器的 Pod （而不是直接创建容器）。每个 Pod 都与调度它的工作节点绑定，并保持在那里直到终止（根据重启策略）或删除。 如果工作节点发生故障，则会在集群中的其他可用工作节点上调度相同的 Pod。

### 例子
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: wa-backend
  labels:
    app: wa-backend
spec:
    containers:
        - name: wa-backend
        image: talangtuandui-docker.pkg.coding.net/wawa/wa-backend/wa-backend:develop
        imagePullPolicy: Always
        ports:
            - containerPort: 5050
    imagePullSecrets:
        - name: coding-docker
```


## 工作节点

一个 pod 会运行在 工作节点。工作节点是 Kubernetes 中的参与计算的机器，可以是虚拟机或物理计算机，具体取决于集群。每个工作节点由主节点管理。工作节点可以有多个 pod ，Kubernetes 主节点会自动处理在集群中的工作节点上调度 pod 。 主节点的自动调度考量了每个工作节点上的可用资源。

每个 Kubernetes 工作节点至少运行:

- Kubelet，负责 Kubernetes 主节点和工作节点之间通信的过程; 它管理 Pod 和机器上运行的容器。
- 容器运行时（如 Docker）负责从仓库中提取容器镜像，解压缩容器以及运行应用程序。

## Service

Service是用来协调Pod之间的通信的。Service定义了一组Pod的逻辑集合，并为这些Pod提供一个统一的访问入口。Service可以通过标签选择器来选择Pod，这样就可以将请求转发到这些Pod上。

Service有四种类型：
- ClusterIP：默认类型，Service只能在集群内部访问
- NodePort：Service会在每个Node上开放一个端口，外部可以通过Node的IP和端口访问Service
- LoadBalancer：Service会在云服务商上创建一个负载均衡器，外部可以通过负载均衡器访问Service
- ExternalName：Service会返回一个CNAME记录，这个记录指向Service的外部地址

Service 匹配一组 Pod 是使用 标签(Label)和选择器(Selector), 它们是允许对 Kubernetes 中的对象进行逻辑操作的一种分组原语。标签(Label)是附加在对象上的键/值对，可以以多种方式使用:
- 指定用于开发，测试和生产的对象
- 嵌入版本标签
- 使用 Label 将对象进行分类

![](https://pic.liahnu.top/img/202403150154123.png)
这张图我觉得很清晰反映了前面各个组件之间的关系。其中Service选择了Label为app=A的Pod，然后通过对其中的Pod进行负载均衡。

### 例子
```yaml
apiVersion: v1
kind: Service
metadata:
  name: wa-backend
spec:
    selector:
        app: wa-backend
    ports:
        - protocol: TCP
        port: 80
        targetPort: 5050
    type: NodePort
```

## Ingress
Ingress是Kubernetes中的一种API对象，我认为是更高一层的Service，用于管理对集群中服务的外部访问。Ingress可以提供HTTP和HTTPS路由，允许您根据路径或主机名将请求路由到不同的服务。Ingress控制器通常是一个负载均衡器，它可以在集群外部公开服务。


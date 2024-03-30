---
layout: p
title: 使用ESXi虚拟机安装K8s带GPU的节点
date: 2024-03-15 15:01:34
tags: [运维，k8s]
---

# 前言

# 安装步骤

## 创建虚拟机

这个没啥可说，在虚拟机软件中创建虚拟机即可

注意安装的系统版本，应选择使用与后文中安装脚本相同的系统版本，我这边安装的是Ubuntu 20.04 服务器版本

## 安装k8s

我这边选择的安装工具是KubeSphere，他有完善的功能和图形化界面，可以很方便的对其进行安装。

[官网文档地址](https://kubesphere.io/zh/docs/v3.4/quick-start/all-in-one-on-linux/)
### 安装KubeSphere单节点服务

#### 下载 KubeKey

使用下面的命令安装KubeKey
```
export KKZONE=cn
curl -sfL https://get-kk.kubesphere.io | VERSION=v3.0.13 sh -

```
#### 安装依赖项
运行`./kk create cluster --with-kubernetes v1.22.12 --with-kubesphere v3.4.1`会弹出表格，告诉你缺失什么项目，按照文档安装所需要的缺失项。

```
sudo apt install socat conntrack ebtables ipset 
```

#### 开始安装

```
./kk create cluster --with-kubernetes v1.23.10 --with-kubesphere v3.4.1
```

确保环境变量KKZONE的值为cn，
后面的命令是选择安装的版本,其中kubernetes为1.23 kubesphere为3.4.1

#### 查看安装结果

```
kubectl logs -n kubesphere-system $(kubectl get pod -n kubesphere-system -l 'app in (ks-install, ks-installer)' -o jsonpath='{.items[0].metadata.name}') -f

```
通过这个命令，初始密码会显示在终端中


## 安装NVIDIA显卡驱动

**注意，一定要安装EXSi版本的显卡驱动，否则安装后会死机**



## 安装docker nvidia-docker模块

## 安装Container gpu模块

因为k8s在v1.20后容器由k8s换为container，因此我们需要安装container的gpu模块



## 配置k8s上安装NVIDIA显卡驱动插件

安装完上述插件后，安装gpu显卡插件

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: nvidia-device-plugin-daemonset
  namespace: kube-system
spec:
  selector:
    matchLabels:
      name: nvidia-device-plugin-ds
  updateStrategy:
    type: RollingUpdate
  template:
    metadata:
      labels:
        name: nvidia-device-plugin-ds
    spec:
      tolerations:
      - key: nvidia.com/gpu
        operator: Exists
        effect: NoSchedule
      # Mark this pod as a critical add-on; when enabled, the critical add-on
      # scheduler reserves resources for critical add-on pods so that they can
      # be rescheduled after a failure.
      # See https://kubernetes.io/docs/tasks/administer-cluster/guaranteed-scheduling-critical-addon-pods/
      nodeSelector:
        gpu: "true"
      priorityClassName: "system-node-critical"
      containers:
      - image: nvcr.io/nvidia/k8s-device-plugin:v0.14.3
        name: nvidia-device-plugin-ctr
        env:
          - name: FAIL_ON_INIT_ERROR
            value: "false"
        securityContext:
          allowPrivilegeEscalation: false
          capabilities:
            drop: ["ALL"]
        volumeMounts:
        - name: device-plugin
          mountPath: /var/lib/kubelet/device-plugins
      volumes:
      - name: device-plugin
        hostPath:
          path: /var/lib/kubelet/device-plugins
```


# 安装Harbor容器仓库

使用KubeSphere安装Harbor容器仓库

配置文件参考
``` yaml
expose:
  type: nodePort
  tls:
    # 建议开启https
    enabled: true
    certSource: auto
    auto:
      # 部署节点
      commonName: 10.180.193.11
    secret:
      secretName: ''
      notarySecretName: ''
  ingress:
    hosts:
      core: core.harbor.domain
      notary: notary.harbor.domain
    controller: default
    kubeVersionOverride: ''
    className: ''
    annotations:
      ingress.kubernetes.io/ssl-redirect: 'true'
      ingress.kubernetes.io/proxy-body-size: '0'
      nginx.ingress.kubernetes.io/ssl-redirect: 'true'
      nginx.ingress.kubernetes.io/proxy-body-size: '0'
    notary:
      annotations: {}
      labels: {}
    harbor:
      annotations: {}
      labels: {}
  clusterIP:
    name: harbor
    annotations: {}
    ports:
      httpPort: 80
      httpsPort: 443
      notaryPort: 4443
  nodePort:
    name: harbor
    ports:
      http:
        port: 80
        nodePort: 30002
      https:
        port: 443
        nodePort: 30003
      notary:
        port: 4443
        nodePort: 30004
  loadBalancer:
    name: harbor
    IP: ''
    ports:
      httpPort: 80
      httpsPort: 443
      notaryPort: 4443
    annotations: {}
    sourceRanges: []
# 注意使用https做外部端口
externalURL: 'https://10.180.193.11:30003'
internalTLS:
  enabled: true
  certSource: auto
  trustCa: ''
  core:
    secretName: ''
    crt: ''
    key: ''
  jobservice:
    secretName: ''
    crt: ''
    key: ''
  registry:
    secretName: ''
    crt: ''
    key: ''
  portal:
    secretName: ''
    crt: ''
    key: ''
  chartmuseum:
    secretName: ''
    crt: ''
    key: ''
  trivy:
    secretName: ''
    crt: ''
    key: ''
ipFamily:
  ipv6:
    enabled: true
  ipv4:
    enabled: true
persistence:
  enabled: true
  resourcePolicy: keep
  persistentVolumeClaim:
    # 这里换成使用storageClass配合nfs节点使用
    registry:
      existingClaim: ''
      storageClass: nfs-sc
      subPath: ''
      accessMode: ReadWriteOnce
      size: 5Gi
      annotations: {}
    chartmuseum:
      existingClaim: ''
      storageClass: nfs-sc
      subPath: ''
      accessMode: ReadWriteOnce
      size: 5Gi
      annotations: {}
    jobservice:
      existingClaim: ''
      storageClass: nfs-sc
      subPath: ''
      accessMode: ReadWriteOnce
      size: 1Gi
      annotations: {}
    database:
      existingClaim: ''
      storageClass: nfs-sc
      subPath: ''
      accessMode: ReadWriteOnce
      size: 1Gi
      annotations: {}
    redis:
      existingClaim: ''
      storageClass: nfs-sc
      subPath: ''
      accessMode: ReadWriteOnce
      size: 1Gi
      annotations: {}
    trivy:
      existingClaim: ''
      storageClass: nfs-sc
      subPath: ''
      accessMode: ReadWriteOnce
      size: 5Gi
      annotations: {}
  imageChartStorage:
    disableredirect: false
    type: filesystem
    filesystem:
      rootdirectory: /storage
    azure:
      accountname: accountname
      accountkey: base64encodedaccountkey
      container: containername
    gcs:
      bucket: bucketname
      encodedkey: base64-encoded-json-key-file
    s3:
      region: us-west-1
      bucket: bucketname
    swift:
      authurl: 'https://storage.myprovider.com/v3/auth'
      username: username
      password: password
      container: containername
    oss:
      accesskeyid: accesskeyid
      accesskeysecret: accesskeysecret
      region: regionname
      bucket: bucketname
imagePullPolicy: IfNotPresent
imagePullSecrets: null
updateStrategy:
  type: RollingUpdate
logLevel: info
harborAdminPassword: Harbor12345
caSecretName: ''
secretKey: not-a-secure-key
proxy:
  httpProxy: null
  httpsProxy: null
  noProxy: '127.0.0.1,localhost,.local,.internal'
  components:
    - core
    - jobservice
    - trivy
enableMigrateHelmHook: false
nginx:
  image:
    repository: goharbor/nginx-photon
    tag: v2.5.3
  serviceAccountName: ''
  automountServiceAccountToken: false
  replicas: 1
  revisionHistoryLimit: 10
  nodeSelector: {}
  tolerations: []
  affinity: {}
  podAnnotations: {}
  priorityClassName: null
portal:
  image:
    repository: goharbor/harbor-portal
    tag: v2.5.3
  serviceAccountName: ''
  automountServiceAccountToken: false
  replicas: 1
  revisionHistoryLimit: 10
  nodeSelector: {}
  tolerations: []
  affinity: {}
  podAnnotations: {}
  priorityClassName: null
core:
  image:
    repository: goharbor/harbor-core
    tag: v2.5.3
  serviceAccountName: ''
  automountServiceAccountToken: false
  replicas: 1
  revisionHistoryLimit: 10
  startupProbe:
    enabled: true
    initialDelaySeconds: 10
  nodeSelector: {}
  tolerations: []
  affinity: {}
  podAnnotations: {}
  secret: ''
  secretName: ''
  xsrfKey: ''
  priorityClassName: null
  artifactPullAsyncFlushDuration: null
jobservice:
  image:
    repository: goharbor/harbor-jobservice
    tag: v2.5.3
  replicas: 1
  revisionHistoryLimit: 10
  serviceAccountName: ''
  automountServiceAccountToken: false
  maxJobWorkers: 10
  jobLoggers:
    - file
  loggerSweeperDuration: 14
  nodeSelector: {}
  tolerations: []
  affinity: {}
  podAnnotations: {}
  secret: ''
  priorityClassName: null
registry:
  serviceAccountName: ''
  automountServiceAccountToken: false
  registry:
    image:
      repository: goharbor/registry-photon
      tag: v2.5.3
  controller:
    image:
      repository: goharbor/harbor-registryctl
      tag: v2.5.3
  replicas: 1
  revisionHistoryLimit: 10
  nodeSelector: {}
  tolerations: []
  affinity: {}
  podAnnotations: {}
  priorityClassName: null
  secret: ''
  relativeurls: false
  credentials:
    username: harbor_registry_user
    password: harbor_registry_password
  middleware:
    enabled: false
    type: cloudFront
    cloudFront:
      baseurl: example.cloudfront.net
      keypairid: KEYPAIRID
      duration: 3000s
      ipfilteredby: none
      privateKeySecret: my-secret
  upload_purging:
    enabled: true
    age: 168h
    interval: 24h
    dryrun: false
chartmuseum:
  enabled: true
  serviceAccountName: ''
  automountServiceAccountToken: false
  absoluteUrl: false
  image:
    repository: goharbor/chartmuseum-photon
    tag: v2.5.3
  replicas: 1
  revisionHistoryLimit: 10
  nodeSelector: {}
  tolerations: []
  affinity: {}
  podAnnotations: {}
  priorityClassName: null
  indexLimit: 0
trivy:
  enabled: true
  image:
    repository: goharbor/trivy-adapter-photon
    tag: v2.5.3
  serviceAccountName: ''
  automountServiceAccountToken: false
  replicas: 1
  debugMode: false
  vulnType: 'os,library'
  severity: 'UNKNOWN,LOW,MEDIUM,HIGH,CRITICAL'
  ignoreUnfixed: false
  insecure: false
  gitHubToken: ''
  skipUpdate: false
  offlineScan: false
  timeout: 5m0s
  resources:
    requests:
      cpu: 200m
      memory: 512Mi
    limits:
      cpu: 1
      memory: 1Gi
  nodeSelector: {}
  tolerations: []
  affinity: {}
  podAnnotations: {}
  priorityClassName: null
notary:
  enabled: true
  server:
    serviceAccountName: ''
    automountServiceAccountToken: false
    image:
      repository: goharbor/notary-server-photon
      tag: v2.5.3
    replicas: 1
    nodeSelector: {}
    tolerations: []
    affinity: {}
    podAnnotations: {}
    priorityClassName: null
  signer:
    serviceAccountName: ''
    automountServiceAccountToken: false
    image:
      repository: goharbor/notary-signer-photon
      tag: v2.5.3
    replicas: 1
    nodeSelector: {}
    tolerations: []
    affinity: {}
    podAnnotations: {}
    priorityClassName: null
  secretName: ''
database:
  type: internal
  internal:
    serviceAccountName: ''
    automountServiceAccountToken: false
    image:
      repository: goharbor/harbor-db
      tag: v2.5.3
    password: changeit
    shmSizeLimit: 512Mi
    nodeSelector: {}
    tolerations: []
    affinity: {}
    priorityClassName: null
    initContainer:
      migrator: {}
      permissions: {}
  external:
    host: 192.168.0.1
    port: '5432'
    username: user
    password: password
    coreDatabase: registry
    notaryServerDatabase: notary_server
    notarySignerDatabase: notary_signer
    sslmode: disable
  maxIdleConns: 100
  maxOpenConns: 900
  podAnnotations: {}
redis:
  type: internal
  internal:
    serviceAccountName: ''
    automountServiceAccountToken: false
    image:
      repository: goharbor/redis-photon
      tag: v2.5.3
    nodeSelector: {}
    tolerations: []
    affinity: {}
    priorityClassName: null
  external:
    addr: '192.168.0.2:6379'
    sentinelMasterSet: ''
    coreDatabaseIndex: '0'
    jobserviceDatabaseIndex: '1'
    registryDatabaseIndex: '2'
    chartmuseumDatabaseIndex: '3'
    trivyAdapterIndex: '5'
    password: ''
  podAnnotations: {}
exporter:
  replicas: 1
  revisionHistoryLimit: 10
  podAnnotations: {}
  serviceAccountName: ''
  automountServiceAccountToken: false
  image:
    repository: goharbor/harbor-exporter
    tag: v2.5.3
  nodeSelector: {}
  tolerations: []
  affinity: {}
  cacheDuration: 23
  cacheCleanInterval: 14400
  priorityClassName: null
metrics:
  enabled: false
  core:
    path: /metrics
    port: 8001
  registry:
    path: /metrics
    port: 8001
  jobservice:
    path: /metrics
    port: 8001
  exporter:
    path: /metrics
    port: 8001
  serviceMonitor:
    enabled: false
    additionalLabels: {}
    interval: ''
    metricRelabelings: []
    relabelings: []
trace:
  enabled: false
  provider: jaeger
  sample_rate: 1
  jaeger:
    endpoint: 'http://hostname:14268/api/traces'
  otel:
    endpoint: 'hostname:4318'
    url_path: /v1/traces
    compression: false
    insecure: true
    timeout: 10s
```
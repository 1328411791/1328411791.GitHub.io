---
layout: p
title: 团队中Git使用相关规范
date: 2023-11-26 11:34:05
tags: [Git]
---

# 前言

在看这篇文章前，你需要了解 Git 的基本操作，如果你还不了解，可以查看 [Git 基本操作](https://www.runoob.com/git/git-basic-operations.html)。

对于新人而言，学完 Git 的基本操作后，如何在团队开发中使用 Git 了以及了解相关的规范是非常重要的。

本文主要介绍团队中 Git 使用相关规范，以及开源项目的项目管理规范，包括分支管理、Commit Message 规范、代码 Review 规范等。除此之外，还会介绍一些有关DevOps的内容，以GitHub Action为例子。

一般来说，以下规范作为参考，具体的规范需要根据实际情况来制定。

如果你不想了解规范，只想快速上手提交代码，可以通过目录跳转到第二部分。

# 分支管理

在团队中，分支管理是非常重要的，一个好的分支管理规范可以提高团队的协作效率，降低代码冲突的概率。其中，主要包括分支命名规范、分支合并规范等。

## 分支命名规范

在团队中，分支命名规范是非常重要的，一个好的分支命名规范可以提高团队的协作效率，降低代码冲突的概率。通常，我们会采用以下分支命名规范：

- `master(或main)`：主分支，用于发布稳定版本。
- `develop`：开发分支，用于日常开发。
- `feature/xxx`：功能分支，用于开发新功能。
- `release/xxx`：发布分支，用于发布版本。
- `fix/xxx`：修复分支，用于修复 Bug。
- `hotfix/xxx`：热修复分支，用于紧急修复 Bug。

这些分支命名规范是比较常见的雷系，具体的分支命名规范根据团队的实际情况来制定。一般来说，常见的分支组合有以下几种：

**单master分支**
分支列表：
- master

**单master分支+develop分支**
- master
- develop

**Gitflow 分支规范**
- master
- develop
- feature/xxx (xxx 为功能名称)
- release/xxx (xxx 为版本号)
- hotfix/*

# Commit Message 规范

在团队中，Commit Message 规范是非常重要的，一个好的 Commit Message 规范可以提高团队的协作效率，降低代码维护的难度。通常，我们会采用以下 Commit Message 规范：

**Commit Message 格式：**`<type>(<scope>): <subject>`
- `<type>`：用于说明 commit 的类别，只允许使用下面7个标识。
  - `feat`：新功能（feature）。
  - `fix`：修补 Bug。
  - `docs`：文档（documentation）。
  - `style`： 格式（不影响代码运行的变动）。
  - `refactor`：重构（即不是新增功能，也不是修改 Bug 的代码变动）。
  - `test`：增加测试。
  - `chore`：构建过程或辅助工具的变动。


## 分支合并规范

一般来说，我们会采用以下分支合并规范：
1. `feature` 分支合并到 `develop` 分支。
2. `release` 分支合并到 `master` 分支和 `develop` 分支。
3. `fix` 分支合并到 `master` 分支和 `develop` 分支。
4. `hotfix` 分支合并到 `master` 分支和 `develop` 分支。

在此基础上，配合分支合并的权限设置，可以固定团队中每个人的分支合并权限，避免不必要的代码冲突。

## Pull Request 规范

在团队开发中，例如feature分支开发完成后，必须需要提交Pull Request，由组长等人员进行代码Review后才能合并到develop分支中。

在这个过程中，我们会采用以下Pull Request规范：

1. Pull Request 标题：简洁明了，描述本次提交的主要内容。
2. Pull Request 描述：详细描述本次提交的内容，包括修改的原因、解决的问题等。

提交完成后会进入以下阶段：
1. 代码门禁：必须由代码测试工具进行代码检查，保证代码质量后，合格才能提交。
2. Test Case：必须提供测试用例，通过相关的测试用例后，合格才能提交。
3. Pull Request Review：由组长等人员进行代码Review，Review 通过后，方可合并。

# 快速上手提交代码

下文中使用Idea作为演示工具，GitHub作为演示平台。

## 1. Clone 项目

首先，我们需要将项目克隆到本地，可以通过以下命令克隆项目：

```bash
git clone https://github.com/1328411791/Blog_Service.git
```

如果是开源项目，需要在 GitHub 上 Fork 项目，然后用Fork创建的项目克隆到本地。

## 2. 创建分支

![](https://pic.liahnu.top/img/202404262152032.png)

其中规范的分支命名可以参考上文中的分支命名规范，这里作为示例创建为`fix/fix_test`。

## 3. 修改代码

在本地修改代码，勾选提交的文件，然后提交Commit。

![](https://pic.liahnu.top/img/202404262155656.png)

Commit Message 规范可以参考上文中的 Commit Message 规范。

## 4. Push 代码

在提交代码后，我们需要将代码推送到远程仓库

![](https://pic.liahnu.top/img/202404262155814.png)

## 5. 创建 Pull Request

在推送代码后，我们需要创建 Pull Request，等待代码 Review。
![](https://pic.liahnu.top/img/202404262157379.png)

选择要合并的分支，填写标题和描述，然后点击Create Pull Request。

![](https://pic.liahnu.top/img/202404262158485.png)

![](https://pic.liahnu.top/img/202404262158465.png)

## 6. 合并代码

在 Pull Request 通过后，我们可以合并代码。
![](https://pic.liahnu.top/img/202404262159859.png)

后续的流程就是代码合并到主分支，然后发布版本，流水线工作。

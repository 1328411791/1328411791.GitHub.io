---
title: hexo基础指令
date: 2022-11-26 19:41:52
tags: [入门]
---

# 简写指令:

hexo n "我的第一篇文章" 等价于 hexo new "我的第一篇文章" 还等价于 hexo new post "我的第一篇文章"
hexo p 等价于 hexo publish
hexo g 等价于 hexo generate
hexo s等价于 hexo server
hexo d 等价于 hexo deploy
hexo deploy -g 等价于 hexo deploy --generate
hexo generate -d等价于hexo generate --deploy

注: hexo clean 没有 简写, git --version 没有简写

# 指令说明:
hexo server #Hexo 会监视文件变动并自动更新，除修改站点配置文件外,无须重启服务器,直接刷新网页即可生效。
hexo server -s #以静态模式启动
hexo server -p 5000 #更改访问端口 (默认端口为4000，'ctrl + c'关闭server)
hexo server -i IP地址 #自定义 IP
hexo clean #清除缓存 ,网页正常情况下可以忽略此条命令,执行该指令后,会删掉站点根目录下的public文件夹
hexo g #生成静态网页 (执行 $ hexo g后会在站点根目录下生成public文件夹, hexo会将"/blog/source/" 下面的.md后缀的文件编译为.html后缀的文件,存放在"/blog/public/ " 路径下)
hexo d #将本地数据部署到远端服务器(如github)
hexo init 文件夹名称 #初始化XX文件夹名称
npm update hexo -g#升级
npm install hexo -g#安装
node-v #查看node.js版本号
npm -v #查看npm版本号
git --version #查看git版本号
hexo -v #查看hexo版本号


# 上传到git仓库指令

`hexo clean && hexo d` 清除缓存并上传到git仓库

# 便签功能

{% note success %}
文字 或者 `markdown` 均可
{% endnote %}

# 公式编辑器

# Mermaid 相关


`{% mermaid %}`
`{% endmermaid %}`

用这个标记把流程图框起来（不知道为什么我这用代码块画会报错）


# 更多

参见 https://hexo.fluid-dev.com/docs/guide/


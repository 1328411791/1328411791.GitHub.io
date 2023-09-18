---
title: github page 自动部署服务器
date: 2023-04-22 17:47:25
tags: [博客，部署]
---

# 起因

这个博客是同时部署在[github page](https://1328411791.github.io/) 和 [我自己的服务器](https://www.liahnu.top/)上，通常在更新博客内容时，会产生数据同步问题。即使用`hexo d`指令后，上传到 Github page 仓库，不同时更新自己服务器上的内容。在更新完成仓库后，需要手动登录服务器进行拉取仓库。

# 解决方法

首先，在上传到github仓库时，所产生的网页文件已经是被打包好的了，因此在部署到服务器只需要拉取仓库。因此，可以使用github中Webhooks功能来拉取更新时候的代码。

## Webhooks是什么

Webhook 允许在某些事件发生时通知外部服务。当指定的事件发生时，我们将向您提供的每个 URL 发送一个 POST 请求。


## 启动github webhook

在github的设置页设置webhook参数

![](https://pic.liahnu.top/img/202304221908717.png)

## 编写sh脚本处理post请求


```sh
#!/bin/bash

# 启动 HTTP 监听服务
nc -l 7000 | while read line
do
    # 检查是否为 POST 请求
    if [[ "$line" == "POST"* ]]
    then
        # 返回 OK 响应
        echo "HTTP/1.1 200 OK"
        echo "Content-Length: 2"
        echo ""
        echo "ok"
    
        # 执行 git pull 操作
        cd /www/hexo/1328411791.GitHub.io/
        git pull origin


    fi
done
```
这段代码这有基础的功能，没有对请求进行验证，同时也没有http返回状态和参数（shell不如py）

真不如py，下面是python的代码
```python
import git
from flask import Flask, request

app = Flask(__name__)

@app.route('/update', methods=['GET'])
def update():
    # github hook 辨别
    if(request.headers.get('X-GitHub-Hook-ID') != "11"):
        return json.dumps({'msg': 'Not a valid github hook'})
    repo = git.Repo('/path/to/repo')
    # 更新本地仓库
    origin = repo.remotes.origin
    # 删除本地仓库
    repo.git.reset('--hard')
    # 拉取远程仓库内容到本地仓库
    origin.pull("master")
    # 输出更新日志  
    print("Updated PythonAnywhere source to commit {}".format(str(repo.head.commit))) 
    ret = {'msg': 'Updated PythonAnywhere source to commit {}'.format(str(repo.head.commit))}
    return ret

if __name__ == '__main__':
    app.run(host= '0.0.0.0',port= 4000, debug=True)

```
安装对应的依赖，代码仅供参考

写完后,发送测试请求，发现成功被接收

![](https://pic.liahnu.top/img/202304221909827.png)




下面将脚本进行后台运行即可

nohup 命令可以用来处理脚本后台运行，将输出重定向到log文件
```
nohup ./update.sh > ./log 2>&1 & 
```

查看log 发现代码被正确拉取

![](https://pic.liahnu.top/img/202304221912578.png)
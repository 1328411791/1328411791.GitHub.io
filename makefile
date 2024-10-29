# 定义变量
HEXO_DIR := /path/to/your/hexo/project
DEPLOY_DIR := /path/to/deploy/directory

# 默认目标
.PHONY: all
all: generate

# 生成静态文件
.PHONY: generate
generate:
    @echo "Generating static files..."
    cd $(HEXO_DIR) && hexo generate

# 启动本地服务器
.PHONY: serve
serve:
    @echo "Starting local server..."
    cd $(HEXO_DIR) && hexo serve

# 清理生成的文件
.PHONY: clean
clean:
    @echo "Cleaning generated files..."
    cd $(HEXO_DIR) && hexo clean

# 部署到远程服务器
.PHONY: deploy
deploy: generate
    @echo "Deploying to remote server..."
    cd $(HEXO_DIR) && hexo deploy

# 帮助信息
.PHONY: help
help:
    @echo "Usage:"
    @echo "  make generate   - Generate static files"
    @echo "  make serve      - Start local server"
    @echo "  make clean      - Clean generated files"
    @echo "  make deploy     - Deploy to remote server"
    @echo "  make help       - Show this help message"
# 自动打包docker镜像
```
当目标机器不方便连接互联网时，可使用该脚本在方便联网的机器上，快捷下载并导出指定的镜像，且对镜像文件命名和压缩
可在Codespaces尝试
```

## 使用示例
需要在脚本后指定：镜像名(xxx或xxx/xxx)，版本(具体版本号或latest)，平台完整名称（不写则默认为linux/amd64）
```
./saveimg.sh mysql 8.0.37 linux/arm64
```
```
./saveimg.sh portainer/portainer latest linux/amd64
```
最终输出的文件类似于
```
mysql_8.0.37_linux_arm64.tar.gz
```
```
portainer_portainer_latest_linux_amd64.tar.gz
```
将文件放在目标机器上，使用命令导入
```
docker load -i mysql_8.0.37_linux_arm64.tar.gz
```

## 如何确定latest目前对应的版本
使用docker pull拉取latest版本，并使用以下命令来检查出具体版本
```
docker image inspect mysql:latest | grep -i version
```

## 说明
该脚本使用AI编写，是对docker pull和docker save的简单封装
# 自动打包docker镜像
```
当目标机器不方便连接互联网时，可用该脚本在方便联网的机器上导出指定的镜像，需要指定平台版本
```

## 如何确定latest目前对应的版本
使用docker pull拉取latest版本，并使用以下命令来检查出具体版本
```
docker image inspect mysql:latest | grep -i version
```

## 使用示例

```
./saveimg.sh mysql 8.0.37 linux/arm64
```
```
./saveimg.sh portainer/portainer latest linux/amd64
```
最终输出的文件类似于
```
mysql_8.0.37_linux_amd64.tar.gz
```
```
portainer_portainer_latest_linux_amd64.tar.gz
```
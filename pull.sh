#!/bin/bash

# 检查参数数量是否正确
if [ "$#" -ne 3 ]; then
    echo "用法: $0 <镜像名称> <标签> <平台>"
    exit 1
fi

# 获取传递的参数
IMAGE_NAME=$1
TAG=$2
PLATFORM=$3

# 生成导出文件名，例如：mysql_8.0.37_arm64.tar.gz
PLATFORM_SUFFIX=$(echo ${PLATFORM} | tr '/' '_')
TAR_FILE="${IMAGE_NAME}_${TAG}_${PLATFORM_SUFFIX}.tar"
GZ_FILE="${TAR_FILE}.gz"

# 检查是否已经存在相同的文件
if [ -f ${GZ_FILE} ]; then
    echo "文件 ${GZ_FILE} 已经存在。中止执行。"
    exit 1
fi

# 拉取指定的平台镜像
docker pull --platform=${PLATFORM} ${IMAGE_NAME}:${TAG}

# 检查拉取是否成功
if [ $? -ne 0 ]; then
    echo "拉取镜像 ${IMAGE_NAME}:${TAG} (平台: ${PLATFORM}) 失败"
    exit 1
fi

# 导出镜像为tar文件
docker save -o ${TAR_FILE} ${IMAGE_NAME}:${TAG}

# 检查导出是否成功
if [ $? -ne 0 ]; then
    echo "导出镜像 ${IMAGE_NAME}:${TAG} 失败"
    exit 1
fi

# 对导出的tar文件进行gzip压缩
gzip ${TAR_FILE}

# 检查压缩是否成功
if [ $? -ne 0 ]; then
    echo "压缩文件 ${TAR_FILE} 失败"
    exit 1
fi

echo "镜像已成功拉取、导出并压缩为 ${GZ_FILE}"

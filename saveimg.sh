#!/bin/bash

# 检查Docker是否安装
if ! command -v docker &> /dev/null; then
    echo "Error: Docker 未安装。"
    exit 1
fi

# 检查Docker是否在运行
if ! docker info &> /dev/null; then
    echo "Error: Docker 未运行。请启动Docker。"
    exit 1
fi

# 检查参数数量是否正确
if [ "$#" -lt 2 ] || [ "$#" -gt 3 ]; then
    echo "用法: $0 <镜像名称> <标签> [平台]"
    exit 1
fi

# 获取传递的参数
IMAGE_NAME=$1
TAG=$2
PLATFORM=${3:-linux/amd64}  # 默认为 linux/amd64

# 验证镜像名称和标签格式
if [[ ! ${IMAGE_NAME} =~ ^[a-z0-9]+([._/-]?[a-z0-9]+)*$ || ! ${TAG} =~ ^[a-zA-Z0-9._-]+$ ]]; then
    echo "Error: 镜像名称或标签格式不正确。"
    exit 1
fi

# 生成导出文件名
PLATFORM_SUFFIX=$(echo ${PLATFORM} | tr '/' '_')
TAR_FILE="${IMAGE_NAME//\//_}_${TAG}_${PLATFORM_SUFFIX}.tar"
GZ_FILE="${TAR_FILE}.gz"

# 检查是否已经存在相同的文件
if [ -f ${GZ_FILE} ]; then
    echo "文件 ${GZ_FILE} 已经存在。中止执行。"
    exit 1
fi

# 拉取指定的平台镜像
echo "正在拉取镜像 ${IMAGE_NAME}:${TAG} (平台: ${PLATFORM})"
docker pull --platform=${PLATFORM} ${IMAGE_NAME}:${TAG}

# 检查拉取是否成功
if [ $? -ne 0 ]; then
    echo "Error: 拉取镜像 ${IMAGE_NAME}:${TAG} (平台: ${PLATFORM}) 失败"
    exit 1
fi

# 验证镜像是否存在并且是指定的平台
IMAGE_ID=$(docker images --filter=reference="${IMAGE_NAME}:${TAG}" --format "{{.ID}}")
if [ -z "${IMAGE_ID}" ]; then
    echo "Error: 无法找到镜像 ${IMAGE_NAME}:${TAG}"
    exit 1
fi

INSPECT_PLATFORM=$(docker inspect --format '{{.Os}}/{{.Architecture}}' ${IMAGE_ID})
if [ "${INSPECT_PLATFORM}" != "${PLATFORM}" ]; then
    echo "Error: 镜像 ${IMAGE_NAME}:${TAG} 的平台 (${INSPECT_PLATFORM}) 与预期的平台 (${PLATFORM}) 不匹配"
    exit 1
fi

# 导出镜像为tar文件
echo "正在导出镜像 ${IMAGE_NAME}:${TAG} (ID: ${IMAGE_ID}) 为 ${TAR_FILE}"
docker save -o ${TAR_FILE} ${IMAGE_ID}

# 检查导出是否成功
if [ $? -ne 0 ]; then
    echo "Error: 导出镜像 ${IMAGE_NAME}:${TAG} (ID: ${IMAGE_ID}) 失败"
    rm -f ${TAR_FILE}
    exit 1
fi

# 对导出的tar文件进行gzip压缩
echo "正在压缩文件 ${TAR_FILE}"

if command -v pigz &> /dev/null; then
    pigz ${TAR_FILE}
else
    gzip ${TAR_FILE}
fi

# 检查压缩是否成功
if [ $? -ne 0 ]; then
    echo "Error: 压缩文件 ${TAR_FILE} 失败"
    rm -f ${TAR_FILE} ${GZ_FILE}
    exit 1
fi

echo "镜像已成功拉取、导出并压缩为 ${GZ_FILE}"

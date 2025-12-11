# 使用多阶段构建
FROM docker.io/library/node:20-slim AS builder

# 安装构建依赖
RUN apt-get update && apt-get install -y --no-install-recommends \
  python3 \
  make \
  g++ \
  git \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# 设置 npm 全局包文件夹
RUN mkdir -p /usr/local/share/npm-global
ENV NPM_CONFIG_PREFIX=/usr/local/share/npm-global
ENV PATH=$PATH:/usr/local/share/npm-global/bin

# 安装 @google/gemini-cli
RUN npm install -g @google/gemini-cli@0.14

# 运行时阶段
FROM docker.io/library/node:20-slim

ARG SANDBOX_NAME="gemini-cli-sandbox"
ARG CLI_VERSION="0.14"
ENV SANDBOX="$SANDBOX_NAME"
ENV CLI_VERSION=$CLI_VERSION
ENV NODE_ENV=production

# 安装运行时依赖
RUN apt-get update && apt-get install -y --no-install-recommends \
  python3 \
  python3-pip \
  python3-venv \
  man-db \
  curl \
  wget \
  dnsutils \
  less \
  jq \
  bc \
  gh \
  git \
  unzip \
  rsync \
  ripgrep \
  procps \
  psmisc \
  lsof \
  socat \
  net-tools \
  iputils-ping \
  netcat-openbsd \
  ca-certificates \
  openssl \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# 设置 npm 全局包文件夹
RUN mkdir -p /usr/local/share/npm-global
ENV NPM_CONFIG_PREFIX=/usr/local/share/npm-global
ENV PATH=$PATH:/usr/local/share/npm-global/bin

# 复制 gemini-cli 从构建阶段
COPY --from=builder /usr/local/share/npm-global /usr/local/share/npm-global

# 验证安装
RUN gemini --version && \
    echo "Gemini CLI version:" && \
    gemini --version

# 创建应用目录
WORKDIR /app

# 设置容器默认行为
CMD ["gemini", "--help"]
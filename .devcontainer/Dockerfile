# Sử dụng image Ubuntu được tối ưu cho Dev Containers
FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

# Tránh các câu hỏi tương tác khi cài đặt gói
ENV DEBIAN_FRONTEND=noninteractive

# Các biến môi trường cho Android SDK
ENV ANDROID_SDK_ROOT=/usr/local/lib/android-sdk
ENV PATH=${PATH}:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools

# 1. Cài đặt các phụ thuộc hệ thống
RUN apt-get update && apt-get install -y --no-install-recommends \
    openjdk-17-jdk \
    curl \
    unzip \
    zip \
    git \
    xz-utils \
    libglu1-mesa \
    libpulse0 \
    nodejs \
    python3 \
    python3-pip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 2. Cài đặt Android SDK Command-line Tools
RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools \
    && curl -o cmdline-tools.zip https://dl.google.com/android/repository/commandlinetools-linux-10406996_latest.zip \
    && unzip cmdline-tools.zip -d ${ANDROID_SDK_ROOT}/cmdline-tools \
    && mv ${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools ${ANDROID_SDK_ROOT}/cmdline-tools/latest \
    && rm cmdline-tools.zip

# 3. Chấp nhận giấy phép Android và cài đặt Platform/Build tools
# Chạy với tư cách root để cài đặt vào /usr/local/lib
RUN yes | sdkmanager --licenses \
    && sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"

# SDK is writable by the development user.
RUN chown -R vscode:vscode ${ANDROID_SDK_ROOT}
USER vscode

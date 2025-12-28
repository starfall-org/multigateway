# Sử dụng image Ubuntu được tối ưu cho Dev Containers
FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

# Tránh các câu hỏi tương tác khi cài đặt gói
ENV DEBIAN_FRONTEND=noninteractive

# Các biến môi trường cho Android SDK và Flutter
ENV ANDROID_SDK_ROOT=/usr/local/lib/android-sdk
ENV FLUTTER_HOME=/usr/local/lib/flutter
ENV PATH=${PATH}:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools:${FLUTTER_HOME}/bin

# 1. Cài đặt các phụ thuộc hệ thống
RUN apt-get update && apt-get install -y --no-install-recommends \
    default-jdk \
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

# 4. Cài đặt Flutter SDK (phiên bản ổn định)
RUN git clone https://github.com/flutter/flutter.git -b stable ${FLUTTER_HOME}

# 5. Cấu hình Flutter và kiểm tra môi trường
RUN flutter config --no-analytics \
    && flutter doctor

# 6. Đổi quyền sở hữu cho user 'vscode' để có thể cập nhật SDK sau này nếu cần
RUN chown -R vscode:vscode ${ANDROID_SDK_ROOT} ${FLUTTER_HOME}

# Chuyển sang user vscode cho các lệnh tiếp theo
USER vscode

# Khởi tạo Flutter cho user vscode
RUN flutter doctor

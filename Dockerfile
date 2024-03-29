# alpine fails too 
# FROM mcr.microsoft.com/dotnet/sdk:8.0.101-alpine3.19-amd64 AS build-env
# RUN apk add build-base

FROM mcr.microsoft.com/dotnet/sdk:8.0-jammy AS build-env
# SHELL ["/bin/bash", "-c"]
RUN apt update
RUN apt install -y openjdk-11-jdk unzip 


ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64/


# Install Android SDK
RUN mkdir -p /usr/lib/android-sdk/cmdline-tools/latest && \
    curl -k "https://dl.google.com/android/repository/commandlinetools-linux-9123335_latest.zip" -o commandlinetools-linux.zip && \
    unzip -q commandlinetools-linux.zip -d /usr/lib/android-sdk/tmp && \
    mv  /usr/lib/android-sdk/tmp/cmdline-tools/* /usr/lib/android-sdk/cmdline-tools/latest && \
    rm -rf /usr/lib/android-sdk/tmp/ && \
    rm commandlinetools-linux.zip 

ENV ANDROID_SDK_ROOT=/usr/lib/android-sdk
ENV PATH=$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$PATH

RUN yes | sdkmanager --licenses
RUN sdkmanager "platform-tools"
RUN sdkmanager "build-tools;34.0.0" "platforms;android-34"

#install workload into home dir 
ENV DOTNET_ROOT=/usr/share/dotnet
RUN for i in $DOTNET_ROOT/sdk-manifests/*; do \
          i=$(basename $i); \
          i=$(echo "$i" | sed 's/-.*//'); \
          mkdir -p $DOTNET_ROOT/metadata/workloads/$i; \
          touch $DOTNET_ROOT/metadata/workloads/$i/userlocal; \
        done

RUN dotnet workload install android maui-android --ignore-failed-sources

RUN ls -al $HOME/.dotnet/sdk-manifests 

FROM build-env
ENV ANDROID_SDK_ROOT=/usr/lib/android-sdk
ENV PATH=$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$PATH
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64/

WORKDIR /app
COPY ./ ./

RUN dotnet workload restore 
RUN dotnet restore
RUN dotnet publish -c Release -f net8.0-android  /p:AndroidSdkDirectory=/usr/lib/android-sdk 

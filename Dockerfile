FROM mcr.microsoft.com/dotnet/core/sdk:2.2.204-stretch AS get-dotnet-sdk

RUN apt-get update -qq \
    && apt-get install -y git zip unzip dos2unix libunwind8

ADD src src

RUN dotnet --info \
    && cd src \
    && git clone https://github.com/cake-build/cake.git \
    && cd cake \
    && latesttag=$(git describe --tags `git rev-list --tags --max-count=1`) \
    && echo checking out ${latesttag} \
    && git checkout -b ${latesttag} ${latesttag} \
    && cd .. \
    && dos2unix -q ./build.sh \
    && chmod +x ./build.sh \
    && ./build.sh \
    && echo ${latesttag} > /app/cakeversion

FROM jenkins/jnlp-slave:3.27-1

MAINTAINER Louis Shen <vvvsrx@gmail.com>

USER root

ENV DOTNET_SDK_VERSION=2.2.204 

RUN apt-get update -qq \
    && apt-get install -y --no-install-recommends \
        libc6 \
        libgcc1 \
        libgssapi-krb5-2 \
        libicu57 \
        liblttng-ust0 \
        libssl1.0.2 \
        libstdc++6 \
        zlib1g \
        libunwind8 \
        dos2unix \
    && rm -rf /var/lib/apt/lists/* 

COPY --from=get-dotnet-sdk ["/usr/share/dotnet", "/usr/share/dotnet"]

COPY --from=get-dotnet-sdk ["/app", "/cake"]

ADD src/cake.sh /cake/cake

# Install dotnet dependencies and ca-certificates
#RUN cat /cake/cakeversion
#RUN ls /cake
RUN ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    #ln -s /cake/cake /usr/bin/cake \
    && mkdir src \
    && dos2unix -q /cake/cake \
    && chmod 755 /cake/cake \
    && chmod 755 /cake/Cake \
    && sync 
    
ENV ASPNETCORE_URLS=http://+:80 \
    # Enable detection of running in a container
    DOTNET_RUNNING_IN_CONTAINER=true \
    # Enable correct mode for dotnet watch (only mode supported in a container)
    DOTNET_USE_POLLING_FILE_WATCHER=true \
    # Skip extraction of XML docs - generally not useful within an image/container - helps perfomance
    NUGET_XMLDOC_MODE=skip

ENV PATH=$PATH:/cake

USER jenkins

ENV PATH=$PATH:/home/jenkins/.dotnet/tools

RUN dotnet --info

RUN echo $PATH

RUN Cake --version && cake --version
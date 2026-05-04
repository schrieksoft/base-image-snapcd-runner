FROM mcr.microsoft.com/dotnet/aspnet:10.0-noble

RUN apt-get update && \
    apt-get install -y --no-install-recommends git openssh-client wget curl && \
    rm -rf /var/lib/apt/lists/*

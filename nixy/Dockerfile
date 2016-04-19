FROM phusion/baseimage:0.9.15

RUN curl -SL "https://github.com/martensson/nixy/releases/download/v0.4.10/nixy_0.4.10_linux_amd64.tar.gz" | tar -xz
WORKDIR nixy_0.4.10_linux_amd64

ADD nixy.toml nixy.toml

ENTRYPOINT ./nixy

### Builder

FROM alpine:3.10.1 AS builder
RUN apk --no-cache add gcc git make linux-headers musl-dev
WORKDIR /opt
RUN git clone https://github.com/jedisct1/dsvpn . && \
        make

### Packed application

FROM scratch

SHELL ["/bin/busybox", "ash", "-c"]

COPY --from=builder /opt/dsvpn /
COPY --from=builder /bin/busybox /bin/busybox
COPY --from=builder /lib/ld-musl-x86_64.so.1 /lib/ld-musl-x86_64.so.1

RUN busybox mkdir -p /sbin /bin /usr/bin && \
    busybox ln -s /bin/busybox /sbin/ip && \
    busybox ln -s /bin/busybox /sbin/route && \
    busybox ln -s /bin/busybox /bin/dd && \
    busybox ln -s /bin/busybox /usr/bin/awk && \
    busybox ln -s /bin/busybox /bin/sh && \
    busybox ln -s /bin/busybox /bin/ip

ENTRYPOINT [ "/dsvpn" ]

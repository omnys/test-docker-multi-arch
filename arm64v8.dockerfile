FROM alpine as builder

# Download QEMU, see https://github.com/docker/hub-feedback/issues/1261
ENV QEMU_URL https://github.com/balena-io/qemu/releases/download/v3.0.0%2Bresin/qemu-3.0.0+resin-aarch64.tar.gz

WORKDIR  /tmp

RUN wget https://repository-master.mulesoft.org/nexus/service/local/repositories/releases/content/org/mule/distributions/mule-standalone/4.2.1/mule-standalone-4.2.1.zip && \
  unzip mule-standalone-4.2.1.zip

RUN apk add curl && curl -L ${QEMU_URL} | tar zxvf - -C . --strip-components 1

FROM arm64v8/openjdk:8-slim

# Add QEMU
COPY --from=builder qemu-aarch64-static /usr/bin

# Define working directory.
WORKDIR /opt/mule

COPY --from=builder /tmp/mule-standalone-4.2.1 .
RUN /usr/sbin/useradd -m mule && \
  /bin/chown -R mule /opt/mule

USER mule

# Define mount points.
VOLUME ["/opt/mule/logs", "/opt/mule/conf", "/opt/mule/apps", "/opt/mule/domains"]

# Default http port
EXPOSE 8081

CMD [ "./bin/mule" ]

FROM node:10-buster AS builder

RUN export DEBIAN_FRONTEND=noninteractive \
  && apt-get -qq update \
  && apt-get -y --no-install-recommends install \
      apt-transport-https \
      curl \
      unzip \
      build-essential \
      python \
      libcairo2-dev \
      libgles2-mesa-dev \
      libgbm-dev \
      libllvm7 \
      libprotobuf-dev \
      libxxf86vm-dev \
      xvfb \
      x11-utils \
  && apt-get -y --purge autoremove \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

#RUN mkdir -p /usr/src/app
COPY / /usr/src/app

ENV NODE_ENV="production"

RUN cd /usr/src/app && npm install --production


FROM node:10-buster-slim AS final

RUN export DEBIAN_FRONTEND=noninteractive \
  && apt-get -qq update \
  && apt-get -y --no-install-recommends install \
      curl \
      libcairo2 \
      libgles2-mesa \
      libegl1 \
      libprotobuf17 \
      libxxf86vm1 \
      xvfb \
      xauth \
  && apt-get -y --purge autoremove \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/src/app /app

ENV NODE_ENV="production"
ENV CHOKIDAR_USEPOLLING=1
ENV CHOKIDAR_INTERVAL=500

VOLUME /data
WORKDIR /data

EXPOSE 80

ENTRYPOINT ["/app/docker-entrypoint.sh"]

CMD ["-p", "80"]

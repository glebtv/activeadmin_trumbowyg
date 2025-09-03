ARG RUBY_IMAGE=ruby:3
FROM ${RUBY_IMAGE}

ENV DEBIAN_FRONTEND=noninteractive
ENV DEVEL=1
ENV LANG=C.UTF-8

RUN apt-get update -qq && \
    apt-get install -yqq --no-install-recommends \
    build-essential \
    chromium \
    less \
    libyaml-dev \
    nano \
    netcat-traditional \
    pkg-config && \
    rm -rf /var/lib/apt/lists/*

ARG BUNDLER_VERSION
ARG UID
RUN gem install bundler -v "${BUNDLER_VERSION}" && \
    echo 'gem: --no-document' > /etc/gemrc && \
    useradd -u "${UID}" --shell /bin/bash app && \
    mkdir -p /home/app && \
    chown -R app:app /home/app

ARG RAILS_VERSION
ENV RAILS_VERSION=$RAILS_VERSION

ARG ACTIVEADMIN_VERSION
ENV ACTIVEADMIN_VERSION=$ACTIVEADMIN_VERSION

WORKDIR /app
COPY . /app
RUN bundle install && \
    chown -R app:app /usr/local/bundle && \
    ln -s /app/extra/.bashrc /home/app/.bashrc

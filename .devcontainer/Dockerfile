# Based on https://evilmartians.com/chronicles/ruby-on-whales-docker-for-ruby-rails-development
# Allow parametrization from outside image
ARG RUBY_VERSION=3.2.2
ARG DISTRO_NAME=bullseye

# Bullseye is codename for Debia 11, current stable distro
# Docker-Slim refers to optimized docker image
# Ex: "3.2.2-slim-bullseye", see here https://hub.docker.com/_/ruby
FROM ruby:$RUBY_VERSION-slim-$DISTRO_NAME

# Common dependencies.
# Tricks to boost build performance: https://docs.docker.com/build/cache/
# Remember, when docker build an image, it will rebuild only from changed layer onwards.
# If this layer never changes, it will always be cached, and thus, will never bring "updated packages"
# Even though "apt-get update" is present
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    --mount=type=tmpfs,target=/var/log                      \
    apt-get update -qq \
    && DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
        build-essential \
        gnupg2 \
        git  \
        curl \
        vim  \
        less \
        # To use devcontainer in vscode
        openssh-client

# install zsh for a better experience
RUN sh -c "$(curl -L https://github.com/deluan/zsh-in-docker/releases/download/v1.1.5/zsh-in-docker.sh)" -- \
    -t robbyrussell \
    -p git \
    -p https://github.com/zsh-users/zsh-autosuggestions \
    -p https://github.com/zsh-users/zsh-completions

# Configure bundler
ENV LANG=C.UTF-8 \
    BUNDLE_JOBS=4 \
    BUNDLE_RETRY=3

# Store Bundler settings in the project's root
ENV BUNDLE_APP_CONFIG=.bundle

# Local devcontainer Codespaces compatibility.
ENV BUNDLE_IGNORE_CONFIG=1
ENV BUNDLE_PATH=./vendor/bundle
ENV BUNDLE_CACHE_PATH=./vendor/cache

# Uncomment this line if you want to run binstubs without prefixing with `bin/` or `bundle exec`
ENV PATH /app/bin:$PATH

# Upgrade RubyGems and install the latest Bundler version
RUN gem update --system && \
    gem install bundler



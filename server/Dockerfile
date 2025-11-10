# syntax=docker/dockerfile:1
# check=error=true

ARG RUBY_VERSION=3.4.7
FROM docker.io/library/ruby:${RUBY_VERSION}-slim AS base

WORKDIR /app

# Dependências básicas (mínimas pro runtime)
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      curl \
      libjemalloc2 \
      libvips \
      libpq5 && \
    ln -s /usr/lib/$(uname -m)-linux-gnu/libjemalloc.so.2 /usr/local/lib/libjemalloc.so && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives

ENV BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_HOME="/usr/local/bundle" \
    LD_PRELOAD="/usr/local/lib/libjemalloc.so"

# Pacotes extras pra compilar gems e rodar em dev/test
ARG DEV_PACKAGES="build-essential git libyaml-dev pkg-config libpq-dev libvips-dev"

# ===========================
# BUILD (produção/test)
# ===========================
FROM base AS build

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y ${DEV_PACKAGES} && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives

COPY Gemfile Gemfile.lock ./
RUN bundle config set frozen false && bundle install --jobs=4

COPY . .

# ===========================
# DEVELOPMENT (hot reload)
# ===========================
FROM base AS development

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y ${DEV_PACKAGES} && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives

ENV RAILS_ENV=development

COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs=4

COPY bin/ ./bin/
RUN chmod +x ./bin/*

EXPOSE 3000

CMD ["bin/rails", "server", "-b", "0.0.0.0"]

# ===========================
# PRODUCTION
# ===========================
FROM base AS production

ENV RAILS_ENV=production \
    BUNDLE_DEPLOYMENT="1"

RUN groupadd --system --gid 1000 rails && \
    useradd --system --uid 1000 --gid 1000 rails

USER rails

COPY --chown=rails:rails --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --chown=rails:rails --from=build /app /app

EXPOSE 80
ENTRYPOINT ["/app/bin/docker-entrypoint"]
CMD ["./bin/rails", "server", "-b", "0.0.0.0"]

# ===========================
# TEST
# ===========================
FROM build AS test

ENV RAILS_ENV=test
ENTRYPOINT ["bundle", "exec"]
CMD ["rspec"]

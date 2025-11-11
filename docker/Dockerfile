FROM ruby:2.6.10

# System deps for Rails + pg + paperclip-like processing
RUN apt-get update -y && apt-get install -y --no-install-recommends \
      build-essential git curl ca-certificates \
      libpq-dev postgresql-client \
      imagemagick file \
    && rm -rf /var/lib/apt/lists/*

# Node for ExecJS / asset pipeline
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get update -y && apt-get install -y --no-install-recommends nodejs && \
    rm -rf /var/lib/apt/lists/* && corepack enable || true

WORKDIR /usr/src/app

# Copy gem manifests first (better caching)
COPY Gemfile Gemfile.lock ./

# Detect Bundler version from Gemfile.lock and install it
# Falls back to 1.17.3 if not present.
RUN set -eux; \
    BVER="$(awk '/BUNDLED WITH/{getline; gsub(/^[ \t]+/,\"\"); print; exit}' Gemfile.lock || true)"; \
    if [ -z "$BVER" ]; then BVER="1.17.3"; fi; \
    gem install bundler -v "$BVER"; \
    bundle _${BVER}_ config set path 'vendor/bundle'; \
    bundle _${BVER}_ install --jobs 4 --retry 3

# Bring in the rest of the app
COPY . .

EXPOSE 3000
CMD ["bash", "docker/docker_set_up.sh"]
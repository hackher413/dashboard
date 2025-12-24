#!/usr/bin/env bash
set -euo pipefail

# Clean leftover pid (ignore if missing)
rm -f tmp/pids/server.pid || true

# Ensure gems are present even when the app dir is bind-mounted
# If your lockfile says "BUNDLED WITH 1.17.3", this still works.
if ! bundle check >/dev/null 2>&1; then
  echo "Installing gems..."
  bundle install
fi

# One-time DB bootstrap marker (persists in your mounted db folder)
mkdir -p db/postgres
if [ ! -f "db/postgres/.built" ]; then
  echo "Bootstrapping database..."
  bundle exec rails db:create

  if [ "${RAILS_ENV:-development}" = "production" ]; then
    # Production-safe: no schema:load, no seeds
    bundle exec rails db:migrate
  else
    # Dev/local: OK to load schema + seed
    bundle exec rails db:migrate
    bundle exec rails db:setup
  fi

  # Optional task
  bundle exec rake feature_flags:load_flags || true
  touch db/postgres/.built
else
  # Always run migrations on boot (safe, and ensures deploys apply new migrations)
  bundle exec rails db:migrate
fi

# Start Rails
exec bundle exec rails server -b 0.0.0.0 -p 3000

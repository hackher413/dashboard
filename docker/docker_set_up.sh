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
  bundle exec rake db:create
  bundle exec rake db:migrate
  bundle exec rake db:setup
  # This task may not exist in all envs; don't crash if missing
  bundle exec rake feature_flags:load_flags || true
  touch db/postgres/.built
fi

# Start Rails
exec bundle exec rails server -b 0.0.0.0 -p 3000
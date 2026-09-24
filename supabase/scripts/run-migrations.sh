#!/usr/bin/env bash
# Applies every migration in supabase/migrations/ (on GitHub, main branch) that hasn't
# been applied to the database yet, in order. Safe to re-run any time: it fetches the
# current file list from GitHub itself, so there's nothing to download or keep up to
# date locally, and already-applied files (tracked in a public._migrations_applied table
# on the database) are skipped automatically.
#
# Usage:
#   export SUPABASE_ACCESS_TOKEN=your-token-here
#   ./run-migrations.sh
#
# SUPABASE_ACCESS_TOKEN is a Personal Access Token from
# https://supabase.com/dashboard/account/tokens — a *scoped* token limited to the Plugin
# Resale project with only Database -> Read-write. Revoke it from that same page once
# you're done for the day; you can always create a new one next time.

set -euo pipefail

PROJECT_REF="pwseqxvdvrkejeayroan"
API_URL="https://api.supabase.com/v1/projects/${PROJECT_REF}/database/query"
GH_API="https://api.github.com/repos/Plugin-Resale/pluginresale/contents/supabase/migrations"

if [ -z "${SUPABASE_ACCESS_TOKEN:-}" ]; then
  echo "Error: run 'export SUPABASE_ACCESS_TOKEN=your-token-here' first." >&2
  exit 1
fi

run_sql() {
  local sql="$1"
  local payload
  payload="$(python3 -c 'import json, sys; print(json.dumps({"query": sys.argv[1]}))' "$sql")"
  local response http_code body
  response="$(curl -sS -w '\n%{http_code}' -X POST "$API_URL" \
    -H "Authorization: Bearer ${SUPABASE_ACCESS_TOKEN}" \
    -H "Content-Type: application/json" \
    -d "$payload")"
  http_code="$(tail -n1 <<<"$response")"
  body="$(sed '$d' <<<"$response")"
  if [ "$http_code" -ge 300 ] || grep -q '"error"' <<<"$body"; then
    echo "SQL failed (HTTP $http_code):" >&2
    echo "$body" >&2
    return 1
  fi
  echo "$body"
}

run_sql "create table if not exists public._migrations_applied (
  filename text primary key,
  applied_at timestamptz not null default now()
);" >/dev/null

# Baseline: these were already applied by hand (copy-pasted into the SQL Editor) before
# this script existed. Marking them here (idempotent) stops the script from re-running them.
for f in 0001_profiles.sql 0002_developers_plugins.sql 0003_seed_developers.sql \
  0004_fix_seed_encoding.sql 0005_listings.sql 0006_deals.sql 0007_messages.sql \
  0008_reviews.sql 0009_legal.sql 0010_add_acustica_audio.sql 0011_catalogue_extension.sql \
  0012_daw_category.sql 0013_50_more_developers.sql 0014_native_instruments_catalogue.sql \
  0015_gap_fill.sql 0016_deepen_30_developers.sql 0017_deepen_70_more_developers.sql \
  0018_deepen_pa_uad_melda.sql 0019_fix_incomplete_developer_records.sql 0020_more_daws.sql \
  0021_even_more_daws.sql 0022_double_the_catalogue.sql 0023_more_daw_editions.sql; do
  run_sql "insert into public._migrations_applied (filename) values ('$f') on conflict do nothing;" >/dev/null
done

echo "Checking GitHub for migration files..."
listing="$(curl -sS "$GH_API")"
files="$(python3 -c '
import json, sys
items = json.loads(sys.stdin.read())
names = sorted(i["name"] for i in items if i["name"].endswith(".sql"))
print("\n".join(names))
' <<<"$listing")"

for name in $files; do
  already="$(run_sql "select 1 from public._migrations_applied where filename = '$name';")"
  if grep -q '\[{' <<<"$already"; then
    echo "skip   $name (already applied)"
    continue
  fi
  echo "apply  $name"
  raw_url="$(python3 -c '
import json, sys
items = json.loads(sys.argv[1])
name = sys.argv[2]
print(next(i["download_url"] for i in items if i["name"] == name))
' "$listing" "$name")"
  sql_content="$(curl -sS "$raw_url")"
  run_sql "$sql_content
insert into public._migrations_applied (filename) values ('$name');" >/dev/null
  echo "done   $name"
done

echo "All migrations up to date."

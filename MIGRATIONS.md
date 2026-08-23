# Database Migrations

This app's schema is versioned via Drift's `schemaVersion` in `lib/data/database/database.dart`.

## Rule: every schema change needs a migration step

Starting from schema version 9 (2026-08-23), NEVER tell a user to delete their local database when the schema changes. Instead, every time a column, table, or constraint changes:

1. Bump `schemaVersion` by 1.
2. Add an `if (from < <new version>) { ... }` block inside `onUpgrade` in `database.dart`, using Drift's `Migrator` methods (`m.addColumn`, `m.createTable`, `m.alterTable`, `m.deleteTable`, etc.) to transform the OLD structure into the NEW one, without deleting existing rows/data.
3. Test the migration by keeping an old-schema database file around and running the upgraded app against it — confirm existing data survives and the new columns/tables appear correctly.

Deleting the local database is only ever acceptable during active development BEFORE this baseline — never again after a real user has real data.

---
name: ef-core-migrations
description: Entity Framework Core database migration workflow — restore tools, create a migration, and apply it to a target database. Use when asked to create, apply, or manage EF Core migrations in a .NET project.
---

## Prerequisites

Run from the directory containing your EF Core Data project (e.g. `src/Data`).

Restore the local dotnet tools (includes `dotnet-ef`):

```bash
dotnet tool restore
```

## Environment Setup

Set the target environment via the `DOTNET_ENVIRONMENT` variable:

```bash
export DOTNET_ENVIRONMENT=development   # or: stage | prod
```

Create or update `appsettings.local.json` with the connection string for the target environment:

```json
{
  "ConnectionStrings": {
    "<environment-name>": "Host=<db-host>;Database=<db-name>;Username=<migration-user>;Password=<password>;"
  }
}
```

> **Never commit `appsettings.local.json`** — it contains credentials. Add it to `.gitignore`.

## Creating a Migration

```bash
dotnet ef migrations add <MigrationName>
```

Use descriptive names that reflect the schema change, e.g. `AddAnimalLactationIndex` or `CreateFarmTable`.

## Applying the Migration

```bash
dotnet ef database update
```

This applies all pending migrations up to the latest.

To apply up to a specific migration:

```bash
dotnet ef database update <MigrationName>
```

## Rolling Back a Migration

To revert to a previous migration:

```bash
dotnet ef database update <PreviousMigrationName>
```

To remove the last unapplied migration (before it has been applied):

```bash
dotnet ef migrations remove
```

## Listing Migrations

```bash
dotnet ef migrations list
```

Shows all migrations and whether they have been applied.

## Tips

- Always run `dotnet ef database update` against a non-production database first.
- For production, prefer generating a SQL script and having a DBA review it:
  ```bash
  dotnet ef migrations script --idempotent -o migration.sql
  ```
- If the project uses multiple `DbContext` types, specify with `--context <ContextName>`.

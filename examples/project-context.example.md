# Example Project Static Context (`SECTION 1` of `architecture-10-90.md`)

You can copy and adapt this block into **SECTION 1** of your local `~/.agents/rules/architecture-10-90.md` file (or in `<PROJECT_ROOT>/.agents/rules/architecture-10-90.md`) so that your project's static prefix remains cached across sessions:

```markdown
## SECTION 1: STATIC CONTEXT (IMMUTABLE)

### 1.1 Detected Technology Stack
- **Backend / ETL:** Python 3.12+ (`.venv` in `/opt/my_project/.venv`), FastAPI, SQLAlchemy, Pytest.
- **Frontend:** TypeScript, React, Vite, TailwindCSS in `/opt/my_project/webapp/`.
- **Data Infrastructure (Mock example environments / RFC 5737 `192.0.2.0/24`):**
  - **Production DB:** PostgreSQL 17 + PostGIS at `192.0.2.10:5432` (`app_db`).
  - **Staging / Test DB:** PostgreSQL 17 at `192.0.2.20:5432` (`app_db_staging`).
  - **Object Storage (S3/MinIO):** `http://192.0.2.30:9000` (buckets `assets-prod` and `assets-raw`).

### 1.2 Project Invariants
1. **Production Database Safety & Idempotency:**
   - Any migration or update script operates in `dry-run` simulation mode by default and requires an explicit `--apply` flag after generating a backup in `backups/`.
   - Primary keys and historical sequence IDs are strictly **APPEND-ONLY**.
```

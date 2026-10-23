# Ejemplo de Contexto Estático de Proyecto (`SECCIÓN 1` de `architecture-10-90.md`)

Puedes copiar y adaptar este bloque dentro de la **SECCIÓN 1** de tu archivo local `~/.agents/rules/architecture-10-90.md` (o en `<PROJECT_ROOT>/.agents/rules/architecture-10-90.md`) para que el prefijo estático de tu proyecto quede cacheado:

```markdown
## SECCIÓN 1: CONTEXTO ESTÁTICO (INMUTABLE)

### 1.1 Stack Tecnológico Detectado
- **Backend / ETL:** Python 3.12+ (`.venv` en `/opt/my_project/.venv`), FastAPI, SQLAlchemy, Pytest.
- **Frontend:** TypeScript, React, Vite, TailwindCSS en `/opt/my_project/webapp/`.
- **Infraestructura de Datos (Entornos ficticios de ejemplo / RFC 5737 `192.0.2.0/24`):**
  - **BD Producción:** PostgreSQL 17 + PostGIS en `192.0.2.10:5432` (`app_db`).
  - **BD Pruebas (Staging):** PostgreSQL 17 en `192.0.2.20:5432` (`app_db_staging`).
  - **Object Storage (S3/MinIO):** `http://192.0.2.30:9000` (buckets `assets-prod` y `assets-raw`).

### 1.2 Invariantes del Proyecto
1. **Idempotencia en BD de Producción:**
   - Todo script de migración o actualización opera en modo `dry-run` por defecto y requiere `--apply` explícito tras crear un respaldo en `backups/`.
   - Las claves primarias y secuencias históricas son estrictamente **APPEND-ONLY**.
```

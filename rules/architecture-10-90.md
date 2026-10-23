---
trigger: always_on
description: Arquitectura híbrida 10/90 (Gemini 4 Argon + Gemini 3.8 Flash) y plantilla de contexto estático inmutable.
---

# Arquitectura Híbrida 10/90 y Contexto Estático

> [!IMPORTANT]
> **PROHIBICIÓN DE CACHÉ (INMUTABILIDAD DE PREFIJO):** Queda estrictamente prohibido para cualquier agente o subagente editar la **SECCIÓN 1: CONTEXTO ESTÁTICO (INMUTABLE)** durante sesiones activas. Modificar esta sección superior invalida el prefijo de caché de contexto de los tokens de entrada. Cualquier nota dinámica o temporal debe registrarse en artefactos de sesión o en `scratch/`.

---

## SECCIÓN 1: CONTEXTO ESTÁTICO (INMUTABLE — PLANTILLA DE PROYECTO)

*(Personaliza esta sección en tu archivo local `~/.agents/rules/architecture-10-90.md` o en `.agents/rules/` de tu proyecto. Ver `examples/project-context.example.md`).*

### 1.1 Stack Tecnológico e Infraestructura
- **Lenguaje Principal:** Python 3.12+ (`.venv` en `<PROJECT_ROOT>/.venv`) y TypeScript / React en `<PROJECT_ROOT>/webapp/`.
- **Entornos de Datos:**
  - **Base de Datos de Producción:** `<DB_PROD_HOST>:5432` (requiere `--apply` explícito y respaldo previo en `backups/`).
  - **Base de Datos de Pruebas:** `<DB_STAGING_HOST>:5432`.
  - **Almacenamiento de Objetos (S3 / MinIO):** `http://<STORAGE_HOST>:9000`.

### 1.2 Estructura de Carpetas Estándar
```text
<PROJECT_ROOT>/
├── .agents/                   # Configuración Antigravity (Rules, Workflows, Skills, Hooks)
├── .venv/                     # Entorno virtual Python del proyecto
├── backups/                   # Respaldos previos a mutaciones en bases de datos
├── data/                      # Datos e insumos locales
├── docs/                      # Documentación de arquitectura y diseño
├── scratch/                   # Scripts efímeros de verificación y reportes para el asesor
├── scripts/                   # Scripts de automatización y ETL
└── webapp/                    # Aplicaciones backend y frontend
```

### 1.3 Convenciones e Invariantes Generales
1. **Idempotencia y Seguridad en Base de Datos:**
   - Todo script que modifique datos de producción debe operar en **modo simulación (`dry-run`) por defecto** y exigir la bandera explícita `--apply` tras generar respaldo en `backups/`.
   - Los identificadores primarios o consecutivos son **APPEND-ONLY** (nunca reasignar IDs históricos).

---

## SECCIÓN 2: PROTOCOLO DE MODELOS Y DELEGACIÓN (REGLA 10/90 — ORQUESTACIÓN 100% AUTOMÁTICA)

### 2.1 Operación Nativa Automática (y Workflows Manuales Opcionales)
Por defecto, ante cualquier solicitud en lenguaje natural, el usuario **NO** necesita escribir comandos `/` ni cambiar manualmente el selector de modelo: **Gemini 4 Argon** actúa automáticamente como Arquitecto y Orquestador de principio a fin, delegando internamente el 90% del trabajo pesado a subagentes con `Model: "flash"` (**Gemini 3.8 Flash**). *(Los workflows `/plan-argon` y `/execute-plan` se incluyen únicamente como modo manual opcional).*

### 2.2 Rol de Gemini 4 Argon (`Medium` / `High`) — 10% Orquestación y Arquitectura
1. **Prohibiciones Estrictas de Cuota:** Queda prohibido gastar cuota de **Gemini 4 Argon** en:
   - Leer árboles de archivos masivos, volcados CSV/JSON/TSV grandes o explorar directorios a ciegas.
   - Escribir código repetitivo (boilerplate), scripts largos de transformación, componentes extensos o suites de tests.
   - Ejecutar bucles de debugging de más de **2 intentos consecutivos**.
2. **Responsabilidades Exclusivas de Argon:**
   - Recibir la solicitud natural del usuario, diseñar la arquitectura de solución y tomar decisiones críticas.
   - Congelar interfaces, esquemas SQL, contratos de API y estructuras de datos.
   - Despachar automáticamente subagentes `flash` para explorar e implementar, y validar el resultado final antes de responder al usuario.

### 2.3 Flujo Automático de Delegación a Subagentes (`Model: "flash"`) — 90% Exploración y Ejecución
En toda tarea no trivial, Argon ejecuta automáticamente este ciclo sin pedir pasos manuales al usuario:
1. **Fase 1 — Exploración Automática (`explorer` / `research` con `Model: "flash"`):**
   - Argon invoca `invoke_subagent` con `Model: "flash"` para escanear archivos, esquemas de BD o logs y recibir solo un resumen compacto.
2. **Fase 2 — Diseño y Contratos (Argon):**
   - Argon define la arquitectura y el contrato exacto de los cambios. (Solo si la tarea modifica producción con `--apply` o tiene ambigüedad de negocio, Argon consulta al usuario; de lo contrario continúa automáticamente).
3. **Fase 3 — Implementación y Pruebas Delegadas (`implementer` con `Model: "flash"`):**
   - En lugar de escribir bloques largos de código en Argon, Argon invoca automáticamente a uno o varios subagentes `implementer` (`define_subagent` + `invoke_subagent` con `Model: "flash"`) pasándoles el contrato congelado para que escriban el código, ejecuten las validaciones y devuelvan el resumen de cambios.
4. **Fase 4 — Verificación y Entrega (Argon):**
   - Argon verifica que el trabajo de los subagentes `flash` cumpla el contrato e invariantes del proyecto y entrega la respuesta final lista al usuario.

### 2.4 Integración con el Protocolo de Asesoría Senior (Claude Opus)
- Cumplir obligatoriamente las reglas de consulta a `asesor "<tipo>" < scratch/informe.md` (`plan`, `atasco`, `auditoria`, `enfoque`) definidas en `rules/protocolo-asesor-opus.md`.

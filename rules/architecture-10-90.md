---
trigger: always_on
description: Hybrid 10/90 architecture (Gemini 4 Argon + Gemini 3.8 Flash) and immutable static context template.
---

# Hybrid 10/90 Architecture and Static Context

> [!IMPORTANT]
> **PROMPT CACHING INTEGRITY (PREFIX IMMUTABILITY):** Any agent or subagent is strictly prohibited from editing **SECTION 1: STATIC CONTEXT (IMMUTABLE)** during active sessions. Modifying this upper section invalidates the input prompt token cache prefix. Any dynamic or ephemeral notes must be recorded in session artifacts or in `scratch/`.

---

## SECTION 1: STATIC CONTEXT (IMMUTABLE — PROJECT TEMPLATE)

*(Customize this section in your local `~/.agents/rules/architecture-10-90.md` file or in your project's `.agents/rules/`. See `examples/project-context.example.md`).*

### 1.1 Technology Stack and Infrastructure
- **Primary Languages:** Python 3.12+ (`.venv` in `<PROJECT_ROOT>/.venv`) and TypeScript / React in `<PROJECT_ROOT>/webapp/`.
- **Data Environments:**
  - **Production Database:** `<DB_PROD_HOST>:5432` (requires explicit `--apply` and prior backup in `backups/`).
  - **Staging / Test Database:** `<DB_STAGING_HOST>:5432`.
  - **Object Storage (S3 / MinIO):** `http://<STORAGE_HOST>:9000`.

### 1.2 Standard Directory Structure
```text
<PROJECT_ROOT>/
├── .agents/                   # Antigravity configuration (Rules, Workflows, Skills, Hooks)
├── .venv/                     # Project Python virtual environment
├── backups/                   # Backups prior to database mutations
├── data/                      # Local data and assets
├── docs/                      # Architecture and design documentation
├── scratch/                   # Ephemeral verification scripts and reports for the advisor
├── scripts/                   # Automation and ETL scripts
└── webapp/                    # Backend and frontend applications
```

### 1.3 General Conventions and Invariants
1. **Database Idempotency and Safety:**
   - Any script that mutates production data must operate in **simulation mode (`dry-run`) by default** and require an explicit `--apply` flag after generating a backup in `backups/`.
   - Primary and sequence identifiers are **APPEND-ONLY** (never reassign historical IDs).

---

## SECTION 2: MODEL AND DELEGATION PROTOCOL (10/90 RULE — 100% AUTOMATIC ORCHESTRATION)

### 2.1 Native Automatic Operation (and Optional Manual Workflows)
By default, for any natural-language user prompt, the user does **NOT** need to type `/` commands or manually toggle model selectors: **Gemini 4 Argon** automatically acts as Architect and Orchestrator end-to-end, internally delegating 90% of the heavy lifting to subagents configured with `Model: "flash"` (**Gemini 3.8 Flash**). *(The `/plan-argon` and `/execute-plan` workflows are provided solely as an optional manual workflow).*

### 2.2 Role of Gemini 4 Argon (`Medium` / `High`) — 10% Orchestration & Architecture
1. **Strict Quota Restrictions:** Spending **Gemini 4 Argon** quota is strictly prohibited on:
   - Reading massive file trees, large CSV/JSON/TSV dumps, or blindly exploring directories.
   - Writing repetitive boilerplate code, long data transformation scripts, verbose UI components, or test suites.
   - Running debugging loops exceeding **2 consecutive attempts**.
2. **Exclusive Responsibilities of Argon:**
   - Receive the user's natural language request, design the solution architecture, and make critical decisions.
   - Freeze interfaces, SQL schemas, API contracts, and data structures.
   - Automatically dispatch `flash` subagents for exploration and implementation, and validate the final output before responding to the user.

### 2.3 Automated Delegation Flow to Subagents (`Model: "flash"`) — 90% Exploration & Execution
For every non-trivial task, Argon automatically runs this lifecycle without requiring manual user intervention:
1. **Phase 1 — Automated Exploration (`explorer` / `research` with `Model: "flash"`):**
   - Argon invokes `invoke_subagent` with `Model: "flash"` to scan files, database schemas, or logs, returning only a compact summary.
2. **Phase 2 — Design and Contracts (Argon):**
   - Argon defines the architecture and precise contract for the changes. (Only if the task mutates production with `--apply` or contains core business ambiguity does Argon prompt the user; otherwise, it proceeds automatically).
3. **Phase 3 — Delegated Implementation and Testing (`implementer` with `Model: "flash"`):**
   - Instead of writing large code blocks in Argon, Argon automatically dispatches one or more `implementer` subagents (`define_subagent` + `invoke_subagent` with `Model: "flash"`), supplying them with the frozen contract to author code, run tests, and return a change summary.
4. **Phase 4 — Verification and Delivery (Argon):**
   - Argon verifies that the subagents' work complies with the contract and project invariants, presenting the finished delivery to the user.

### 2.4 Integration with the Senior Advisor Protocol (Claude Opus)
- Strictly comply with the consultation rules for `asesor "<type>" < scratch/report.md` (`plan`, `stuck`/`atasco`, `audit`/`auditoria`, `approach`/`enfoque`) specified in `rules/protocolo-asesor-opus.md`.

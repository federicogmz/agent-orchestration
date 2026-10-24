---
description: (Optional manual mode) Scans context using lightweight subagents, designs system architecture, freezes interfaces/contracts, and generates an Implementation Plan Artifact without writing production code.
---

# Workflow `/plan-argon` — Architectural Design and Contract Freezing (10/90 Rule)

*(Note: Under standard operation, the 10/90 rule runs 100% automatically. Use this workflow only if you want to force a manual review pause between the design phase in Argon and execution in Flash).*

Strictly follow this lifecycle when the user triggers `/plan-argon`:

1. **Delegated Exploration (Zero Noise in Primary Context):**
   - Do not read multiple large files directly from Gemini 4 Argon.
   - Invoke a read-only subagent (`invoke_subagent` with `TypeName: "research"` or the `explorer` subagent defined in the `hybrid-swarm` skill, using `Model: "flash"`) to scan relevant project files and return only the dependency map, current signatures, and constraints.

2. **Architectural Design and Exact Contracts:**
   - Analyze the summary returned by the subagent.
   - Precisely define:
     - Exact files to create or modify.
     - Function signatures, classes, types (Python / TypeScript), or SQL queries/migrations.
     - Safety invariants (backups in `backups/`, `--apply` flags, preservation of primary keys).
     - Exact test and verification commands.

3. **Implementation Plan Artifact Generation:**
   - Create `implementation_plan.md` in the conversation artifact directory (`<appDataDir>/brain/<conversation-id>/implementation_plan.md`) with `ArtifactMetadata` (`UserFacing: true`, `RequestFeedback: true`).
   - **STRICTLY PROHIBITED to write production code** or edit repository files during this workflow.

4. **Deterministic Completion and Handoff:**
   - Stop execution immediately after generating the artifact and respond to the user with:
     > *"Plan and interfaces frozen. You can proceed directly or switch to **Gemini 3.8 Flash** and run `/execute-plan` to implement."*

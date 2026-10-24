---
description: (Optional manual mode) Executes the latest approved Implementation Plan using Gemini 3.8 Flash, writing all required code and running validations until passing without deviating from the frozen design.
---

# Workflow `/execute-plan` — High-Speed Execution (Gemini 3.8 Flash)

*(Note: This workflow is the optional manual counterpart to `/plan-argon` when the user wishes to execute a previously frozen `implementation_plan.md`).*

Follow these steps strictly without deviating from the frozen design:

1. **Read the Frozen Plan:**
   - Read the latest `implementation_plan.md` artifact in the conversation artifact directory (`<appDataDir>/brain/<conversation-id>/implementation_plan.md`) or the approved plan from recent session turns.
   - Strictly adhere to the signatures, contracts, filenames, and constraints defined by the Architect (Argon).

2. **Direct or Swarm Implementation:**
   - If changes span decoupled parallel modules (more than 2 independent files), trigger the `hybrid-swarm` skill to delegate to `implementer` subagents with `Model: "flash"`.
   - If changes are sequential, implement the full code directly using `write_file` and `edit_file` without leaving incomplete placeholders or `TODO`s.
   - If the `PostToolUse` hook is active, it automatically formats code after each edit; do not spend extra turns formatting manually.

3. **Automated Verification and Testing:**
   - Execute the validation commands specified in the plan (using `<PROJECT_ROOT>/.venv/bin/python` for Python scripts or `npm`/`npx` for web modules).
   - Never execute `--apply` against production databases without explicit user authorization and prior backup in `backups/`.
   - If any test or validation fails, fix it within a maximum of 2 iterations. If a design or architectural blocker persists, stop immediately and consult the advisor (`asesor "stuck"` or `asesor "atasco"`) or escalate to **Gemini 4 Argon**.

4. **Concise Completion Report:**
   - Deliver a brief summary with clickable links to all created/modified files and validation output.

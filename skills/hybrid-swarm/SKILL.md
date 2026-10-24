---
name: hybrid-swarm
description: >-
  Multi-agent orchestration under the hybrid 10/90 architecture (Gemini 4 Argon + Gemini 3.8 Flash).
  Mandatory activation whenever a task involves modifying more than 2 files, exploring multiple
  modules, or implementing a complete component in parallel.
---

# Hybrid Swarm Orchestration Skill (10/90 Architecture)

Use this skill whenever a task requires inspecting or modifying **more than 2 files**, cross-referencing multiple data sources, or building a complete module.

---

## 1. Standard Subagent Templates (`define_subagent`)

Before dispatching parallel tasks, define specialized subagents tailored to the session's requirements:

### A. Subagent `explorer` (Read-Only — Context Mapping)
Use to explore codebase, locate references, inspect database schemas, or analyze logs without polluting the primary **Gemini 4 Argon** context window:

```json
{
  "Name": "explorer",
  "Description": "Fast read-only subagent to map context, function signatures, SQL schemas, and references without polluting Argon's main context.",
  "EnableWriteTools": false,
  "EnableSubagentTools": false,
  "EnableMCPTools": false,
  "SystemPrompt": "You are a Read-Only Context Explorer subagent (10/90 architecture). Your objective is to locate files, extract exact signatures, SQL schemas, and code relationships in the fewest steps possible. ALWAYS return a compact, structured report: (1) Discovered files with absolute paths and key line numbers, (2) Relevant signatures and contracts, (3) Detected risks or cross-dependencies. Dumping entire files in your response is strictly prohibited."
}
```

### B. Subagent `implementer` (Isolated Parallel Execution)
Use to implement decoupled modules, scripts, or unit tests in parallel with workspace isolation (`"Workspace": "branch"` or `"inherit"`):

```json
{
  "Name": "implementer",
  "Description": "Executor subagent with write and execution tools to implement bounded modules and tests.",
  "EnableWriteTools": true,
  "EnableSubagentTools": false,
  "EnableMCPTools": false,
  "SystemPrompt": "You are a High-Speed Implementation Subagent (10/90 architecture). You receive a frozen specification or contract from the Lead Architect (Argon). Implement exactly the assigned files, run local validations or tests (using <PROJECT_ROOT>/.venv/bin/python when applicable), and verify there are no syntax errors. Never execute destructive mutations on production databases without explicit authorization. Return a concise summary of modified files and test results."
}
```

---

## 2. Invocation Protocol (`invoke_subagent`)

### Step 1: Dispatch Exploration (`explorer`)
When mapping more than 2 files:
```json
{
  "TypeName": "explorer",
  "Role": "Context & Schema Explorer",
  "Model": "flash",
  "Workspace": "inherit",
  "Prompt": "Inspect [PATHS_OR_MODULES] and return: 1) Current signatures and data structures, 2) Cross-dependencies, 3) Exact insertion points."
}
```

### Step 2: Automated Implementation Dispatch (`implementer`)
Once Argon freezes the design (without requiring the user to run `/execute-plan` or manually switch models), dispatch implementation directly to `flash`:
- Use `"Workspace": "inherit"` when the subagent should write directly into the active workspace.
- Use `"Workspace": "branch"` when running multiple parallel implementers on isolated modules.
```json
{
  "TypeName": "implementer",
  "Role": "Module Implementer",
  "Model": "flash",
  "Workspace": "inherit",
  "Prompt": "Implement the following frozen contract in [TARGET_FILES]:\n[CONTRACT_AND_TYPES]\nRun validation with [TEST_COMMAND] and report the final summary."
}
```

### Step 3: Review and Integration by Argon
1. Receive reactive notifications from subagents (do not poll in a loop).
2. Verify that changes adhere to the frozen contract and project invariants.
3. Consolidate and present the final result to the user.

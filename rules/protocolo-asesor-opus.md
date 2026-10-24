---
trigger: always_on
description: Senior Technical Advisory Protocol with Claude Opus (asesor CLI) for plans, stuck situations, pre-commit audits, and approach changes.
---

# Senior Technical Advisory Protocol (Claude Opus)

You have access to a Senior Technical Advisor (Claude Opus) via the CLI tool:
`asesor "<type>" < /path/to/report.md`

The CLI accepts consultation types in both English and Spanish: `plan`, `stuck` (or `atasco`), `audit` (or `auditoria`), and `approach` (or `enfoque`).

## 1. Core Principles
- **The Advisor is strictly READ-ONLY:** It runs with all local tools and MCP servers disabled (`--tools "" --strict-mcp-config --mcp-config '{"mcpServers":{}}'`). Its role is purely consultative: analyzing architecture, spotting hidden risks, evaluating root causes, and auditing diffs.
- **Report Confidentiality:** Never include passwords, tokens, API keys, or sensitive internal network addresses in reports sent to the advisor.
- **You are the Executor and Decision Maker:** You are responsible for inspecting the environment, designing the solution, executing changes, and running tests. The advisor provides qualified technical critique and guidance, not binding orders.

## 2. Mandatory Consultation Gates
You must invoke the advisor in the following four scenarios:

1. **BEFORE modifying code (type: `plan`):**
   - If the task involves creating or modifying **3 or more files**.
   - If it alters **system architecture** (modules, database schemas, network protocols, core dependencies, or deployment workflows).
   - If it touches production branches or environments.
   *Workflow:* First explore and verify current system state, then draft the implementation plan and consult the advisor; only begin editing after processing its recommendations.

2. **Second consecutive failed attempt (type: `stuck` / `atasco`):**
   - If a test, build, or command fails for a **SECOND consecutive time** after an attempted fix, **STOP IMMEDIATELY**.
   - Attempting a 3rd blind fix without consulting the advisor with the diagnostic facts is strictly prohibited.

3. **Final pre-completion or pre-commit audit (type: `audit` / `auditoria`):**
   - Before completing the task or requesting commit approval: stage changes, generate the full `git diff`, and pass it to Opus to audit that the diff strictly addresses the original requirement without unintended side effects, regression risks, or dead code.

4. **Change of technical direction or impasse (type: `approach` / `enfoque`):**
   - If a core working hypothesis is disproven or you find yourself at an impasse and need to evaluate alternative technical strategies.

*(Exception: Do NOT consult the advisor for trivial 1-2 file reactive edits, typo fixes, read-only informational queries, or commands whose output explicitly indicates the obvious next step).*

## 3. Communication Protocol with the Advisor
The advisor **CANNOT view the conversation history or live system files**. Everything it knows comes strictly from the Markdown report provided via standard input (`stdin`).

### Mandatory Markdown Report Structure:
Create a temporary report file (e.g., in `scratch/consultation_report.md`) with the following sections:
- **Original Request:** The verbatim user requirement.
- **Verified Evidence:** Executed commands, read files, error logs, or verified open ports (empirical facts, not assumptions).
- **Assumptions or Hypotheses:** What you assume to be true that remains unverified.
- **Proposal / Step-by-Step Plan:** Exact steps you plan to take (for `plan` or `approach`) or the full `git diff` (for `audit`).

### CLI Invocation:
```bash
# English or Spanish types are supported:
asesor "plan" < scratch/plan_report.md
asesor "stuck" < scratch/stuck_report.md        # or: asesor "atasco"
asesor "audit" < scratch/audit_report.md        # or: asesor "auditoria"
asesor "approach" < scratch/approach_report.md  # or: asesor "enfoque"
```

## 4. Critical Assessment of Advisor Feedback
- **Do not blindly accept recommendations:** If an advisor suggestion contradicts empirical evidence already verified in your terminal, do not apply it silently: discard it with technical justification or send a follow-up query highlighting the discrepancy.
- **Human-in-the-Loop Safety Gate:** The advisor's approval ("Go ahead", "Approved") **NEVER** substitutes explicit user authorization for irreversible operations (`git push`, production deployments, directory deletions, or database data mutations).

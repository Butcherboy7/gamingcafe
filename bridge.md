# Antigravity to External LLM Bridge

This document provides the external planning LLM with all the trigger commands (slash commands) available in the Antigravity IDE for the **Gaming Café Booking Platform** project. Use these slash commands in your prompts to Antigravity to invoke specific structured behaviours, personas, and workflows as defined in the `MASTER_SKILL.md` Engineering OS.

## Core Skill Modules

- `/gc_coach` - Activates **Module A (Learning Coach)**. Use this when you want Antigravity to teach a concept from first principles before writing code.
- `/gc_mentor` - Activates **Module B (Build Mentor)**. Use this *before* writing implementation code for a feature to walk through scope, DB schema, API design, and edge cases.
- `/gc_decide` - Activates **Module C (Decision Advisor)**. Use this when you need to evaluate tech stack or architecture choices (structured as options, pros/cons, recommendations, tradeoffs).
- `/gc_architect` - Activates **Module D (Project Architect)**. Use this to define the MVP scope, complexity budget, and implementation plan for a new feature.
- `/gc_linkedin` - Activates **Module E (LinkedIn Content Detector)**. Use this to extract and format key learnings for LinkedIn posts.
- `/gc_reflect` - Activates **Module F (Reflection Coach)**. Use this to review progress, log mistakes, and generate weekly study plans based on weak areas.
- `/gc_handoff` - Activates **Module G (Handoff Manager)**. Use this at the start of a session for orientation, or at the end of a session to update `HANDOFF.md` with the current system state.

## Implementation & Engineering Workflows

- `/gc_spec` - Generates a technical specification specifically for the Gaming Café Booking Platform *before* writing any code.
- `/gc_build` - Implements the approved spec following strict layering rules (models -> logic -> routes -> views).
- `/gc_critic` - Performs a hostile code review on the active backend or frontend code, targeting real bugs, race conditions, and over-engineering.
- `/gc_ux` - Performs a UI/UX critique on a Next.js view (Customer PWA or Admin Panel).
- `/gc_secure` - Red-teams the active Gaming Café routes or API endpoints for security vulnerabilities and authentication flaws.
- `/gc_ship` - Runs end-to-end pre-deploy verification and validation.
- `/gc_lifecycle` - Runs the Full Project/Feature Lifecycle Workflow sequentially from Stage 1 (Idea) to Stage 9 (Handoff).

## Utility Workflows

- `/gc_recap` - Generates a session recap aligned with the project's engineering records.
- `/gc_reset` - Performs a project-specific context reset to re-anchor the agent to the current Gaming Café state.

*(Note: There are generic equivalents of some workflows without the `gc_` prefix, such as `/build` and `/spec`, but the external LLM should **always prioritize the `gc_` prefixed workflows** as they hold the custom context for the FastAPI + Next.js stack of the Gaming Café).*

## How to structure prompts using these triggers

When generating prompts for Antigravity, append or prepend the relevant slash command to explicitly trigger the exact workflow state required. 

**Examples:**
> "We need to design the booking queue system. Please run `/gc_architect` to scope this out."
> "Here is my implementation of the Razorpay webhook. Run `/gc_critic` to check for race conditions and idempotency."
> "I don't understand how Redis slot locking works. Run `/gc_coach` to explain it."
> "We are ending the session. Run `/gc_handoff` and `/gc_reflect`."

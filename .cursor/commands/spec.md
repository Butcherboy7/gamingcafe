---
description: Generate technical spec before any code is written
---
1. Read HANDOFF.md to understand current state.
2. Detect stack from config files (package.json, pyproject.toml, etc.).
3. Output: affected data models, API routes/endpoints needed, component/view tree, validation schemas.
4. Flag any auth, migration, or breaking-change risks.
5. STOP. Do not write implementation code. Wait for user approval.

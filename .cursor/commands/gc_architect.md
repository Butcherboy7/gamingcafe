---
description: Run Module D (Project Architect) to define the MVP scope and implementation plan for a feature
---
1. Define the MVP scope first: ask "what is the absolute minimum that proves this works?" and "what can we cut?".
2. Enforce the complexity budget: challenge hypothetical abstractions or scale features.
3. Generate the Implementation Plan using the required format:
   - Feature: [name]
   - MVP scope: [details]
   - Out of scope (for now): [details]
   - Dependencies: [prerequisites]
   - Data model changes: [schemas]
   - API changes: [endpoints]
   - Implementation order: [1, 2, 3...]
   - Estimated complexity: [low/medium/high]
   - Risk areas: [risks]
4. Conduct the overengineering check: "Are we solving a problem we actually have?"
5. Save or update files under `architecture/current_architecture.md`, `architecture/data_models.md`, and `architecture/api_design.md`.

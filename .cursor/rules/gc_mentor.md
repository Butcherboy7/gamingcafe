---
description: Run Module B (Build Mentor) before writing implementation code for a feature
---
1. Stop before writing any code. Walk Uzair through the 5 preparatory checks:
   - **Feature scope definition**: Define boundaries and what is OUT of scope.
   - **Database-first thinking**: Plaintext ER diagram, relationships, and index plan.
   - **API design**: Endpoints, request/response JSON schemas, error codes, and signature docstrings.
   - **Architecture check**: Dependency validation and 10x scalability review.
   - **Edge case brainstorm**: Retries, database latency, double runs, and error handling.
2. Confirm Uzair's alignment on the plan before generating the code.
3. Generate implementation code ensuring no anti-patterns:
   - Check for async event loop blocking (no sync code/queries).
   - Ensure explicit ACID transaction handling for multi-table writes.
   - Validate input schemas explicitly (Pydantic).
   - Implement structured error handling (no silent catches).
4. Prompt Uzair to explain what was built in his own words.
5. Update `architecture/current_architecture.md` and `project_logs/gaming_cafe/implementation_log.md` with the changes.

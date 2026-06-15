---
description: Run Module E (LinkedIn Content Detector) to extract and format key learnings for LinkedIn posts
---
1. Analyze the session or recent changes to identify a LinkedIn-worthy moment:
   - AHA moments (concepts made clear).
   - Architectural bugs/lessons.
   - Tradeoff decisions (e.g. Next.js PWA, Redis slot locks).
   - Project milestones (first payment, worker process setup).
2. Ask: "🔖 LinkedIn moment detected: {brief description}. Should I add this to your content ideas?"
3. If confirmed, write a new entry to `linkedin_content/content_ideas.md` using the template:
   - Title idea
   - Date
   - Category (learning/build/mistake/milestone/insight)
   - The hook (engaging scroll-stopping line)
   - The story (what happened in 2-3 sentences)
   - The insight (lesson for other engineers)
   - Proof (code/diagram/metrics)
   - Draft status: idea
4. If requested to write a post, draft it using:
   - Line 1: Hook (counterintuitive or specific metric)
   - Lines 2-4: Story
   - Lines 5-7: What was learned (the meat)
   - Lines 8-10: Takeaway / call to action
   - Zero buzzwords (no "excited to share", "game-changer"). Speak like an engineer.

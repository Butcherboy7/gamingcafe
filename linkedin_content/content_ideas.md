# LinkedIn Content Ideas
> Captured automatically by Content Detector during sessions

---

## Idea format
```
### {Title idea}
**Date captured:** {date}
**Category:** learning / build / mistake / milestone / insight / comparison
**The hook:** {first line — make someone stop scrolling}
**The story:** {what happened, 2-3 sentences}
**The insight:** {what this teaches other engineers}
**Proof:** {code / diagram / metric}
**Draft status:** idea / drafted / scheduled / published
```

---

### How UPI broke our entire booking system
**Date captured:** {to be filled}
**Category:** build
**The hook:** "Our slot booking TTL was 2 minutes. UPI payments can take 40 minutes. We shipped a double-booking bug before writing a single line of code."
**The story:** While designing the booking flow, we realized UPI transactions enter a "pending" state that can last up to 40 minutes due to bank server delays. Our slot lock TTL was 2 minutes. This would release the slot while the payment was still processing, allowing someone else to book the same slot — both payments would succeed.
**The insight:** Payment systems in India have UPI-specific edge cases that don't exist in Western payment systems. You have to design for them explicitly.
**Proof:** Architecture diagram showing the 45-minute UPI lock extension
**Draft status:** idea

---

### I designed an entire production system without writing code first
**Date captured:** {to be filled}
**Category:** milestone
**The hook:** "29 features. 11 database tables. 35 API endpoints. Zero lines of code written. This is the document that gets us there."
**The story:** Instead of jumping into code, we spent time designing the complete system: database schema, API contracts, edge cases, race conditions, payment flows. The result is a document that another developer could pick up and build from scratch.
**The insight:** The most expensive bugs are the ones baked into your architecture. Changing a database schema after 1000 users is 10x harder than changing it before writing line 1.
**Proof:** Link to the PRD / architecture document
**Draft status:** idea


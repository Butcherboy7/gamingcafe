# Weak Areas — Study Tracker
> Honest self-assessment. Updated by Reflection Coach.

---

## Area format
```
### {Topic}
**First identified:** {date}
**Why it's hard:** {honest reason}
**Study approach:** {specific plan}
**Progress notes:** {what's improving}
**Status:** needs-work / improving / strong
```

---

### Async/Await Internals
**First identified:** Pre-build
**Why it's hard:** The event loop is invisible. Code looks sequential but isn't.
**Study approach:** Build a small demo: sync vs async DB queries under load. Measure difference.
**Progress notes:** Understand the concept, need to debug it under load
**Status:** needs-work

### Database Transactions and Isolation Levels
**First identified:** Pre-build
**Why it's hard:** Most tutorials skip isolation levels. The bugs they prevent are invisible until you have concurrent users.
**Study approach:** Deliberately cause a race condition without transactions, then fix it.
**Status:** needs-work

### System Design at Scale
**First identified:** Pre-build
**Why it's hard:** Hard to practice without real scale. Everything seems to work on localhost.
**Study approach:** Read "Designing Data-Intensive Applications" one chapter per week.
**Status:** needs-work


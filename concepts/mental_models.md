# Mental Models for Engineering
> Frameworks for thinking about common problems

---

## The Waiter Model (Async)
A sync program is a waiter who takes one order, goes to the kitchen, stands there watching food cook, brings it back, then takes the next order. An async program is a waiter who takes 20 orders, submits them all to the kitchen, and brings each dish out as it's ready. Same single person — radically different throughput.

## The Bathroom Key Model (Distributed Locking)
One key. One person at a time. To enter, you must hold the key. When you're done, you return the key. If you drop it and collapse, someone will find it eventually (TTL = the cleanup crew who checks after a timeout).

## The Ledger Model (Event Sourcing / Audit Logs)
A bank doesn't store "your balance is ₹5000." It stores every transaction: +₹1000 on Monday, -₹200 on Tuesday. The balance is computed from history. This means you can reconstruct any past state and audit any change. Our `booking_events` table is this ledger.

## The Snapshot vs Live Price Model
When you buy a flight ticket, the price is fixed at purchase time even if the flight's price changes tomorrow. Our slots snapshot the price at generation time. This prevents the nightmare of a customer paying ₹100, café changing price to ₹200, and the system being confused about what was agreed.

## The Circuit Breaker Model
An electrical circuit breaker trips when current exceeds safe levels — protecting the circuit. A software circuit breaker stops making calls to a failing service and returns fast errors instead of queuing up slow timeouts. Our booking endpoint returns 503 immediately if Redis is down rather than hanging.

## {Add new mental models as you discover them}





```
Title:  
Tiled - Playtest Alpha (v0.1.0-alpha.1)

Tiled is a local party quiz game where players reveal clue tiles, guess answers, and vote on close calls.  
This build is a playtest alpha focused on loop feel, pacing, and controller usability.


What this build is:  
This is an early local alpha focused on core loop testing.

What works:

1. Main game loop
2. Music and transitions
3. Vote flow
4. Controller support
5. Close-enough answers are auto-accepted for small typos (for example, “octagon” can pass for “octogon”).

Known issues:

1. Controller UI is still rough
2. Some dialog/UI polish is pending

How to run:

1. Launch the game executable
2. Start a local game from the host machine
3. Connect controllers using the in-game URL/QR flow

Playtest focus:

1. Game loop feel
2. Vote clarity
3. Pacing
4. Question variety
5. Controller confusion points

Feedback format:

1. What happened
2. What you expected
3. Steps to reproduce
4. Host OS and number of players

Versioning recommendation:

1. Build now: v0.1.0-alpha.1
2. Next content update: v0.1.0-alpha.2
3. First public-stable candidate later: v0.1.0-beta.1
```





---

TILED is a local-first party Q&A game where every guess is a risk and every close call can go to a vote.

Reveal clue tiles, weigh up the score potential, and decide when to lock in your answer. Exact answers score cleanly. Near-misses can trigger a player vote, turning the room into judge and jury.

Built with a hand-drawn look, quick rounds, and couch/classroom energy in mind.

This release is an early alpha focused on core loop feel, pacing, and controller usability.

**How to Play (60 Seconds)**

- Host starts a game and chooses settings.
- Players join on phones via the local link/QR.
- On each turn, reveal clue tiles to gather information.
- Submit your guess before confidence runs out.
- Exact answers score directly.
- “Close enough” answers can go to a player vote.
- First player to the target score wins.

**Known Issues (Alpha)**

- Controller UI is functional but still rough.
- Some transitions and dialog polish are still in progress.
- Balance/content tuning is ongoing (questions, pacing, scoring feel).

**Feedback I’m Looking For**

- Where did the flow feel confusing?
- Did scoring and vote outcomes feel fair?
- Which moments felt slow, unclear, or repetitive?
- Any controller pain points during join or play?

## Playtest Notes - 2026-05-26 (Rule Freeze Draft)

Goal: lock v1 gameplay decisions in docs before any implementation changes.

### Confirmed From Session

- Core loop is engaging with 2 players.
- Text readability and comprehension are improved.
- Quick disconnect handling worked: timeout, disconnected status, and return to lobby.
- Vote phase exposed rules clarity issues (especially scoring penalties).

### v1 Decisions to Lock First

1. Remove point deduction for wrong guesses.
2. Keep freeze/turn loss as the only punishment for wrong guesses.
3. Add a clear on-screen disconnect timeout message during network grace window.
4. Keep single-round pacing for v1 (short, replayable sessions).
5. Keep LPS as a true free-guess state (no hidden extra tile-turn behavior).

### LPS (Last Player Standing) Rule Draft

1. Trigger: only one active guesser remains.
2. Reveal state: show all remaining tiles immediately.
3. Guess state: one free final guess with no penalty.
4. Correct guess score: reduced award (proposed 60% of normal solve points; fallback 50% if tuning requires).
5. Wrong guess score: 0 points and round ends.

### Deferred for Post-v1 / Future Modes

1. Three-round match structure.
2. Double-point rounds.
3. Point-steal variants.
4. Additional reveal modifiers (for example, double reveal).

### Open Question (Pending Knock-on Effect)

- A new idea has been identified with possible balancing side effects.
- Action: capture the exact idea and expected knock-on impacts here before changing rules or code.

Template for capture:

1. Idea summary:
2. Intended benefit:
3. Possible knock-on impacts (scoring, pacing, fairness, UX clarity):
4. Test scenario to validate:
5. Decision:

## Playtest Addendum - 2026-05-26 (Brain Dump Capture)

Purpose: capture new knock-on thoughts before changing gameplay logic.

### Trigger A - Disconnect Visibility Is Too Easy to Miss

Observation:

- On first occurrence, disconnect state was not obvious to everyone.
- Phone lock/sleep can trigger a disconnect path that feels like "confusion first, explanation later."

Implication:

- Current logic is mostly correct, but UX feedback is too quiet.

Candidate v1 UX behavior:

1. Show a clear blocking message when a player disconnect timeout starts.
2. Show countdown text so players understand it is a grace window, not a hard fail.
3. On reconnect, show "player reconnected" confirmation.
4. On timeout expiry, show "player disconnected, returning to lobby" message.
5. Consider temporary pacing slowdown/pause during grace window (decision pending test).

### Trigger B - Scoring Incentive for Early Guessing Feels Too Weak

Observation:

- At target score 200, games can finish in roughly 5-7 questions.
- With wrong-answer deduction removed, guessing reluctance remains possible if early reward is too small.
- Current early/mid reveal bonus feels low (about +3 to +6), which may not create strong "buzz in early" behavior.

Current tuning reference (QnA scene constants):

1. Base points: 50 with optional difficulty multipliers.
2. Early bonus: +6.
3. Mid bonus: +3.
4. LPS reduced-award draft: 60% (with discussion of 65%).

Working hypothesis:

- If no deduction exists, the game still needs positive pressure to guess earlier.
- Increasing early reward is likely cleaner than reintroducing punishment.

Candidate tuning directions (document-only, no code yet):

1. Keep base points as-is; raise early/mid bonuses.
2. Keep early/mid bonuses; reduce base points slightly to amplify bonus importance.
3. Keep scoring but raise LPS reduced-award to 65% if LPS currently feels too weak.

### Recommended Next Playtest Matrix

1. Variant A (conservative): base unchanged, early +10, mid +5, LPS 60%.
2. Variant B (aggressive early guess): base unchanged, early +12, mid +6, LPS 60%.
3. Variant C (LPS stronger): base unchanged, early +10, mid +5, LPS 65%.

Success checks:

1. Do players voluntarily guess earlier without feeling forced?
2. Does scoring still feel fair when someone misses?
3. Does LPS feel exciting without becoming a dominant strategy?
4. Does average game length remain in the desired quick-session range?

### Rules Communication Note

- Round intro transitions are currently weak and not final.
- Once scoring is frozen, use intro transitions as the primary place to explain risk/reward and LPS behavior.

### Companion Docs Created

1. One-page session script: see `playtest-script-2026-05-26.md`.
2. Preset table for one-edit tuning swaps: see `qna-scoring-presets-v1.md`.
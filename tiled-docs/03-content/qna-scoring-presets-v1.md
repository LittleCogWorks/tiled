# QnA Scoring Presets (v1 Draft)

Status: document-only. No gameplay code changes yet.

## Active Preset

ACTIVE_PRESET: A

## Preset Table

| Preset | Base Points | Difficulty Multiplier | Early Threshold | Mid Threshold | Early Bonus | Mid Bonus | LPS Award |
|---|---:|---|---:|---:|---:|---:|---:|
| A (Conservative) | 50 | On | 0.40 | 0.70 | 10 | 5 | 60% |
| B (Aggressive Early Guess) | 50 | On | 0.40 | 0.70 | 12 | 6 | 60% |
| C (Stronger LPS) | 50 | On | 0.40 | 0.70 | 10 | 5 | 65% |

## One-Edit Switch Rule

When implementation starts, only change ACTIVE_PRESET (A/B/C) first.  
Do not mix values across presets during the same test cycle.

## Notes

1. Existing baseline constants in qna.gd are currently: base 50, early +6, mid +3.
2. Presets above are intended to strengthen early-guess incentive without reintroducing deduction penalties.
3. If game length inflates too much, reduce base points before lowering early bonuses.

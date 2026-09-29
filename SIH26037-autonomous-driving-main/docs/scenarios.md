# Canonical scenarios

| ID | Scene | Capability tested | Pass condition |
|---|---|---|---|
| 1 | Unmarked village road with a pushcart and slow two-wheeler | Free-space progress and static-object passing without lane paint | Reach x≈79 m, stop safely, no collision or road departure |
| 2 | Unsignalized urban crossroad with auto-rickshaw, pedestrian, and two-wheeler | Crossing-traffic prediction and yielding | Reach x≈79 m without collision |
| 3 | Arterial merge with slow truck and merging auto-rickshaw | Following, passing, speed adaptation | Reach x≈79 m without collision |
| 4 | Dense market with pushcart, auto-rickshaw, pedestrian, and two-wheeler | Narrow corridor and mixed actor avoidance | Reach x≈65 m without collision |
| 5 | Cattle appears at t=5 s near x=32 m, then crosses | Sudden risk escalation, braking/evasion, replanning | Reach x≈48 m or remain safely stopped, without collision |

All scenarios define actor geometry, road width, initial state, goal, timeout, and event motion in `sih.makeScenario` / `sih.actorStates`. They run headlessly. Custom dimensions represent local road users without requiring decorative meshes.

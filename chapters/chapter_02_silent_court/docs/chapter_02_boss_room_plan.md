# 无声舞会厅 Boss 房空间规划

Status: Stage 1 spatial plan; no Duchess combat implementation

## Arena dimensions

- PackedScene: `res://chapters/chapter_02_silent_court/scenes/rooms/09_silent_ballroom.tscn`
- World bounds: global X `27520..32128`, Y `-180..720` (4608×900; 3.6×1.25 viewports).
- Main floor: `y=612`, full-solid and level across the room.
- Usable combat lane: local X `320..4288` (3968 px / 3.10 screens).
- Player entry: local `(400,612)`; placeholder Duchess spawn `(3300,612)`.
- Boss activation trigger: local X `640`; entry Boss door local X `0`; post-Boss exit local X `4480`.
- Side safety margins: 320 px each. No solid column, table or chair enters the combat lane.

## Camera behavior

Before activation, Room 09 uses limits `(27520,-180,32128,720)`. On trigger, the same Player Camera remains active and horizontal limits stay within the Ballroom; smoothing resets once. No zoom or camera teleport is required. Debug framing trials in Stage 8 must place Player and Duchess at both attack-relevant extremes and prove neither combatant disappears during RapierThrust, Backstep or SideStep.

## Movement and attack lanes

- Rapier lane: 640 px clear forward line around floor height; no prop collision.
- FanSlash lane: at least 320 px clear around the Duchess.
- Backstep/SideStep: 480 px free on either side of her authored decision point.
- Player cross-through: the full 3968 px lane supports jump, double jump, Ground/Air Dash and rear access.
- Future phase-two afterimage routes: three non-solid guide lanes at floor, +72 px and +136 px visual elevations; they do not create platforms in Stage 8.
- Future dancer phantoms cross as non-body attack presentations and must not become permanent solid blockers.

## Room composition

Background may contain broken mirrors, stage, chandelier and faceless dancers. Columns remain in Mid/Far Background. Foreground curtains are restricted to the outer 160 px. All floor-edge and Boss tells remain unobscured.

The preceding Antechamber owns E15 and CP05. A 488 px safe buffer separates CP05 `(27032,612)` from the approach trigger `(27360,612)`; the Player can prepare without starting the Boss.

## Stage 8 placeholder contract

States: Idle, ElegantApproach, RapierWindup, RapierThrust, FanSlash, Backstep, SideStep, Recovery, Hurt, DeathPlaceholder. Stage 8 validates space, door/reset/camera and a single death completion only. It does not implement full balance, phase two, final pixel animation or dancers.

DeathPlaceholder must emit the room completion once, reopen the Boss door/exit, and present the required final line: `殿下一直在等你。` No Chapter III transition is implemented in this plan.

## Failure/reset behavior

- Player death closes active hitboxes, resets the placeholder Boss and reopens the entry state before respawning at CP05.
- CP05 activation alone never closes the door.
- Boss death remains cleared for the current disposable run and opens the exit.
- Leaving Debug Chapter Start or restarting with reset enabled returns Boss/door state to authored defaults.

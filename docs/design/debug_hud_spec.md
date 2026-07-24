# Main Debug HUD Specification

Status: implemented prototype, 2026-07-24

## Purpose and authority boundary

The Debug HUD exposes runtime state for development but owns no Health, Stamina, Player action, encounter, AI, or damage data. `MainDebugHudController` only controls presentation state and layout. Player and Enemy overlays read existing public diagnostic interfaces; the formal HUD remains signal-driven from its gameplay components.

F5 authority remains:

```text
res://scenes/main/main.tscn
```

## Runtime structure

```text
Main
├── Interface (CanvasLayer, MainDebugHudController)
│   └── DebugHudRoot (full-rect Control)
│       ├── Panel (top-left Player Debug ColorRect)
│       │   ├── Content (MarginContainer)
│       │   │   └── ActionScroll
│       │   │       └── ActionDebug (PlayerActionDebugOverlay)
│       │   └── DebugToggle (small fold Button)
│       ├── EnemyDebugPanel (bottom-left ColorRect)
│       │   ├── Content (MarginContainer)
│       │   │   └── EnemyScroll (ScrollContainer)
│       │   │       └── EnemyDebug (MainEnemyDebugOverlay)
│       │   └── EnemyDebugToggle (small fold Button)
│       └── DamageTestButton (120×28 development Button)
└── HUD (CanvasLayer, PlayerStaminaHud)
    ├── HealthContainer (196×56, signal-driven)
    ├── StaminaContainer (196×56, signal-driven)
    └── DeathOverlay
```

`Interface` and `HUD` remain separate CanvasLayers. F1 affects only `DebugHudRoot`; Health, Stamina, and the death presentation are never controlled by Debug visibility.

## Default state and input

- `debug_hud_visible = true`
- `debug_compact_mode = true`
- `enemy_details_expanded = false`
- F1 / `debug_toggle_hud`: show or hide the complete development HUD.
- F2 / `debug_toggle_compact`: switch both overlays between Compact and Expanded presentation.
- F3 / `debug_toggle_enemy_details`: independently reveal or fold Enemy details.
- The small `+`/`−` buttons mirror F2 and F3 without recreating any HUD node.

The three actions are registered in Input Map and do not overlap A/D, arrows, Space, Shift, or J.

## Compact field contract

Player uses two rows inside a 340×64 surface:

```text
PLAYER  STATE idle | HP 100/100 | STA 100/100
VX 0  VY 0 | DASH 0 | HURT 0.00 | INV 0.00
```

Enemy uses two rows inside a 380×68 bottom-left surface:

```text
ENC 01 | ALIVE 2 | ENGAGED 1 | ATK 0/2
Guard ×1 | Shield Guard ×1
```

The Enemy summary selects the latest activated authored group, or the first group before any activation. Type names are shortened only in Compact presentation.

## Expanded field preservation

Expanded Player presentation retains every previous diagnostic:

- floor and action/movement state;
- Ground/Air Dash type, sequence number, direction, VX/VY;
- animation, Stamina, regeneration mode/timer, Dash buffer;
- combo window, Dash Attack usage, Attack frame, Attack buffer/timer, chain window, input-to-hit time;
- Health/life state, invulnerability, Hurt stun, last damage;
- last source coordinates and knockback vector.

Expanded Enemy presentation retains every authored encounter and every valid enemy's existing `get_debug_summary()`, node name, X coordinate, activation, engaged/alive/attacking counts, damage, animation, phase, block/range/projectile data supplied by each type.

Both expanded surfaces use ScrollContainers. Compact mode omits verbose rendering only; it does not delete or stop collecting gameplay state.

## Layout and rendering

- Player Debug anchors to top-left with 12-pixel margins.
- formal vitals anchor to top-right with 12-pixel margins and a 196-pixel width.
- Enemy Debug anchors to bottom-left, ending 50 pixels above the lower edge.
- the 120×28 damage button anchors below Enemy Debug at the lower-left edge.
- panel background opacity is 66%; formal vitals use 82% for readability.
- Debug body text is 11 pixels; formal vitals use 11-pixel labels.
- Expanded widths and Enemy height are clamped from the viewport size; Action and Enemy details scroll rather than forcing panels off-screen.
- Godot's project-wide nearest texture filter remains unchanged. Debug text uses the engine font and Control layout; no texture filtering or mipmap setting was added.

With the existing `canvas_items` stretch and 1280×720 logical viewport, ordinary physical window changes retain the same authored logical safe area. The automated responsive-layout test additionally disables content scaling inside its isolated test process, then checks true Control bounds and panel separation at 800×540, 1280×664, 1280×720, and 1920×1080 before restoring project scaling.

## Update cost

- Player diagnostics reuse one Label and refresh only while visible.
- Enemy diagnostics reuse one Label, refresh every 0.15 seconds, and stop processing while hidden.
- No Label, panel, or signal connection is recreated when the mode changes.
- Formal Health and Stamina remain signal-driven and do not poll.

## QA evidence

- Compact: `docs/qa/debug_hud_compact00000000.png`
- Expanded: `docs/qa/debug_hud_expanded00000000.png`
- Debug hidden: `docs/qa/debug_hud_hidden00000000.png`

The hidden capture intentionally retains formal Health/Stamina and removes the Player/Enemy panels plus the development damage button.

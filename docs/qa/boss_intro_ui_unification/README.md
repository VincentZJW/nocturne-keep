# CH2–CH4 Boss Intro UI Unification QA

Status: **PASS** for the requested Boss-intro presentation scope.

Main authority: `res://scenes/bootstrap/main_bootstrap.tscn` at the saved
1280×720 debug viewport. Chapter III Edran remained unchanged and is the sole
visual/source-value reference.

## Edran UI source of truth

| Property | Saved formal value |
|---|---|
| Font | Godot engine default font plus its existing fallback; no local `Font` override |
| Boss name | One centered bilingual line, 28 px |
| Secondary title | 13 px |
| Dialogue and speaker | One Label, 16 px; speaker on the first line |
| Phase title | English 25 px; Chinese 17 px |
| Name outline | 6 px, `Color(0.015, 0.015, 0.03, 1)` |
| Secondary outline | 5 px, same outline color |
| Name color | `Color(0.88, 0.80, 0.62, 1)` |
| Secondary color | `Color(0.65, 0.70, 0.76, 1)` |
| Dialogue color | `Color(0.88, 0.84, 0.74, 1)` |
| Phase colors | English `Color(0.63, 0.84, 0.90, 1)`; Chinese `Color(0.78, 0.72, 0.62, 1)` |
| Shadow / spacing | No local shadow, letter-spacing, or line-spacing override |
| Panel | Existing default `PanelContainer` style; no local color/opacity/style override |
| Intro CanvasLayer | 70 |
| Boss title bounds | `(318,244)` with size `(644,100)` |
| Dialogue anchors/margins | Bottom-wide; left `180`, top `-132`, right `-180`, bottom `-42`; minimum text height `84` |
| Phase title bounds | `(280,214)` with size `(720,110)` |
| Alignment | Horizontal center; dialogue also vertically centered; smart word wrap |
| Name fade | `0.18 s` in, `0.70 s` hold, `0.24 s` out |
| Phase fade | `0.18 s` in, `0.58 s` hold, `0.24 s` out |
| Dialogue reveal | No typewriter; full line is shown immediately |
| Dialogue advance | Automatic; `0.72 s` normal line and `1.00 s` final intro line |
| Skip | None added because the reference has none |
| Camera | `0.65 s` reveal; `0.39 s` return, sine in/out |
| Music | 6 dB dialogue duck over `0.18 s`; restore over `0.25 s` |
| Boss HUD | Top-wide offsets `340,18,-340,92`; margins `10,6,10,6`; name 12 px; health 10 px; poise 6 px; state 9 px |

## Runtime comparison

| Style | Chapter II | Chapter III reference | Chapter IV |
|---|---|---|---|
| Font resource | Default/fallback | Default/fallback | Default/fallback |
| Boss name size | 28 px | 28 px | 28 px |
| Secondary size | 13 px | 13 px | 13 px |
| Dialogue/speaker size | 16 px | 16 px | 16 px |
| Speaker format | `SERAPHINE` / `NIGHT WARDEN` first line | `EDRAN` / `NIGHT WARDEN` first line | `ORMUND` / `NIGHT WARDEN` first line |
| Dialogue panel | Exact reference bounds and default panel style | Source of truth | Exact reference bounds and default panel style |
| Name/phase anchors | Exact reference bounds | Source of truth | Exact reference bounds |
| Name fade/hold | `.18/.70/.24` | `.18/.70/.24` | `.18/.70/.24` |
| Phase fade/hold | `.18/.58/.24` | `.18/.58/.24` | `.18/.58/.24` |
| HP header | Reference top HUD geometry | Source of truth | Reference top HUD geometry |
| Phase II reveal | Dedicated reference-style title | Source of truth | Dedicated reference-style title |

Chapter II keeps its existing story lines, mask transformation, ballroom art,
Boss values, attacks and BGM content. Chapter IV keeps its existing bilingual
story-body lines, prison presentation, Boss values, attacks and BGM content.
Only speaker formatting and line wrapping changed; story wording did not.

## Runtime evidence

All images were captured through `MainBootstrap`, not by opening Boss scenes
directly.

| State | Chapter II | Chapter III reference | Chapter IV |
|---|---|---|---|
| Dialogue | [image](ch2_01_dialogue.png) | [image](ch3_01_dialogue_reference.png) | [image](ch4_01_dialogue.png) |
| Boss name | [image](ch2_02_boss_name.png) | [image](ch3_02_boss_name_reference.png) | [image](ch4_02_boss_name.png) |
| HP HUD | [image](ch2_03_hp_bar.png) | [image](ch3_03_hp_bar_reference.png) | [image](ch4_03_hp_bar.png) |
| Phase II | [image](ch2_04_phase_02.png) | [image](ch3_04_phase_02_reference.png) | [image](ch4_04_phase_02.png) |

## Commands and results

Exact executable: `/Users/vincentz/Downloads/Godot.app/Contents/MacOS/Godot`
(Godot `4.7.1.stable.official.a13da4feb`).

```text
--headless --editor --path . --quit-after 3
PASS: project import and GDScript parse; only the expected forced-quit scan warning.

--headless --path . --script tests/ui/test_boss_intro_ui_contract.gd
PASS: BOSS_INTRO_UI_CONTRACT: CH2=EDRAN_REFERENCE CH3=UNCHANGED

--headless --path . --script chapters/chapter_02_silent_court/tests/test_hollow_duchess_presentation_phase.gd
PASS: intro=5 transition=10 phase2=0.85/80

--headless --path . --script chapters/chapter_02_silent_court/tests/test_hollow_duchess_main_integration.gd
PASS: formal Chapter-II Main integration and HUD composition.

--headless --path . --script chapters/chapter_03_chapel_of_thirteen_echoes/tests/test_edran_b4_b7_full_boss.gd
PASS: reference transition, Phase-II attacks, death and reward interfaces.

--headless --path . --script chapters/chapter_04_drowned_underkeep/tests/scenes/test_chapter_04_q4_boss_flow.gd
PASS: MainBootstrap, Boss P1/P2/death and post-Boss route.

--path . --script tests/ui/capture_boss_intro_ui_unification.gd -- ch2|ch3|ch4
PASS: four Main-route captures per chapter, 12 total, all 1280×720.
```

The Chapter-II presentation/capture harness can report ObjectDB/resource
teardown warnings after a successful forced test exit. The targeted runtime
captures and assertions produced no gameplay script error, missing-node error,
or UI-contract failure.

## Manual acceptance

Start with `CH2_BOSS`, observe the entire automatic dialogue → name reveal →
HUD → camera return → combat flow, then lower the Duchess below her transition
threshold to inspect the Phase-II title. Repeat with `CH3_BOSS` and
`CH4_BOSS_PHASE_01`; compare against the linked screenshots above. Confirm feel,
readability and camera composition manually; automated checks do not certify
subjective pacing.

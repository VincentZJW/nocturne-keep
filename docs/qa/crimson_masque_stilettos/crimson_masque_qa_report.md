# Crimson Masque Stilettos Main QA

Engine: Godot 4.7.1 Standard, GL Compatibility, Apple M4

The graphical runner starts the saved `res://scenes/bootstrap/main_bootstrap.tscn`, selects Chapter II `CH2_BOSS` through the guarded Debug profile, completes the real post-Boss controller, collects the fixed WeaponPickup, swaps Player/HUD state and traverses the existing passage into Chapter III.

| Evidence | Purpose | SHA-256 |
|---|---|---|
| `01_world_pickup_main.png` | fixed world pickup at the saved Boss reward anchor | `91bc83d09b24022b7933276e9adde06665c7bd123720472a99959e94079b44ce` |
| `02_acquisition_panel_main.png` | bilingual acquisition panel and HUD T3 14/28 | `5d73dc15623f581a6d0c630ffe45e24c86546cd8351d636413dc7cb32b6e241e` |
| `03_player_idle_main.png` | equipped straight ceremonial pair in Idle | `c04b8060998285d02e42a2a8b25ce2a5980030f7e0ce44644592790bf2582db6` |
| `04_normal_attack_main.png` | paired forward thrust normal Attack | `55ec5c7a0f7bf536d858a6cad7b7898c254c04df0eaca1eea3714037a4df8ef7` |
| `05_dash_attack_main.png` | longer paired thrust Dash Attack | `7e0cf0f554dad0f5640a9b54a1396ff2244b0b2c7946f8321a6032ccda8323c3` |
| `06_chapter_03_entry_main.png` | persisted equipped reward after Main transition | `9e52ab2c35358c98bdcdd921b48afafa0f4ec1b9a61b4b39da94c6a7c1084016` |

All images are real 1280×720 RGBA viewport captures. Automated tests separately prove exact 14/28 damage, attack-id deduplication, both reload branches, unique inventory ownership and the Chapter III Start Profile.

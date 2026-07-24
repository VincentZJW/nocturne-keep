# Chapter II Damage Scaling Boundary

This milestone establishes only a numeric runway: Player weapon damage is Resource-driven and Chapter I target pools use 10-point units. Chapter II content, shops, upgrades, affixes and additional weapons are not implemented.

Chapter II begins with Ravenfang Daggers at 12 normal / 24 Dash damage. Recommended target pools are:

| Future target role | Recommended HP | Intended Ravenfang normal hits |
|---|---:|---:|
| base enemy | 36–48 | 3–4 |
| special enemy | 60–72 | 5–6 |
| heavy/high-defense body | 72–96 | 6–8 |
| optional heavy shield | 36–48 | 3–4 shield hits |
| elite | 120–180 | 10–15, with mechanics rather than pure HP |

Adjacent story weapons should normally improve core damage by roughly 10–20%, never double each chapter. A future weapon should also earn a readable visual or behavior identity, but no additional attack property is introduced here.

Future tuning must add `WeaponData` resources and change enemy config Resources, never scene Hitbox copies. Player HP, Stamina, incoming damage and timings remain independent; the 10× enemy-HP migration is not permission to multiply enemy damage.

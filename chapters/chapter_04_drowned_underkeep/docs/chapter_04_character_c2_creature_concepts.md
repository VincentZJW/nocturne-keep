# Chapter IV CH4-C2 Creature Concept Art / 第四章非人形敌人原画

- Stage: `CH4-C2`
- Status: `CONCEPT COMPLETE / USER ACCEPTANCE PENDING`
- Baseline: `chapter_04_character_roster_c0.md`
- Provenance: original text-only built-in image generation; no third-party or commercial character source

## Deliverables

| Character | Concept sheet | SHA-256 |
|---|---|---|
| Mirefin Raider | `res://chapters/chapter_04_drowned_underkeep/assets/enemies/mirefin_raider/concept_art/mirefin_raider_concept_sheet.png` | `47378583a3a49708cc241ab7f8629b504ae7c03f74881708e8d55f6aa037d71d` |
| Bog Toad | `res://chapters/chapter_04_drowned_underkeep/assets/enemies/bog_toad/concept_art/bog_toad_concept_sheet.png` | `381e4c660378ea50051503e60cb646a9d17650b598a991a0a7e087d2d88b2954` |
| Sewer Maw | `res://chapters/chapter_04_drowned_underkeep/assets/enemies/sewer_maw/concept_art/sewer_maw_concept_sheet.png` | `7fd9a62b370632931b3b8414be735dd048d5d45583f79e15381d079920286650` |

All boards are `1536×1024` PNG production references. They are not runtime textures.

## Locked silhouettes and motion

### Mirefin Raider

- Fish-bone skull, exposed gill cage, irregular layered dorsal fins and a strongly hunched spine establish the head-first silhouette.
- Long muscular forearms and webbed claws lead the attack language; compact water-adapted legs keep the body low without turning it into a human with fins.
- The single broken ankle restraint remains visible in every runtime pose. Water-skitter, claw and locked lunge must preserve it without changing attachment.

### Bog Toad

- A broad true amphibian skull, four complete load-bearing limbs and oversized folded hind legs own the silhouette.
- Bone nodules, moss, mud, throat chain and swollen glands separate materials without relying on random pixel noise.
- Leap animation must compress the rear legs, show a clear airborne body and end in a heavy recovery; no oval body with line limbs is acceptable.

### Sewer Maw

- Ground-hugging asymmetrical body, long layered mouth, nested tooth rows, short claw limbs and embedded drain fragments define the role.
- Hidden state shows only the armored spine/water disturbance; the complete mouth cannot become active before the bubble telegraph.
- The runtime sprite must remain substantially smaller than Bog Toad and cannot inherit a crocodilian upright gait despite the armored head reference.

## C4 pixel-production invariants

- Runtime art is redrawn at `128×96`, `128×128` and `96×96`; it is never a scaled copy of these paintings.
- Every frame retains head, torso/body mass, functional limbs, material separation and signature debris/restraint.
- Nearest filtering, no mipmaps, integer origin and consistent ground/body anchor are mandatory.
- Each attack owns readable windup/active/recovery poses, and the weaponless creatures never use line-only appendages.

## Scope boundary

C2 creates concept authority only. SpriteFrames, AI, Hitboxes, Main instances and trial content belong to C4/C7 and are not claimed here.

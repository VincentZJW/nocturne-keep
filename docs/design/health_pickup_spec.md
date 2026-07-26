# Health Pickup Specification

`small_health_pickup.tscn` restores 10 HP and `large_health_pickup.tscn` restores 20 HP. Both use transparent original Gothic vial drawings made from integer-aligned Godot canvas rectangles.

- Only a living Player can collect; full-health contact leaves the vial present.
- `HealthComponent.heal()` owns clamping and the Health HUD updates through its signal.
- Consumption disables monitoring and queues exactly once.
- Healing does not clear Hurt, grant invulnerability, resurrect, or alter death flow.
- Feedback is a small dark-red `+10 HP`/`+20 HP` label for 0.75 seconds plus six short-lived 2×2 dark-red pixels; it does not pause combat.
- Lifespan is 20 seconds with an 8 Hz blink in the final 3 seconds.

Normal-enemy vial generation is governed upstream by the shared dynamic loot profile, not by pickup code. Full Health has 0% small/large-vial probability; Light damage uses 28%/7%, Heavy damage 35%/15%, and Critical Health 25%/40%. The component snapshots Health only at enemy death. Contact-time collection checks remain unchanged, so an unneeded vial is never consumed even if Player Health changed after it spawned.

# Chapter I Checkpoint and Respawn Specification

The existing `PlayerRespawnController` remains the single respawn authority. New `CheckpointTrigger` Area2D nodes only update its Marker2D reference and then disable themselves.

| Checkpoint | Main node path | Approx. x |
|---|---|---:|
| Initial awakening | `World/SpawnPoint` | 320 |
| After tutorial | `World/Checkpoints/AfterTutorial` | 2580 |
| After Dark Forest | `World/Checkpoints/AfterForest` | 3780 |
| After Castle Outskirts | `World/Checkpoints/AfterOutskirts` | 4780 |
| Before Boss | `World/CastleEntranceArea/BossCheckpoint` | 5480 |

Checkpoints do not refill stamina or health merely by crossing them. The established Boss entry behavior still restores resources for the Boss test. Respawn continues to run the complete body/ghost sequence and resets player velocity, action state, health, stamina, and control. Tutorial progress remains on Main and is not reset by Player respawn.

Encounter persistence after respawn is intentionally limited to the current runtime state; a save/checkpoint persistence system is outside this milestone.

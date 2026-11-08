# Static rule reference

**All numeric thresholds are review heuristics chosen for this project.** They are *not* official Roblox limits, defects, or measured performance impacts. Results depend on scan scope, dynamic spawning, distance, player hardware and visual context.

| Rule ID | Condition | Output | Possible false positives |
| --- | --- | --- | --- |
| `MESH_COLLISION` | `MeshPart.CollisionFidelity == PreciseConvexDecomposition` | Per-mesh REVIEW card | Complex interactive geometry legitimately needs precision; mesh may not be actively colliding |
| `PARTICLE_RATE` | Enabled `ParticleEmitter.Rate >= 150` | Per-emitter REVIEW card | Effect is short-lived, off-screen, on quality scaling, or artistic priority |
| `PARTICLE_ESTIMATE` | Enabled emitter `Rate * Lifetime.Max >= 500` | Per-emitter REVIEW card | This is only a configured upper estimate; actual visible particles may differ |
| `PART_COUNT` | Count of `BasePart`s (excluding `Terrain`) `>= 5000` | Scope INFO card | Well-streamed, optimized content can contain many parts |
| `UNANCHORED` | Count of unanchored `BasePart`s `>= 200` | Scope REVIEW card | Unanchored does not imply active simulation; avatar parts or intended physics |
| `SHADOW_LIGHTS` | Count of enabled `Light`s with `Shadows == true` `>= 12` | Scope REVIEW card | Lights can be dispersed, culled, or not simultaneously visible |
| `EMITTER_COUNT` | Count of enabled `ParticleEmitter`s `>= 80` | Scope INFO card | Effects can be spread over a large map and mostly off-screen |
| `DECAL_COUNT` | Count of `Decal` and `Texture` instances `>= 600` | Scope INFO card | Count alone says nothing about draw calls or visibility |
| `PRECISE_COLLISION_TOTAL` | Precise-collision mesh count `>= 50` | Scope INFO card | Large counts might be intentional or outside runtime hot paths |
| `PRECISE_RENDER_TOTAL` | `MeshPart.RenderFidelity == Precise` count `>= 100` | Scope REVIEW card | The scene may already meet performance targets |

## Safety and scope

- Game hierarchy is never changed by the plugin. Clicking a finding only changes **Explorer selection** using `Selection:Set`.
- A scan of a selection includes the selected roots and all their descendants. Multiple overlapping selections are counted once.
- For large projects, finding cards/report entries are limited to the first **250** triggers; a counter indicates omitted triggers. The displayed results are sorted by severity and rule identifier **after** collection. Therefore, when the cap is exceeded, later triggers may not appear even if important.
- A scan may run for some time on large maps. It yields every 1000 objects, and starting another scan supersedes a previous scan.
- The plugin reports a static point-in-time snapshot. It does not monitor object/property changes until you rescan.
- `PARTICLE_ESTIMATE` assumes continuous emission at configured `Rate` for the longest configured lifetime and ignores `Emit()` bursts, throttling and visibility. It is **not** a live-particle metric.

## How to validate

Profile an actual performance concern in Studio using performance metrics and MicroProfiler, and cross-check the rule's object and usage at runtime. Never lower visual or physics fidelity solely to silence a warning.

Sources:
- https://create.roblox.com/docs/performance-optimization/improve
- https://create.roblox.com/docs/reference/engine/classes/ParticleEmitter
- https://create.roblox.com/docs/workspace/collisions

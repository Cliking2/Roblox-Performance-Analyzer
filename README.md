# Roblox Performance Analyzer

**A free, open-source, read-only performance review plugin for Roblox Studio.**

> **Status: v1.0.0 release candidate.** Source was reviewed and packaged, but **has not been run inside Roblox Studio** in the development environment. Please validate it in a disposable place before promoting it as tested or stable.

**Language:** Luau · **License:** MIT · **Dependencies:** none · **Network:** none

Roblox Performance Analyzer performs *static, heuristic checks* on the `Workspace` or an Explorer selection. It identifies candidates for **manual investigation**, not measured bottlenecks. It never changes place objects (except selecting an item in Explorer when you click a finding).

## Features

- **Scan Workspace** or **Scan selection** (supports multiple selected roots and avoids double-counting).
- Report the number of inspected instances, `BasePart`s, unanchored parts, precise collision meshes, precise-render meshes, particle emitters, active emitters, shadow-enabled lights, and decals/textures.
- Flag individual `MeshPart`s with `CollisionFidelity.PreciseConvexDecomposition`.
- Flag enabled `ParticleEmitter`s with configured `Rate >= 150` or with `Rate × Lifetime.Max >= 500` as *review triggers*.
- Identify large counts of potential physics/rendering review targets.
- **Click any finding** to select the related instance in Explorer.
- View a plain-text report containing the scan scope, counts, rule IDs and instance paths.
- Yield periodically while scanning large scenes, so Studio can continue handling input.
- Source code can be read and audited before installation. No HTTP, analytics, automatic edits or external dependencies.

## What this tool does **not** do

- It **does not measure FPS, frame timings, draw calls, network latency, memory use, or script execution time**.
- It cannot inspect runtime script loops or all objects spawned dynamically after the scan.
- It does not infer if an unanchored object is physically simulated in a given runtime situation.
- `Rate × Lifetime.Max` is an **illustrative upper estimate of sustained emission** from configuration, not a measured particle population, and excludes manual `Emit()` bursts, throttling and visibility.
- It does not know which meshes or lights are actually visible to a player.
- Thresholds are **project-specific review triggers**, **not official Roblox pass/fail limits**. A finding may be intentional or harmless.
- Finding none does **not** certify that an experience is optimized.

Use the **MicroProfiler**, Studio performance tools, and real-device testing to establish actual performance impacts.

## Installation: Roblox Studio

1. Download this repository as source code (or clone it).
2. Open `plugin/RobloxPerformanceAnalyzer.lua` in a text editor and copy the entire source.
3. Open **Roblox Studio** and create/open a **disposable test place**.
4. In **Explorer > ServerStorage**, insert a regular **Script** as a temporary container. Paste the source.
5. With the Script selected, use Roblox Studio's **Save as Local Plugin** option and confirm the save. The plugin global exists only when Studio runs it as a plugin.
6. Delete the temporary Script from `ServerStorage` after saving; do **not** run the code as a normal game Script.
7. Click **Performance Analyzer** on the **Plugins** toolbar to open the pane. Click **Scan Workspace**.

See [French install guide](docs/INSTALL_FR.md) and the official [Roblox Studio plugin documentation](https://create.roblox.com/docs/studio/plugins).

## Quick test (recommended before public promotion)

1. Use a disposable place.
2. Copy `examples/create_demo_scene.lua` to Studio's **Command Bar** and run it once.
3. Select `Workspace/PerformanceAnalyzer_Demo` in Explorer.
4. Click **Scan selection**.
5. Expect at least these two findings: `PARTICLE_RATE` and `PARTICLE_ESTIMATE`.
6. Click a finding: Explorer selection should jump to `HighRateTestEmitter`.
7. Click **Report** and inspect its text, then switch back with **Findings**.
8. Delete `Workspace/PerformanceAnalyzer_Demo` after testing.

For the full acceptance checklist, see [VALIDATION.md](docs/VALIDATION.md).

## Project layout

```text
plugin/RobloxPerformanceAnalyzer.lua    Standalone Studio plugin source
examples/create_demo_scene.lua          Disposable demo scene fixture
docs/INSTALL_FR.md                      Installation guide in French
docs/RULES.md                           Rule catalog and limitations
docs/VALIDATION.md                      Manual tests and expected results
CONTRIBUTING.md                         Contribution process
CHANGELOG.md                            Project history
LICENSE                                 MIT license
```

## Rule rationale and Roblox references

All reference links below point to official Roblox Creator Hub documentation. These explain why the properties are useful review candidates; they do **not** endorse this plugin's numeric thresholds.

- [Improve performance](https://create.roblox.com/docs/performance-optimization/improve)
- [ParticleEmitter API](https://create.roblox.com/docs/reference/engine/classes/ParticleEmitter)
- [Mesh collision fidelity](https://create.roblox.com/docs/workspace/collisions)
- [Plugins API](https://create.roblox.com/docs/reference/engine/classes/Plugin)
- [Performance optimization overview](https://create.roblox.com/docs/performance-optimization)

## Roadmap (ideas, not shipped)

- Optional user-editable thresholds
- JSON/CSV export with explicit permission
- More context-sensitive checks and lower false-positive rates
- Test fixture automation in a Roblox Studio test workflow
- Translations and accessibility improvements

## Contributing

Bug reports and pull requests are welcome. Please test rule changes in Roblox Studio, document false positives and cite relevant official API documentation. See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

[MIT](LICENSE). This is an independent community project, not affiliated with or endorsed by Roblox.

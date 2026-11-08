# Manual validation checklist

No Roblox Studio instance is available in the authoring environment. All tasks below are **NOT YET EXECUTED**. Check each item only after personally verifying it in Studio.

- [ ] **Install:** The plugin installs via *Save as Local Plugin* and produces a `Performance Analyzer` toolbar button without output errors.
- [ ] **Open/close:** The button toggles a dockable panel; closing and reopening works.
- [ ] **Empty selection:** `Scan selection` displays guidance instead of crashing.
- [ ] **Demo:** Run `examples/create_demo_scene.lua` once using the Command Bar in a disposable place.
- [ ] **Selection scan:** Select `PerformanceAnalyzer_Demo` and click `Scan selection`.
- [ ] **Rules:** `HighRateTestEmitter` produces `PARTICLE_RATE` (`220/s`) and `PARTICLE_ESTIMATE` (`1100` upper estimate).
- [ ] **Explorer jump:** Clicking a demo finding selects the emitter in Explorer.
- [ ] **Report:** `Report` displays counts, rule IDs, paths and the caveat about FPS. `Findings` restores the cards.
- [ ] **Workspace scan:** `Scan Workspace` includes the same demo findings, possibly plus other scene findings.
- [ ] **Multiple selection:** Select the model **and** its child Part; `Scan selection` does not count the shared descendants twice.
- [ ] **Non-mutation:** The plugin does not modify game objects, scripts, values or files during the scan.
- [ ] **Cleanup:** Delete `Workspace/PerformanceAnalyzer_Demo` after validation; rescan and confirm those findings are gone.
- [ ] **Large place:** Test performance and UI responsiveness on a larger place.
- [ ] **Official metrics:** Confirm that flagged objects actually matter in an appropriate Studio/profiler scenario before drawing conclusions.

If a test fails, please open a GitHub issue with the Roblox Studio version, repro steps, output messages and the smallest place file demonstrating the problem (no private assets).

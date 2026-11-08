# Contributing

Thank you for helping make Roblox Performance Analyzer more useful for Roblox developers.

1. Search existing issues before opening a new one. Include repro steps and the current Studio version.
2. Keep the plugin read-only: do not add automatic place modifications, telemetry, network access, or file uploads without explicit review and user consent.
3. Treat performance thresholds as **heuristics**, not platform limits. Describe when a proposed rule would produce false positives and cite official Roblox documentation.
4. Test changes in a disposable Roblox Studio place. Update `docs/VALIDATION.md` and the rule table when behavior changes.
5. Keep the install path simple: `plugin/RobloxPerformanceAnalyzer.lua` must remain usable as a standalone local plugin script.
6. Do not include private Roblox places, copyrighted third-party assets, credentials or personal data in bug reports or pull requests.
7. Open a pull request describing the issue, implementation, testing, limitations and any risks.

A good first contribution is a reproducible test case, a small UI accessibility fix, or a documentation improvement.

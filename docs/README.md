# Beer Counter docs

| To learn about | Read |
|---|---|
| Why the app exists, its scope, and its terminology | [project-overview-pdr.md](project-overview-pdr.md) |
| Boundaries and the reasoning behind each decision | [system-architecture.md](system-architecture.md) |
| Installing the SDK, building, and copying the app to the watch | [deployment-guide.md](deployment-guide.md) |
| Code, test, and commit conventions | [code-standards.md](code-standards.md) |
| On-watch interface rules | [design-guidelines.md](design-guidelines.md) |

Two files from the project's standard layout are skipped on purpose. `codebase-summary.md` isn't needed because the source is small enough for the [boundaries table](system-architecture.md#boundaries) to navigate. `project-roadmap.md` isn't needed because no direction beyond the current scope has been agreed.

Code decides what the app does. These docs only record reasons, constraints, and pointers to the owner of each thing, so when a doc disagrees with `source/` or the `Makefile`, trust the code and fix the doc.

# Architecture

## Boundaries

| Part | Owns |
|---|---|
| `source/BeerSession.mc` | Session state, storage, auto-reset, titles, and calculations. Knows nothing about the screen. |
| `source/BeerCounterView.mc` | Drawing, animation, sensor reads, and input handling. |
| `source/BeerCounterApp.mc` | The app entry point. |
| `source/BeerSessionTest.mc` | Unit tests for session logic. |
| `tools/mtp-put.c` | Copies a file to `GARMIN/Apps` and reads it back to verify. |
| `tools/make-icons.py` | Generates every PNG in `resources/drawables/`. |

## Decisions

| Decision | Why | Rejected |
|---|---|---|
| Build a Watch App | It has the most memory for animation and bitmaps | Glance and watch face, which have far lower memory limits |
| Write to storage after every change | The app can exit at any time, and losing the count is the worst failure for this product | Saving only on exit |
| Derive elapsed time from stored timestamps | Time stays correct while the app isn't running | A continuously running counter |
| Check auto-reset when the app opens | The count only has to be right when someone is looking, so nothing needs to run in the background | Background service |
| Draw the mug with shapes through `Dc` | Graphics memory is shared with the system, and out-of-memory errors may only appear on real hardware | Monkey Motion, multiple full-screen layers |
| Use one view that switches between main and summary by session state | The confirmation dialog closes itself after a response, so no navigation between views is needed, and the summary returns on its own when the app reopens | Pushing a separate summary view |
| Keep an ended session in storage until the user starts a new one | The summary is the thing to show off, so exiting must not lose it | Clearing the count as soon as a session ends |
| Use `InputDelegate` with `onTap` and `onKey` | It separates screen taps from the START button, so a tap can't be read as a select action | `BehaviorDelegate` |
| Leave the Back button unhandled | Back exits by default, and the count is already in storage | Back opening the end-session dialog |
| Read stress from `ActivityMonitor.Info.stressScore` | It is available on the FR165 and needs no extra permission | `SensorHistory.getStressHistory`, which needs its own permission |
| Hide beers per hour for the first 15 minutes | Dividing by a very short duration gives absurd numbers | Showing it from the first beer |
| Write our own `tools/mtp-put.c` | `mtp-sendfile` can't find the destination folder on the FR165 because of a metadata read error | The stock `libmtp` tools |

## Accepted limitations

- Max heart rate only counts while the app is open, so it can be lower than the real peak.
- Stress on the summary screen is the value at viewing time, not the session's peak.
- Undo only reverts the latest tap and is gone once the app reopens.

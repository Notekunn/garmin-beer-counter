# Code standards

## Keep logic away from the screen

Anything that doesn't need a `Dc` belongs in `BeerSession`, and time-based functions take `now` as a parameter. That lets tests cover auto-reset and beers per hour without waiting for real time.

## Tests

- `make test` runs the unit tests. Open the simulator first with `connectiq` from the SDK's `bin` folder.
- `monkeydo` exits with code 1 even when every test passes, so the `Makefile` reads the result line instead. Don't switch it back to checking the exit code.
- Unit tests only cover session logic. Drawing, taps, vibration, and sensors have no automated tests, so any change to `BeerCounterView.mc` must be tried on the real watch.
- The simulator can't stand in for real hardware on graphics memory; see the [reasoning](system-architecture.md#decisions).

## Resources

The PNG files in `resources/drawables/` are generated. To change an icon, edit `tools/make-icons.py` and rerun it instead of editing the PNG.

## Commits

Use conventional commits. `bin/` and `plans/` stay out of git.

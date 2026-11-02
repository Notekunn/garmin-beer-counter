# Beer Counter

A Connect IQ watch app for the Garmin Forerunner 165 that counts beers during a drinking session, built to be shown off from the wrist. Tap to add a beer, watch the mug fill up, earn silly titles, and finish with a summary screen. It runs entirely on the watch, with no phone, network, or server.

## Quick start

You need the Connect IQ SDK with the `fr165` device, `libmtp`, and a developer key. The [deployment guide](docs/deployment-guide.md) covers the setup.

```sh
make build      # compile bin/BeerCounter.prg
make test       # run unit tests; the simulator must be open
make sideload   # build, copy to the connected watch, and verify
```

## Documentation

Start at the [docs index](docs/README.md).

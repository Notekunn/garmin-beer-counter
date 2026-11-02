# Build and install on the watch

The app is only sideloaded onto the project owner's own Forerunner 165. Build and copy commands live in the `Makefile`.

## Machine setup

- Java.
- **Connect IQ SDK:** install the SDK and the `fr165` device through SDK Manager, available from [Garmin's SDK page](https://developer.garmin.com/connect-iq/sdk/). This can only be done in the SDK Manager interface. The `Makefile` reads the active SDK from `current-sdk.cfg`, so changing versions needs no path edits.
- **`libmtp`:** `brew install libmtp`. macOS has no built-in MTP support.
- **Pillow:** only needed to rerun `tools/make-icons.py`.

## Developer key

| Field | Details |
|---|---|
| Location | `~/.garmin/developer_key.der`, outside the repository; the path is set in the `Makefile` |
| Creating one | Run `openssl genrsa` with a 4096-bit key, then `openssl pkcs8 -topk8 -outform DER -nocrypt` to produce the `.der` file |
| Limits | Never commit the key or copy it into the repository. Back it up separately, because a future store release would need every update signed with the same key |

## Copy the app to the watch

| Field | Details |
|---|---|
| When to use | Trying a build on real hardware |
| Scope | The Forerunner 165 connected over USB, folder `GARMIN/Apps` |
| Source of truth | The `sideload` target in the `Makefile` and `tools/mtp-put.c` |
| How | Unlock the watch, leave it on the normal watch face, plug in the cable, run `make sideload`, then unplug so the watch loads the app |
| Limits | Each run deletes and rewrites `BeerCounter.prg` only. Close Garmin Express and OpenMTP first to avoid fighting over the connection |
| Verification | The command prints `verified GARMIN/Apps/BeerCounter.prg` after reading the file size back. Then open the app on the watch |
| Fallback | OpenMTP, which is unverified on this machine. Removing a sideloaded app requires Garmin Express |

## When the Mac can't see the watch

`libmtp` only works when the watch is in MTP mode, which is product ID `0x5150` (Garmin vendor ID `0x091e`).

```sh
ioreg -r -c IOUSBHostDevice -l -w0 | grep -E '"(idVendor|idProduct)"'
```

This prints decimal values, so MTP is `20816` and the Garmin vendor is `2334`. A product ID of `3` means the watch is in a different USB mode, and `libmtp` reports no device. Unplugging, leaving the watch on its normal watch face, and plugging back in has fixed this before.

The `is UNKNOWN in libmtp` line on connect is a harmless warning, because the FR165 isn't in `libmtp`'s device list.

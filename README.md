# SmallReSiever

RSS reader for GNUStep using the [SmallStep](../SmallStep) API and [libxml2](https://gitlab.gnome.org/GNOME/libxml2) (FOSS).

## Features

- Fetch RSS 2.0 and Atom 1.0 feeds from any HTTP(S) URL
- Parse feeds with libxml2 (C, free software)
- List items in a table; show title, link, date, and content in a text view
- Add Feed (Cmd+O) and Refresh (Cmd+R); Quit (Cmd+Q)
- Feed fetching runs on a background thread so the UI stays responsive

## Dependencies

- **GNUStep** (Base + GUI): `gnustep-base`, `gnustep-gui`, `gnustep-make`
- **libxml2**: `libxml2-dev` (or equivalent)

SmallReSiever implements the SmallStep API locally (SmallStepCompat) so it runs without building SmallStep. If SmallStep is installed, you can link against it instead by adjusting the GNUmakefile.

## Build

```bash
cd SmallReSiever
. /usr/share/GNUstep/Makefiles/GNUstep.sh   # or your GNUSTEP.sh path
make
```

## Run

```bash
./SmallReSiever.app/SmallReSiever
# or
openapp ./SmallReSiever.app
```

Enter a feed URL (e.g. `https://www.example.com/feed.xml`) and click **Fetch**. Select an item in the list to view its content.

## License

GNU AGPLv3+. See [LICENSE](LICENSE).

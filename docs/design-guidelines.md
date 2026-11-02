# Design guidelines

The screen is a round 390×390 AMOLED with a black background. Layout is calculated as ratios of the screen height, which would make other screens easier to support later. Colours live at the top of `source/BeerCounterView.mc`.

## Rules

- **Nothing may cover the Undo strip.** A milestone title must appear on the title line, not in an overlay. The first version used an overlay that hid Undo and cost the user time to press it, so it was dropped.
- **The Undo target must be wide.** The strip spans the full bottom of the screen because it gets pressed with wet fingers.
- **Shapes must look round.** The mug, logo, and icons use large corner radii, curved handles, and round foam. The boxy look of the first version was rejected.
- **On-watch text is English.** That allows system fonts, with no embedded font for Vietnamese diacritics.
- **Use icons instead of text labels** in the stats row, and centre the group by its real text width so the round edge doesn't cut it off.
- **Actions that erase the count need confirmation**, because there is no history to recover from.

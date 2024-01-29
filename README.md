K Color Blocks
==============

## Objectives

This is primarily intended as a creative mode mod and admittedly one with very limited use. I created this because the kids wanted to create giant statues of things and paint them as accurately as possible.

Built in dyes didn't quite cover the range that the minetest engine can deliver. And unified dyes, while pretty nice, has a different problem where the the palette index 0 would stain everything slightly pink and as the clients for this project put it "NOT ENOUGH BROWNS!!1". The implementation felt a little clunky and so I came my with my even clunkier one.

Currently supports only one palette with 15 grey values and 240 color values split into 12 hues. Each hue has 10 full staturation with scaled luminance and the remaining ten are lower saturation. It's not a palette that evenly splits all RGB colours into 256 but rather colours that are subjectively fun to paint with.

This is NOT a replacement for unifieddyes or the built in dye system. For example you cannot dye wool with this mod (for now). Only predefined blocks with the `k_colorblocks` group can be stained.

### Usage

Requires creative mode to be able to access the Colouring Wand and blocks.

Comes with a plain white and a textured quartz block off-white node as a neutral base for staining thing. There is a glowing and non glowing varient of each.

Also comes with about 24 tinted plain blocks in glowing and non glowing varients. Theses can be use to further overlay another tint to create even more variety.

Place stainable blocks in whatever configuration you fancy, right click with the wand to show the color picker, pick a color, click OK, and paint away.

### Other notes:

The textures for the quarts block were lifted from mineclonia (which is using pixelperfection texture pack) so the media license for this mod is also `CC-BY-SA-4.0`

I also not fixing the inconsistent spelling of `colour`.


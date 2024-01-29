K Color Blocks
==============

## What this does

This mods add stainable blocks for creative mode.

If you want to relax and play with speudo legos for a while or want your kids to leave you alone for a few hours.

Built in dyes didn't quite cover the range that the minetest engine can deliver.

And unifieddyes exists, and while pretty nice, has a different problem where the the palette index 0 would stain everything slightly pink.
The implementation felt a little clunky to me and so I came my with my even clunkier one.

Currently supports only one palette with 15 grey values and 240 color values split into 12 hues. Each hue has 10 full staturation with scaled luminance and the remaining ten are lower saturation. It's not a palette that evenly splits all RGB colours into 256 but rather colours that are subjectively fun to paint with.

This is NOT a replacement for unifieddyes or the built in dye system. For example you cannot dye wool with this mod (for now). Only predefined blocks with the `k_colorblocks` group and specific palette file can be stained.

### Features and Usage

Requires creative mode to be able to access the Colouring Wand and blocks.

 * Colors are numerically coded to easily find which one you last used instead of eyeballing it
 * Conveniently shows active color of pointed thing if any.
 * Double click to pick a color instead of clicking `OK` each time on the form for a more relaxed experience.
 * "Continous firing", behaves like a real paint brush and don't have to click each node separately. 
 * Comes with a plain white and a textured quartz block off-white node as a neutral base for staining thing. There is a glowing and non glowing varient of each.
   * Also comes with about 24 tinted plain blocks in glowing and non glowing varients. Theses can be use to further overlay another tint to create even more variety.

Place stainable blocks in whatever configuration you fancy, right click with the wand to show the color picker, pick a color and click OK or just doubleclick on the color tile, and paint away.

Stained blocks retain their tint when you dig them again so you can prepare a swatch of colored blocks before hand and then build your imagination without having to tweak color each time.

### Other notes:

The textures for the quarts block were lifted from mineclonia (which is using pixelperfection texture pack) so the media license for this mod is also `CC-BY-SA-4.0`

I also not fixing the inconsistent spelling of `colour/color`.

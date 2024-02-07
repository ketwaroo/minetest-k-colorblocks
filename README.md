K Color Blocks
==============

# What this does

This mod add stainable blocks for creative mode.

If you want to relax and play with pseudo Legos for a while or want your kids to leave you alone for a few hours.

I made this mod because my kids requested it. Built in dyes didn't quite cover the range that the minetest engine can deliver.
And unifieddyes exists, and while pretty nice, has a different problem where the the palette index 0 would stain everything slightly pink.
The implementation felt a little clunky to me and so I came my with my even clunkier one.

Currently supports only one palette with 15 grey values and 240 color values split into 12 hues. Each hue has 10 full saturation with scaled luminance and the remaining ten are lower saturation. It's not a palette that evenly splits all RGB colours into 256 but rather colours that are subjectively fun to paint with.

# Features and Usage

Requires creative mode to be able to access the Colouring Wand and blocks.

 * Colors are numerically coded to easily find which one you last used instead of eyeballing it.
 * Conveniently shows active colour of pointed thing if any. Also shows actively selected colour and aux colour if any.
 * Double click to pick a colour instead of clicking `OK` each time on the form for a more relaxed experience.
 * "Continuous firing", behaves like a real paint brush and don't have to click each node separately. 
 * Comes with a plain white and a textured quartz block off-white node as a neutral base for staining thing. There is a glowing and non glowing variant of each.
    * Also comes with about 24 tinted plain blocks in glowing and non glowing variant. Theses can be use to further overlay another tint to create even more variety.
    * And on top of that, translucent variants and connected glass blocks. So a lot to play with. If we get ray tracing in this engine, this will look not half bad.
 * Auxiliary colour - You can pick 2 colours to paint with at a time.
    * After selecting second color, click the `Aux` button to set it.
    * Hold `aux1` button while dragging tool across surface to use aux colour.
    * Typical usage for this would have `aux` be palette index `0` which is white. This can serve as undo feature so you don't have to switch back and forth between the colour you want and `0` if you make mistakes.
 * Setting to automatically register certain nodes as stainable.
    * See `k_colorblocks.autoregister_nodes` setting. Disabled by default
    * Works in [Mineclonia](https://content.minetest.net/packages/ryvnf/mineclonia/) and default game to some extent
        * Concrete blocks, slabs, and powder
        * Terracota patterns
        * light blocks ([`mcl_light_blocks`](https://content.minetest.net/packages/Tony996-source/mcl_light_blocks/) third party mod, which is a bit redundant...)
        * wools and carpets.
        * snow and ice. kind of.
    * Does not work with nodes which are already using `param2` and `paramtype2` for different purposes. such as rotation values for beds and stair blocks. May fix eventually.

Place stainable blocks in whatever configuration you fancy, right click with the wand to show the color picker, pick a color and click OK or just double-click on the color tile, and paint away.

Stained blocks retain their tint when you dig them again so you can prepare a swatch of colored blocks before hand and then build your imagination without having to tweak color each time.

# License

Code is under [GPL 3.0 or Later](https://spdx.org/licenses/GPL-3.0-or-later.html).

The textures for the quartz block were lifted from [mineclonia](https://codeberg.org/mineclonia/mineclonia), which is using [pixelperfection](https://www.planetminecraft.com/texture_pack/131pixel-perfection/) texture pack, so the media license for those textures is [CC-BY-SA-4.0](http://creativecommons.org/licenses/by-sa/4.0/).

All other textures and media created by me, including palette files, are also licensed [CC-BY-SA-4.0](http://creativecommons.org/licenses/by-sa/4.0/).

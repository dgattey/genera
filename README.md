# Genera
Experimenting with terrain generation and Metal. Currently a macOS app with the ability to generate infinite (theoretically) procedural terrain with Simplex noise. All generation done on GPU using Metal. Allows for zooming, panning with mouse or keyboard, and tweaking generation params live via a config sidebar.

![Interface](https://github.com/dgattey/genera/images/interface.png)

## Terrain generation
The terrain generator uses both a heightmap generated via configurable octaves of Simplex noise, and a smaller-scale moisture map generated via the same. They're mixed together and compared to ~16 built in biomes to see what color the tile should appear. These biomes have both moisture and elevation ranges to make this happen. Sea level & overall aridity are configurable via global params too, as is distribution ("sharpness") of the noise ranges, i.e. how quickly they range from 0-1, useful for creating spikier peaks and flatter valleys or temperature extremes.

## Future ideas
1. Presets for terrain generation
1. Ability to swap generators (there's a random tile based one too)
1. Blending of colors, random variation to create more realistic variety
1. Trees!
1. Optimized triple buffering/smarter rendering
1. User avatar
1. Turning it into more of a game

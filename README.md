# Genera
Experimenting with terrain generation and Metal. Currently a macOS app with the ability to generate infinite (theoretically) procedural terrain with Simplex noise. All generation done on GPU using Metal. Allows for zooming, panning with mouse or keyboard, and tweaking generation params live via a config sidebar.

![Main Interface](https://user-images.githubusercontent.com/982182/99040398-ecbd6500-253d-11eb-835e-a81985a504f7.png)

## Terrain generation
The terrain generator uses both a heightmap generated via configurable octaves of Simplex noise, and a smaller-scale moisture map generated via the same. All of it is calculated on the GPU itself. They're mixed together and compared to ~16 built in biomes to see what color the tile should appear. These biomes have both moisture and elevation ranges to make this happen. Sea level & overall aridity are configurable via global params too, as is distribution ("sharpness") of the noise ranges, i.e. how quickly they range from 0-1, useful for creating spikier peaks and flatter valleys or temperature extremes.

There are presets available, and you can quickly save more of your own/load them from other sources (they're just json files).

![Terrain Generation](https://user-images.githubusercontent.com/982182/99040409-f0e98280-253d-11eb-85d7-b99dc176f68e.png)

## Grid generation
The grid generator is a CPU-heavy debugging tool that generates random noise on the CPU and passes a ton of float data to the GPU. Useful for debugging chunk loading/paging/padding and zooming/other user interaction. Uses colors from the biomes in terrain generation

![Grid generation](https://user-images.githubusercontent.com/982182/99040406-efb85580-253d-11eb-8fc8-2eaf29b8a925.png)

## Future ideas
1. Blending of colors, random variation to create more realistic variety
1. Trees!
1. Optimized triple buffering/smarter rendering (maybe?)
1. User avatar visualized on map
1. Making more of a game out of it

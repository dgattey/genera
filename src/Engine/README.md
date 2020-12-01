# Engine

All the code that runs the game engine itself, rendering, handling the viewport, coordinating chunks, and running the metal shaders.
Will eventually contain the shaders themselves when metal header searching is supported - right now not possible.

## EngineData

All shared data structures (in header form), used in Swift and Obj-C and Metal. Headers used in Metal can't use `@import`, otherwise
there are few restrictions.

## Engine

Contains the game engine itself, plus data structures used in other modules like `Chunk` and `Direction`. Also contains extensions to
the C-defined header data structures of `DataStructures`.

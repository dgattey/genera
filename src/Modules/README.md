# Modules

This package contains everything that comprises all modules in the app other than the main app. Contains a few different groupings
of data that can be used elsewhere. All modules outlined below! For the most part modules map to libraries, but there are a few
consolidations that happen of multiple modules into one library.

## DataStructures

All shared data structures (in header form), used in Swift and Obj-C and Metal. Headers used in Metal can't use `@import`, otherwise
there are few restrictions.

## DataStructuresSwift

Contains data structures used in other modules like `Chunk` and `Direction` (probably should become part of Engine). Also contains
extensions to the C-defined header data structures of `DataStructures`.

## Engine

All the code that runs the game engine itself, rendering, handling the viewport, coordinating chunks, and running the metal shaders.
Will eventually contain the shaders themselves when metal header searching is supported - right now not possible.

## GeneraGame

The game-specific code, used to generate and draw terrain and grid stuff. Has everything non-generic outside the generic engine. Will
also contain shaders eventually.

## GeneraShaderTypes

The Objective-C component of `GeneraGame` - contains headers to actually render grid and terrain stuff.

## UI

All the reusable UI that can be used generically across a bunch of contexts, like scrollable stack views, interactable views, etc. Could be
pulled out into its own project without question.

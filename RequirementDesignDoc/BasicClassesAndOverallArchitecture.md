# Basic Classes and Overall Architecture

## Basic Classes

### Top-level classes

Top-level classes are Game, GameInfo, EventRecorder, and Page.
Page holds all Items.

<img src="./GameClassesDiagram.png"
alt="Top-level Classes" width="70%">

### Item classes

Item represents everything that displays on the screen and
affects game logic.

Game logic is represented by the updates of items and
by the interactions between items.
The top-level classes are in fact just a framework that
deals with these updates and interactions.

<img src="./ItemClassesDiagram.png"
alt="Item Classes" width="70%">

## Game Framework Work Sequence

<img src="./OverallArchitectureSequenceDiagram.png"
alt="Overall Game Sequence" width="70%">

## How to Store and Manage All the Items

### map-oriented

Items are arranged by their spatial positions in some "map" object.
Item may not need a position attribute.
For example, in some simple cases, map is a cell array,
and cell holds items.

Easy to find out whether a particular position is occupied,
and by which item it is occupied.

Difficult to list items or to retrieve a specific item.

### item-oriented

Items are managed by some list or hash.
Item needs a position attribute.

Easy to retrieve items.

Difficult to deal with spatial problems,
e.g., what items are in the neighbour of a specific item.

### hybrid

Uses list/hash to hold items,
as well as a spatial map as a helper class.

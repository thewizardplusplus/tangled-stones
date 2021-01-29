# Change Log

## [v1.5.2](https://github.com/thewizardplusplus/tangled-stones/tree/v1.5.2) (2020-12-02)

## [v1.5.1](https://github.com/thewizardplusplus/tangled-stones/tree/v1.5.1) (2020-12-01)

## [v1.5](https://github.com/thewizardplusplus/tangled-stones/tree/v1.5) (2020-11-22)

## [v1.4](https://github.com/thewizardplusplus/tangled-stones/tree/v1.4) (2020-11-20)

- initialization:
  - creating a stone grid:
    - setting size of stones based on their count;
- operations:
  - moving stones via drag control:
    - destroying stones below a bottom limit:
      - destroying all dragged stones simultaneously;
- refactoring.

## [v1.3](https://github.com/thewizardplusplus/tangled-stones/tree/v1.3) (2020-11-15)

- game stats:
  - metrics:
    - current move count;
    - minimal move count;
  - storing in the [FlatDB](https://github.com/uleelx/FlatDB) database;
- drawing:
  - drawing a reset button:
    - based on a window size:
      - calculation of a font size based on a screen height;
  - drawing game stats:
    - based on a window size;
- operations:
  - restarting a game session:
    - automatical actions:
      - resetting game stats;
      - saving game stats:
        - if there are changes only.

### Features

- physics entities:
  - static:
    - game field frame;
  - dynamic:
    - stones;
    - joins:
      - joins between stone pairs:
        - rope joint (it restricts a maximal distance only);
      - join for drag control:
        - mouse joint (it moves a stone to a cursor);
        - support of touches;
- game stats:
  - metrics:
    - current move count;
    - minimal move count;
  - storing in the [FlatDB](https://github.com/uleelx/FlatDB) database;
- initialization:
  - creating a game field frame:
    - based on a window size;
    - splitting a bottom border for destroying stones;
  - creating a stone grid:
    - based on a window size;
  - creating joins between stone pairs:
    - automatically when creating stones;
    - random shuffling of joins;
- drawing:
  - drawing physics entities:
    - drawing join edges;
  - drawing a reset button:
    - based on a window size;
  - drawing game stats:
    - based on a window size;
- operations:
  - moving stones via drag control:
    - selecting a stone closest to a cursor;
    - freezing all stones except dragged ones;
    - destroying stones below a bottom limit;
  - restarting a game session:
    - cases:
      - on destroying all stones;
      - by a reset button;
    - automatical actions:
      - resetting game stats;
      - saving game stats:
        - if there are changes only.

## [v1.2](https://github.com/thewizardplusplus/tangled-stones/tree/v1.2) (2020-11-11)

- drawing:
  - drawing a reset button:
    - based on a window size;
- operations:
  - restarting a game session:
    - on destroying all stones;
    - by a reset button.

### Features

- physics entities:
  - static:
    - game field frame;
  - dynamic:
    - stones;
    - joins:
      - joins between stone pairs:
        - rope joint (it restricts a maximal distance only);
      - join for drag control:
        - mouse joint (it moves a stone to a cursor);
        - support of touches;
- initialization:
  - creating a game field frame:
    - based on a window size;
    - splitting a bottom border for destroying stones;
  - creating a stone grid:
    - based on a window size;
  - creating joins between stone pairs:
    - automatically when creating stones;
    - random shuffling of joins;
- drawing:
  - drawing physics entities:
    - drawing join edges;
  - drawing a reset button:
    - based on a window size;
- operations:
  - moving stones via drag control:
    - selecting a stone closest to a cursor;
    - freezing all stones except dragged ones;
    - destroying stones below a bottom limit;
  - restarting a game session:
    - on destroying all stones;
    - by a reset button.

## [v1.1](https://github.com/thewizardplusplus/tangled-stones/tree/v1.1) (2020-11-09)

- initialization:
  - creating a game field frame:
    - splitting a bottom border for destroying stones;
- operations:
  - moving stones via drag control:
    - destroying stones below a bottom limit.

### Features

- physics entities:
  - static:
    - game field frame;
  - dynamic:
    - stones;
    - joins:
      - joins between stone pairs:
        - rope joint (it restricts a maximal distance only);
      - join for drag control:
        - mouse joint (it moves a stone to a cursor);
        - support of touches;
- initialization:
  - creating a game field frame:
    - based on a window size;
    - splitting a bottom border for destroying stones;
  - creating a stone grid:
    - based on a window size;
  - creating joins between stone pairs:
    - automatically when creating stones;
    - random shuffling of joins;
- drawing:
  - drawing physics entities:
    - drawing join edges;
- operations:
  - moving stones via drag control:
    - selecting a stone closest to a cursor;
    - freezing all stones except dragged ones;
    - destroying stones below a bottom limit.

## [v1.0](https://github.com/thewizardplusplus/tangled-stones/tree/v1.0) (2020-11-07)

- initialization:
  - creating a stone grid:
    - based on a window size;
  - creating joins between stone pairs:
    - random shuffling of joins;
- operations:
  - moving stones via drag control:
    - selecting a stone closest to a cursor;
    - freezing all stones except dragged ones.

### Features

- physics entities:
  - static:
    - game field frame;
  - dynamic:
    - stones;
    - joins:
      - joins between stone pairs:
        - rope joint (it restricts a maximal distance only);
      - join for drag control:
        - mouse joint (it moves a stone to a cursor);
        - support of touches;
- initialization:
  - creating a game field frame:
    - based on a window size;
  - creating a stone grid:
    - based on a window size;
  - creating joins between stone pairs:
    - automatically when creating stones;
    - random shuffling of joins;
- drawing:
  - drawing physics entities:
    - drawing join edges;
- operations:
  - moving stones via drag control:
    - selecting a stone closest to a cursor;
    - freezing all stones except dragged ones.

## [v1.0-alpha](https://github.com/thewizardplusplus/tangled-stones/tree/v1.0-alpha) (2020-11-06)

### Features

- physics entities:
  - static:
    - game field frame;
  - dynamic:
    - stones;
    - joins:
      - joins between stone pairs:
        - rope joint (it restricts a maximal distance only);
      - join for drag control:
        - mouse joint (it moves a stone to a cursor);
        - support of touches;
- initialization:
  - creating a game field frame:
    - based on a window size;
  - creating joins between stone pairs:
    - automatically when creating stones;
- drawing:
  - drawing physics entities:
    - drawing join edges;
- operations:
  - moving stones via drag control.

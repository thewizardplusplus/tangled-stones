# Gameplay (EN / [RU](gameplay_ru.md))

[<< Back](README.md)

![](screenshot.png)

## Description of the Game Field

The game field is represented by a set of square stones. The stones are arranged in the center of the field close to each other in the form of a square grid.

Every two stones are connected to each other by a rope. (If the total number of stones is odd, one stone remains unpaired.) The pairing of the stones is random.

The game field is limited by a barrier. There is a hole in the center of the bottom side of the barrier.

## Functioning of the Game Field

The player can move any stone. The other stones and the barrier are obstacles.

By default, all the stones are frozen, i.e. they cannot move. When the player interacts with a stone, it becomes unfrozen. The stone connected to it also becomes unfrozen. All the other stones remain frozen and still cannot move! When the interaction with the stones is over, the stones are frozen again.

The rope connecting the stones is indestructible. Its length can decrease, but it cannot increase. The connected stones cannot be further apart than when they were created, but they can be closer.

If a stone is moved outside the barrier, it is removed from the game field.

## Levels and Grid Size

A level is completed when all stones have been removed from the game field. The game then creates a new grid.

By default, the first level has one stone. After each completed level, the number of stones along each side of the grid increases by one. The current grid size is saved and restored on the next game launch.

This behavior is controlled by the settings and is enabled by default. If it is disabled, every new level uses the same grid size.

## Game Goal and Statistics

The game goal is to clear the game field of stones. This is done by moving the stones into the hole in the barrier.

The game keeps statistics by memorizing the minimum number of actions for all game sessions. Statistics are stored separately for each stone grid size. One action in this case is a continuous movement of a stone (i.e. release the stone — complete the action).

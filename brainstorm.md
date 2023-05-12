
## Break process

1. Player moves/changes a piece
2. Send event that board state has changed (`Gameplay.onRotate` and `Gameplay.onSwap`)
3. Connection plugin scans the board and finds all trees
4. If tree reaches from inputs to outputs, fire event
5. Delivery plugin receives trees and checks for validity (inputs with matching outputs on same tree)
6. If valid match found, find shortest path between inputs and outputs
   1. Lock these tiles (set `isMobile` to false?)
   2. Start timer: perhaps visually represented as the input shape traveling along the pipe, 'ending' once piece reaches the other side
   3. Once timer ends, shortest path pipes are removed and new pipes are generated in their place
   4. If a new connection is added to the tree (either new input to existing outputs, new output for existing inputs, or new input to new output), the new pieces are locked, and the timer mechanism resets



### Piece difficulty

In order of ease-of-use:

- 4-way
- tee
- double-corner
- corner
- crossover
- straight
- one-way
- empty
- dead

- Corner pieces seem to be the most versatile?
-
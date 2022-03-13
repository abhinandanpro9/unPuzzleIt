// ignore_for_file: public_member_api_docs

import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:unpuzzle_it_abhi/models/models.dart';

part 'puzzle_event.dart';
part 'puzzle_state.dart';

class PuzzleBloc extends Bloc<PuzzleEvent, PuzzleState> {
  PuzzleBloc(this.tileSize, {this.random}) : super(const PuzzleState()) {
    on<PuzzleInitialized>(_onPuzzleInitialized);
    on<TileTapped>(_onTileTapped);
    on<PuzzleReset>(_onPuzzleReset);
    on<PuzzleReverse>(_onPuzzleReverse);
    on<PuzzleTriggerCustom>(_onPuzzleTriggerCustom);
  }

  late int tileSize;

  final Random? random;

  // StreamSubscription<int>? _tickerSubscription;

  TickerMs tickerMs = const TickerMs();

  // List to store the swap process so that it can be reversed later
  List<int> tileProcessFlow = [];

  void _onPuzzleTriggerCustom(
    PuzzleTriggerCustom event,
    Emitter<PuzzleState> emit,
  ) {
    emit(
      state.copyWith(
        customPuzzleChange: !event.isImageChange,
      ),
    );
  }

  // create:
  // reverse solves the puzzle
  void _onPuzzleReverse(
    PuzzleReverse event,
    Emitter<PuzzleState> emit,
  ) {
    //Null Calls
    if (tileProcessFlow.length == 0) {
      emit(
        state.copyWith(
          puzzleStatus: PuzzleStatus.spam,
        ),
      );
      return;
    }

    final correctPositions = <Position>[];
    final whitespacePosition = Position(x: tileSize, y: tileSize);

    // Create all possible board positions.
    for (var y = 1; y <= tileSize; y++) {
      for (var x = 1; x <= tileSize; x++) {
        if (x == tileSize && y == tileSize) {
          correctPositions.add(whitespacePosition);
        } else {
          final position = Position(x: x, y: y);
          correctPositions.add(position);
        }
      }
    }

    final currentPositions =
        _reversePuzzle(tileSize, event.tilesList, shuffle: false);

    var tiles = _getTileListFromPositions(
      tileSize,
      correctPositions,
      currentPositions,
    );

    // print(currentPositions);
    // debugPrint('Tile Size: $currentPositions');
    // print(correctPositions);
    var puzzle = Puzzle(
      tiles: tiles,
    );

    tileProcessFlow.removeLast();

    if (puzzle.getNumberOfCorrectTiles() == (pow(tileSize, 2) - 1)) {
      emit(
        state.copyWith(
          puzzle: puzzle.sort(),
          puzzleStatus: PuzzleStatus.reversed,
          tileMovementStatus: TileMovementStatus.moved,
          numberOfCorrectTiles: puzzle.getNumberOfCorrectTiles(),
          numberOfMoves: state.numberOfMoves,
          playerScore: state.playerScore
        ),
      );
    } else {
      emit(
        state.copyWith(
          puzzle: puzzle.sort(),
          puzzleStatus: PuzzleStatus.reversing,
          tileMovementStatus: TileMovementStatus.moved,
          numberOfCorrectTiles: puzzle.getNumberOfCorrectTiles(),
          numberOfMoves: state.numberOfMoves,
          playerScore: state.playerScore
        ),
      );
    }
  }

  /// Build a reverse solvable puzzle of the existing state size.
  List<Position> _reversePuzzle(
    int size,
    List<Tile> tiles, {
    bool shuffle = true,
  }) {
    var swapDirection = false;

    var current = [
      for (int i = 0; i < size * size; i++) tiles[i].correctPosition
    ];

    // currentProcessFlow.removeAt(currentProcessFlow.length - 1);

    var slideObjectEmpty = getEmptyObject(current);

    // get index of empty slide object
    int emptyIndex = slideObjectEmpty;

    // tileProcess.add(emptyIndex);
    var nextIndex = tileProcessFlow.last;

    // No need to do unwanted processing
    if (slideObjectEmpty == nextIndex) return current;

    // swapDirection here
    if (swapDirection == false) {
      var yEmpty = emptyIndex ~/ tileSize + 1; //row
      var xEmpty = emptyIndex % tileSize + 1; // col

      var ySwapDirection = nextIndex ~/ tileSize + 1; // row
      var xSwapDirection = nextIndex % tileSize + 1; // col

      if (yEmpty == ySwapDirection) {
        for (var xx = xEmpty; xx != 0 && xx != tileSize + 1;) {
          var next = (yEmpty - 1) * tileSize + (xx - 1);

          if (xx != xSwapDirection) {
            xx = _reverseLogic(
              current,
              next,
              xx,
              xSwapDirection,
              1,
            );
            swapDirection = true;
          } else {
            break;
          }
        }
      }
    }

    if (swapDirection == false) {
      var yEmpty = emptyIndex ~/ tileSize + 1; //row
      var xEmpty = emptyIndex % tileSize + 1; // col

      var ySwapDirection = nextIndex ~/ tileSize + 1; // row
      var xSwapDirection = nextIndex % tileSize + 1; // col

      if (xEmpty == xSwapDirection) {
        for (var xx = yEmpty; xx != 0 && xx != tileSize + 1;) {
          var next = (xx - 1) * tileSize + (xEmpty - 1);

          if (ySwapDirection != xx) {
            xx = _reverseLogic(
              current,
              next,
              xx,
              ySwapDirection,
              tileSize,
            );
          } else {
            break;
          }
        }
      }
    }

    return current;
  }

  int _reverseLogic(
    List<Position> current,
    int next,
    int xx,
    int xSwapDirection,
    int swapOffset,
  ) {
    // Get empty tile
    var newEmptyIndex = getEmptyObject(current);

    // If greater move forward
    if (xSwapDirection > xx) {
      // Swap
      final temp = current[newEmptyIndex];
      current[newEmptyIndex] = current[next + swapOffset];
      current[next + swapOffset] = temp;

      xx++;
    }
    // move backward
    else if (xSwapDirection < xx) {
      // Swap
      final temp = current[newEmptyIndex];
      current[newEmptyIndex] = current[next - swapOffset];
      current[next - swapOffset] = temp;

      xx--;
    }
    return xx;
  }

  void _onPuzzleInitialized(
    PuzzleInitialized event,
    Emitter<PuzzleState> emit,
  ) {
    tileSize = event.tileSize;

    //  event.shufflePuzzle; shuffle by default or not
    //  _size; size of the puzzle
    // flow: PUZZ basically just generates the x,y coordinates for the puzzle .
    final puzzle = _generatePuzzle(tileSize, shuffle: event.shufflePuzzle);

    // flow: PUZZ sets state of the PuzzleBloc
    emit(
      PuzzleState(
        puzzle: puzzle.sort(),
        numberOfCorrectTiles: puzzle.getNumberOfCorrectTiles(),
      ),
    );
  }

  //flow: TILE tap handler
  void _onTileTapped(TileTapped event, Emitter<PuzzleState> emit) {
    final tappedTile = event.tile;

    if (state.puzzleStatus == PuzzleStatus.incomplete) {
      if (state.puzzle.isTileMovable(tappedTile)) {
        final mutablePuzzle = Puzzle(tiles: [...state.puzzle.tiles]);
        final puzzle = mutablePuzzle.moveTiles(tappedTile, [], tileProcessFlow);
        if (puzzle.isComplete()) {
          // When complete the puzzle
          emit(
            state.copyWith(
              puzzle: puzzle.sort(),
              puzzleStatus: PuzzleStatus.complete,
              tileMovementStatus: TileMovementStatus.moved,
              numberOfCorrectTiles: puzzle.getNumberOfCorrectTiles(),
              numberOfMoves: state.numberOfMoves + 1,
              lastTappedTile: tappedTile,
              playerScore: state.playerScore
            ),
          );
        } else {
          // When incomplete the puzzle handle switch
          emit(
            state.copyWith(
              puzzle: puzzle.sort(),
              tileMovementStatus: TileMovementStatus.moved,
              numberOfCorrectTiles: puzzle.getNumberOfCorrectTiles(),
              numberOfMoves: state.numberOfMoves + 1,
              lastTappedTile: tappedTile,
              playerScore: state.playerScore
            ),
          );
        }
      } else {
        emit(
          state.copyWith(tileMovementStatus: TileMovementStatus.cannotBeMoved),
        );
      }
    } else {
      emit(
        state.copyWith(tileMovementStatus: TileMovementStatus.cannotBeMoved),
      );
    }
  }

  void _onPuzzleReset(PuzzleReset event, Emitter<PuzzleState> emit) {
    final puzzle = _generatePuzzle(tileSize);
    emit(
      PuzzleState(
        puzzle: puzzle.sort(),
        numberOfCorrectTiles: puzzle.getNumberOfCorrectTiles(),
      ),
    );
  }

  /// Build a randomized, solvable puzzle of the given size.
  Puzzle _generatePuzzle(int size, {bool shuffle = true}) {
    final correctPositions = <Position>[];
    final currentPositions = <Position>[];
    final whitespacePosition = Position(x: size, y: size);

    // Create all possible board positions.
    for (var y = 1; y <= size; y++) {
      for (var x = 1; x <= size; x++) {
        // flow: TILE calc
        if (x == size && y == size) {
          correctPositions.add(whitespacePosition);
          currentPositions.add(whitespacePosition);
        } else {
          final position = Position(x: x, y: y);
          correctPositions.add(position);
          currentPositions.add(position);
        }
      }
    }

    // if (shuffle) {
    //   // Randomize only the current tile posistions.
    //   currentPositions.shuffle(random);
    // }

    // // Custom Shuffle Algorithm
    if (shuffle) {
      tileProcessFlow = [];
      tileProcessFlow.add((size * size) - 1);
      _shuffle(currentPositions, correctPositions);
      // var len = tileProcessFlow.length;
      // debugPrint('TILE: ' '$len' ':' '$currentProcessFlow');
    }

    var tiles = _getTileListFromPositions(
      size,
      correctPositions,
      currentPositions,
    );

    // flow: PUZZ initial puzzle grid without shuffle
    var puzzle = Puzzle(tiles: tiles);

    // flow: PUZZ shuffle the grid here

    return puzzle;
  }

  // get empty slide object from list
  int getEmptyObject(List<Position> tiles) {
    return tiles.indexWhere(
      (element) => element.x == tileSize && element.y == tileSize,
    );
  }

  int _shuffleLogic(
    List<Position> current,
    List<Position> correct,
    int randomDestIndex,
    int next,
    int xx,
    int xSwapDirection,
    int swapOffset,
  ) {
    // Get empty tile
    var newEmptyIndex = getEmptyObject(current);

    // If greater move forward
    if (xSwapDirection > xx && (next + swapOffset) != newEmptyIndex) {
      // The correct[next+swapOffset] != current[EmptyIndex]
      // and correct[EmptyIndex] != current[next+swapOffset]
      if (correct[next + swapOffset] != current[newEmptyIndex] &&
          correct[newEmptyIndex] != current[next + swapOffset] &&
          correct[randomDestIndex] != current[newEmptyIndex] &&
          correct[newEmptyIndex] != current[randomDestIndex]) {
        // Swap
        final temp = current[newEmptyIndex];
        current[newEmptyIndex] = current[next + swapOffset];
        current[next + swapOffset] = temp;

        // Store swap index
        tileProcessFlow.add(next + swapOffset);
      } else {
        return -1;
      }
      xx++;
    }
    // move backward
    else if (xSwapDirection < xx && (next - swapOffset) != newEmptyIndex) {
      // The correct[next+swapOffset] != current[EmptyIndex]
      // and correct[EmptyIndex] != current[next+swapOffset]
      if (correct[next - swapOffset] != current[newEmptyIndex] &&
          correct[newEmptyIndex] != current[next - swapOffset] &&
          correct[randomDestIndex] != current[newEmptyIndex] &&
          correct[newEmptyIndex] != current[randomDestIndex]) {
        // Swap
        final temp = current[newEmptyIndex];
        current[newEmptyIndex] = current[next - swapOffset];
        current[next - swapOffset] = temp;

        // Store swap index
        tileProcessFlow.add(next - swapOffset);
      } else {
        return -1;
      }
      xx--;
    }
    return xx;
  }

  /// Shuffle the tiles based on each move in loop.
  /// Store so that its easy to reverse
  List<int> _shuffle(
    List<Position> currentPositions,
    List<Position> correctPositions,
  ) {
    var swapDirection = true;
    var flagShuffle = 1;

    // Wait till all tiles are shuffled
    while (flagShuffle == 1) {
      flagShuffle = 0;
      var randomTilePos = <int>[];

      // Check if all tiles are shuffled
      for (var i = 0; i < tileSize * tileSize; i++) {
        if (currentPositions[i] == correctPositions[i]) {
          flagShuffle = 1;
          randomTilePos.add(i);
        }
      }

      // if (randomTilePos.length < 10) break;

      if (flagShuffle == 0) break;

      var slideObjectEmpty = getEmptyObject(currentPositions);

      // get index of empty slide object
      int emptyIndex = slideObjectEmpty;

      // tileProcess.add(emptyIndex);
      int randonDestIndex;
      var row = 0;
      var col = 0;

      // Select random tile index which are not swapped yet
      // var element = randomTilePos[new Random().nextInt(randomTilePos.length)];

      var random = new Random().nextInt(tileSize);
      // debugPrint('Tile Size: $random');

      if (swapDirection) {
        // horizontal swapDirection
        row = emptyIndex ~/ tileSize;
        randonDestIndex = row * tileSize + random;
      } else {
        // vertical swapDirection
        col = emptyIndex % tileSize;
        randonDestIndex = tileSize * random + col;
      }
      // print(randKey);
      // if (randKey == 0) debugPrint('Rand: $randKey');

      // swapDirection here
      if (swapDirection) {
        var yEmpty = emptyIndex ~/ tileSize + 1; //row of empty
        var xEmpty = emptyIndex % tileSize + 1; // col of empty

        var ySwapDir = randonDestIndex ~/ tileSize + 1; // row of destination
        var xSwapDir = randonDestIndex % tileSize + 1; // col of destination

        if (yEmpty == ySwapDir) {
          for (var xx = xEmpty; xx != 0 && xx != tileSize + 1;) {
            var next = (yEmpty - 1) * tileSize + (xx - 1);

            // Swap rows here
            if (xx != xSwapDir) {
              xx = _shuffleLogic(
                currentPositions,
                correctPositions,
                randonDestIndex,
                next,
                xx,
                xSwapDir,
                1,
              );
              if (xx == -1) break;
            } else {
              break;
            }
          }
        }
      }

      if (!swapDirection) {
        var yEmpty = emptyIndex ~/ tileSize + 1; //row of empty
        var xEmpty = emptyIndex % tileSize + 1; // col of empty

        var ySwapDir = randonDestIndex ~/ tileSize + 1; // row of destination
        var xSwapDirec = randonDestIndex % tileSize + 1; // col of destination

        if (xEmpty == xSwapDirec) {
          for (var xx = yEmpty; xx != 0 && xx != tileSize + 1;) {
            var next = (xx - 1) * tileSize + (xEmpty - 1);

            // Swap columns here
            if (ySwapDir != xx) {
              xx = _shuffleLogic(
                currentPositions,
                correctPositions,
                randonDestIndex,
                next,
                xx,
                ySwapDir,
                tileSize,
              );
              if (xx == -1) break;
            } else {
              break;
            }
          }
        }
      }
      // Change the swap direction each loop
      swapDirection = !swapDirection;
    }

    // print(puzzleExtras.currentProcess);
    // List<int> list = currentProcessFlow;
    // debugPrint('Tile Flow: $currentProcessFlow');

    return tileProcessFlow;
  }

  /// Build a list of tiles - giving each tile their correct position and a
  /// current position.
  List<Tile> _getTileListFromPositions(
    int size,
    List<Position> correctPositions,
    List<Position> currentPositions,
  ) {
    final whitespacePosition = Position(x: size, y: size);
    return [
      for (int i = 1; i <= size; i++)
        for (int j = 1; j <= size; j++)
          if (i == size && j == size)
            Tile(
              // Calc value based on i and r i.e, row and col
              value: 1 + ((i - 1) * tileSize + (j - 1)),
              // correct position for last tile
              correctPosition: whitespacePosition,
              // current position for last tile based on list where the element
              // in present
              currentPosition: correctPositions[currentPositions
                  .indexWhere((element) => element.x == j && element.y == i)],
              isWhitespace: true,
            )
          else
            Tile(
              // Calc value based on i and r i.e, row and col
              value: 1 + ((i - 1) * tileSize + (j - 1)),
              // correct position for last tile
              correctPosition: correctPositions[((i - 1) * tileSize + (j - 1))],
              // current position for last tile based on list where the element
              // in present
              currentPosition: correctPositions[currentPositions
                  .indexWhere((element) => element.x == j && element.y == i)],
            )
    ];
  }
}

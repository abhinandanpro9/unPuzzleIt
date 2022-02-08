// ignore_for_file: public_member_api_docs

part of 'puzzle_bloc.dart';

abstract class PuzzleEvent extends Equatable {
  const PuzzleEvent();

  @override
  List<Object> get props => [];
}

class PuzzleInitialized extends PuzzleEvent {
  const PuzzleInitialized({
    required this.shufflePuzzle,
    required this.tileSize,
  });

  final bool shufflePuzzle;
  final int tileSize;

  @override
  List<Object> get props => [shufflePuzzle, tileSize];
}

class TileTapped extends PuzzleEvent {
  const TileTapped(this.tile);

  final Tile tile;

  @override
  List<Object> get props => [tile];
}

class PuzzleReset extends PuzzleEvent {
  const PuzzleReset();
}

// create:
class PuzzleReverse extends PuzzleEvent {
  const PuzzleReverse(this.tilesList);

  final List<Tile> tilesList;

  @override
  List<Tile> get props => tilesList;
}

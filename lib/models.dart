

class TransitionRule {
  final String state; // "A", "B", "C"
  final int readVal;  // 0 or 1
  int writeVal;       // 0 or 1
  String moveDir;     // "R" (Clockwise), "L" (Counter-clockwise), "S" (Stay)
  String nextState;   // "A", "B", "C", "H" (Halt)

  TransitionRule({
    required this.state,
    required this.readVal,
    required this.writeVal,
    required this.moveDir,
    required this.nextState,
  });

  TransitionRule copy() {
    return TransitionRule(
      state: state,
      readVal: readVal,
      writeVal: writeVal,
      moveDir: moveDir,
      nextState: nextState,
    );
  }
}

class GameLevel {
  final int id;
  final String name;
  final String description;
  final String goalDescription;
  final List<int> initialTape; // 24 values
  final List<int> targetTape;  // 24 values (or check criteria dynamically)
  final List<TransitionRule> initialRules;
  final int maxSteps;
  final String hint;

  GameLevel({
    required this.id,
    required this.name,
    required this.description,
    required this.goalDescription,
    required this.initialTape,
    required this.targetTape,
    required this.initialRules,
    required this.maxSteps,
    required this.hint,
  });

  // Check if current tape matches the target criteria
  bool isSolved(List<int> currentTape) {
    if (id == 1) {
      // Level 1: Northern Summer Solstice. We want at least 16 Light cells total,
      // specifically we want a long day. Let's say we want exactly 16 Light cells and 8 Dark cells.
      int lightCount = currentTape.where((v) => v == 1).length;
      return lightCount == 16;
    } else if (id == 2) {
      // Level 2: Southern Winter Solstice. Long night, short day.
      // We want exactly 8 Light cells and 16 Dark cells.
      int lightCount = currentTape.where((v) => v == 1).length;
      return lightCount == 8;
    } else if (id == 3) {
      // Level 3: Equinox Balance. Exactly 12 Light and 12 Dark cells.
      int lightCount = currentTape.where((v) => v == 1).length;
      return lightCount == 12;
    } else if (id == 4) {
      // Level 4: Alan Turing's Solstice Enigma. Match the exact target pattern:
      // 8 Light, 8 Dark, 8 Light (represented in 24 hours)
      for (int i = 0; i < 24; i++) {
        if (currentTape[i] != targetTape[i]) return false;
      }
      return true;
    }
    return false;
  }
}

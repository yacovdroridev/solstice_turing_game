import 'dart:async';
import 'package:flutter/foundation.dart';
import 'models.dart';

class GameProvider with ChangeNotifier {
  List<GameLevel> _levels = [];
  int _currentLevelIndex = 0;
  
  // Current state of the active game
  List<int> _tape = List.filled(24, 0);
  int _headPosition = 0;
  String _currentState = "A";
  bool _isRunning = false;
  int _stepsTaken = 0;
  String _statusMessage = "Ready to start the Solstice Machine!";
  bool _hasWon = false;
  
  Timer? _timer;
  int _speedMs = 150; // speed of step executions in milliseconds
  
  // Active rule table for the current level (copies of initial level rules)
  List<TransitionRule> _activeRules = [];

  // Chat message logs with Alan Turing AI
  List<Map<String, String>> _chatMessages = [];

  GameProvider() {
    _initializeLevels();
    _loadLevel(0);
    _initChat();
  }

  // Getters
  List<GameLevel> get levels => _levels;
  int get currentLevelIndex => _currentLevelIndex;
  GameLevel get currentLevel => _levels[_currentLevelIndex];
  List<int> get tape => _tape;
  int get headPosition => _headPosition;
  String get currentState => _currentState;
  bool get isRunning => _isRunning;
  int get stepsTaken => _stepsTaken;
  String get statusMessage => _statusMessage;
  bool get hasWon => _hasWon;
  List<TransitionRule> get activeRules => _activeRules;
  List<Map<String, String>> get chatMessages => _chatMessages;
  int get speedMs => _speedMs;

  set speedMs(int ms) {
    _speedMs = ms;
    notifyListeners();
    if (_isRunning) {
      _stopTimer();
      _startTimer();
    }
  }

  void _initializeLevels() {
    _levels = [
      GameLevel(
        id: 1,
        name: "Summer Solstice (North)",
        description: "The June Solstice brings the longest day of the year in the Northern Hemisphere. Your goal is to heat up the tape!",
        goalDescription: "Generate exactly 16 Light cells (☀️) on the 24-hour cycle. Stop the machine by transitioning to the HALT (H) state.",
        initialTape: List.filled(24, 0), // Start with all Dark
        targetTape: List.filled(24, 0), // Criteria checked dynamically
        maxSteps: 40,
        hint: "To get exactly 16 Lights, write 1 in State A, move Right (R), and transition to B. In State B, write 1, move R, and transition to C. Continue this chain to count, or write a loop that halts on the 16th step!",
        initialRules: [
          TransitionRule(state: "A", readVal: 0, writeVal: 1, moveDir: "R", nextState: "B"),
          TransitionRule(state: "A", readVal: 1, writeVal: 1, moveDir: "R", nextState: "A"),
          TransitionRule(state: "B", readVal: 0, writeVal: 1, moveDir: "R", nextState: "C"),
          TransitionRule(state: "B", readVal: 1, writeVal: 0, moveDir: "R", nextState: "B"),
          TransitionRule(state: "C", readVal: 0, writeVal: 1, moveDir: "R", nextState: "H"), // H is Halt
          TransitionRule(state: "C", readVal: 1, writeVal: 1, moveDir: "R", nextState: "C"),
        ],
      ),
      GameLevel(
        id: 2,
        name: "Winter Solstice (South)",
        description: "While the North basks in daylight, the Southern Hemisphere faces its longest night. Bring the dark!",
        goalDescription: "Cool the system down. The tape starts fully bright (all 24 Light). Program the machine to end with exactly 8 Light cells (☀️) and 16 Dark cells (🌙), then Halt (H).",
        initialTape: List.filled(24, 1), // Start with all Light
        targetTape: List.filled(24, 0),
        maxSteps: 50,
        hint: "You need to wipe out 16 Light cells. Try making your states write 0 (Dark), move Right, and chain them together until you reach the target, then transition to H.",
        initialRules: [
          TransitionRule(state: "A", readVal: 1, writeVal: 0, moveDir: "R", nextState: "B"),
          TransitionRule(state: "A", readVal: 0, writeVal: 0, moveDir: "R", nextState: "A"),
          TransitionRule(state: "B", readVal: 1, writeVal: 0, moveDir: "R", nextState: "C"),
          TransitionRule(state: "B", readVal: 0, writeVal: 1, moveDir: "R", nextState: "B"),
          TransitionRule(state: "C", readVal: 1, writeVal: 0, moveDir: "R", nextState: "H"),
          TransitionRule(state: "C", readVal: 0, writeVal: 1, moveDir: "R", nextState: "C"),
        ],
      ),
      GameLevel(
        id: 3,
        name: "The Equinox Balance",
        description: "The cosmic turning point. Daylight and darkness must be in perfect mathematical equilibrium.",
        goalDescription: "The tape starts with a messy scrambled pattern. Program the machine to result in an exact 50/50 balance: exactly 12 Light cells and 12 Dark cells, then Halt.",
        initialTape: [1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0],
        targetTape: List.filled(24, 0),
        maxSteps: 60,
        hint: "With alternating cells, your states can read the current cell and decide whether to toggle it. To make 12 Light cells, you can overwrite any excess Light/Dark cells until the count is 12, then Halt.",
        initialRules: [
          TransitionRule(state: "A", readVal: 0, writeVal: 1, moveDir: "R", nextState: "B"),
          TransitionRule(state: "A", readVal: 1, writeVal: 0, moveDir: "R", nextState: "A"),
          TransitionRule(state: "B", readVal: 0, writeVal: 0, moveDir: "R", nextState: "C"),
          TransitionRule(state: "B", readVal: 1, writeVal: 1, moveDir: "R", nextState: "B"),
          TransitionRule(state: "C", readVal: 0, writeVal: 1, moveDir: "R", nextState: "H"),
          TransitionRule(state: "C", readVal: 1, writeVal: 0, moveDir: "R", nextState: "C"),
        ],
      ),
      GameLevel(
        id: 4,
        name: "Turing's Solstice Cipher",
        description: "Alan Turing has encrypted a secret solstice message into three distinct blocks of 8-hour phases.",
        goalDescription: "Decrypt the tape. Create the exact pattern: 8 Light cells (☀️), followed by 8 Dark cells (🌙), followed by 8 Light cells (☀️). Total 24 cells.",
        initialTape: List.filled(24, 0),
        targetTape: [
          1, 1, 1, 1, 1, 1, 1, 1, // 8 Light
          0, 0, 0, 0, 0, 0, 0, 0, // 8 Dark
          1, 1, 1, 1, 1, 1, 1, 1  // 8 Light
        ],
        maxSteps: 80,
        hint: "State A can write 8 Lights and then switch to State B to skip 8 cells (leave them 0), then State B transitions to State C to write another 8 Lights before halting. Use loops to keep track of counting!",
        initialRules: [
          TransitionRule(state: "A", readVal: 0, writeVal: 1, moveDir: "R", nextState: "B"),
          TransitionRule(state: "A", readVal: 1, writeVal: 1, moveDir: "R", nextState: "A"),
          TransitionRule(state: "B", readVal: 0, writeVal: 0, moveDir: "R", nextState: "C"),
          TransitionRule(state: "B", readVal: 1, writeVal: 1, moveDir: "R", nextState: "B"),
          TransitionRule(state: "C", readVal: 0, writeVal: 1, moveDir: "R", nextState: "H"),
          TransitionRule(state: "C", readVal: 1, writeVal: 0, moveDir: "R", nextState: "C"),
        ],
      ),
    ];
  }

  void _loadLevel(int index) {
    _currentLevelIndex = index;
    final level = _levels[index];
    _tape = List.from(level.initialTape);
    _headPosition = 0;
    _currentState = "A";
    _isRunning = false;
    _stepsTaken = 0;
    _hasWon = false;
    _statusMessage = "Loaded Level ${level.id}: ${level.name}. Modify rules and click RUN!";
    
    // Deep copy rules
    _activeRules = level.initialRules.map((r) => r.copy()).toList();
    _stopTimer();
    notifyListeners();
  }

  void selectLevel(int index) {
    if (index >= 0 && index < _levels.length) {
      _loadLevel(index);
    }
  }

  void updateRule(int ruleIndex, {int? writeVal, String? moveDir, String? nextState}) {
    if (ruleIndex >= 0 && ruleIndex < _activeRules.length) {
      if (writeVal != null) _activeRules[ruleIndex].writeVal = writeVal;
      if (moveDir != null) _activeRules[ruleIndex].moveDir = moveDir;
      if (nextState != null) _activeRules[ruleIndex].nextState = nextState;
      notifyListeners();
    }
  }

  void resetLevel() {
    _loadLevel(_currentLevelIndex);
  }

  // Run the Turing machine
  void runMachine() {
    if (_isRunning) return;
    if (_hasWon) {
      _statusMessage = "Level already solved! Reset or move to the next level.";
      notifyListeners();
      return;
    }
    _isRunning = true;
    _statusMessage = "Solstice Turing Machine is running...";
    _startTimer();
    notifyListeners();
  }

  void pauseMachine() {
    _isRunning = false;
    _statusMessage = "Machine paused at step $_stepsTaken.";
    _stopTimer();
    notifyListeners();
  }

  void stepMachine() {
    if (_hasWon) return;
    _executeStep();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(milliseconds: _speedMs), (timer) {
      _executeStep();
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _executeStep() {
    if (_stepsTaken >= currentLevel.maxSteps) {
      _isRunning = false;
      _stopTimer();
      _statusMessage = "Halted: Exceeded maximum steps limit (${currentLevel.maxSteps}). Try optimizing your rules!";
      notifyListeners();
      return;
    }

    int currentReadVal = _tape[_headPosition];
    
    // Find matching rule
    TransitionRule? activeRule;
    for (var rule in _activeRules) {
      if (rule.state == _currentState && rule.readVal == currentReadVal) {
        activeRule = rule;
        break;
      }
    }

    if (activeRule == null) {
      _isRunning = false;
      _stopTimer();
      _statusMessage = "Halted: No matching transition rule found for State $_currentState and Read $currentReadVal.";
      notifyListeners();
      return;
    }

    // Apply rule
    _tape[_headPosition] = activeRule.writeVal;
    
    // Move head
    if (activeRule.moveDir == "R") {
      _headPosition = (_headPosition + 1) % 24;
    } else if (activeRule.moveDir == "L") {
      _headPosition = (_headPosition - 1 + 24) % 24;
    } // "S" stays in place

    _currentState = activeRule.nextState;
    _stepsTaken++;

    if (_currentState == "H") {
      _isRunning = false;
      _stopTimer();
      
      // Check if solved
      if (currentLevel.isSolved(_tape)) {
        _hasWon = true;
        _statusMessage = "🎉 SUCCESS! You broke the Solstice Cipher! Turing is proud of you!";
        _addSystemChatMessage("Alan Turing", "Splendid work! You've balanced the forces of light and dark using elegant computing logic. Proceed to the next level of computation.");
      } else {
        _statusMessage = "Halted in State H (Halt), but the solstice target was not met. Try resetting and tweaking your rules!";
      }
    }

    notifyListeners();
  }

  // --- Chat with Alan Turing AI Logic ---
  void _initChat() {
    _chatMessages = [
      {
        "sender": "Alan Turing",
        "message": "Greetings, fellow researcher! I am Alan. Together, we shall decrypt the cosmic rhythms of the June Solstice. Our instrument is this circle of 24 hours – a closed-loop Turing Machine tape. Ask me anything, and I shall assist with algorithmic hints or computational principles!"
      }
    ];
  }

  void sendUserChatMessage(String userMsg) {
    if (userMsg.trim().isEmpty) return;
    
    _chatMessages.add({
      "sender": "You",
      "message": userMsg
    });
    notifyListeners();

    // Generate responsive reply based on keywords/current level
    String reply = _generateTuringReply(userMsg);
    
    // Delayed response for realism
    Future.delayed(const Duration(milliseconds: 1000), () {
      _chatMessages.add({
        "sender": "Alan Turing",
        "message": reply
      });
      notifyListeners();
    });
  }

  void _addSystemChatMessage(String sender, String msg) {
    _chatMessages.add({
      "sender": sender,
      "message": msg
    });
    notifyListeners();
  }

  String _generateTuringReply(String query) {
    query = query.toLowerCase();
    
    if (query.contains("solstice") || query.contains("day") || query.contains("night")) {
      return "Ah, the June Solstice! An elegant astrophysical phenomenon where the tilt of our planet maximizes exposure to our host star in one hemisphere, while plunging the other into shadows. In our machine, we represent this duality with binary states: 1 for Light (☀️) and 0 for Dark (🌙). A perfect subject for computational modeling!";
    }
    
    if (query.contains("hint") || query.contains("help") || query.contains("stuck") || query.contains("solve")) {
      return "To crack Level ${currentLevel.id} (${currentLevel.name}):\n\n" + currentLevel.hint + "\n\nRemember, your state register determines your memory. Transitioning to different states allows you to keep track of counts and patterns without having infinite cells!";
    }
    
    if (query.contains("turing") || query.contains("enigma") || query.contains("computing") || query.contains("bombe")) {
      return "My work at Bletchley Park was centered around mechanical breaking of complex states – the Enigma cipher. The key to cryptography and general computing is the formal definition of state transitions. Our Solstice Engine works on the exact same principles as the Universal Turing Machine I conceived in 1936!";
    }

    if (query.contains("google") || query.contains("gemini") || query.contains("ai")) {
      return "Google's Gemini and Antigravity engines are marvellous modern achievements. They represent the realization of my 'Computing Machinery and Intelligence' paper, where I pondered if machines could think. Utilizing Google AI to help craft this game is a perfect symbiosis of organic and inorganic reasoning!";
    }

    return "A fascinating query! In computational terms, we must remember that every problem can be reduced to state symbols, a tape, and transition rules. Try focusing on how your States A, B, and C can share the logic of counting or matching cells!";
  }

  void nextLevel() {
    if (_currentLevelIndex < _levels.length - 1) {
      _loadLevel(_currentLevelIndex + 1);
    }
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}

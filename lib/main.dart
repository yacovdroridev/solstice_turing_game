import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'game_provider.dart';
import 'models.dart';

void main() {
  runApp(const SolsticeTuringApp());
}

class SolsticeTuringApp extends StatelessWidget {
  const SolsticeTuringApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameProvider(),
      child: MaterialApp(
        title: 'Solstice Engine',
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: const Color(0xFF0F172A), // Slate 900
          primaryColor: const Color(0xFFFBBF24), // Gold 400
          colorScheme: const ColorScheme.dark().copyWith(
            primary: const Color(0xFFFBBF24),
            secondary: const Color(0xFF38BDF8), // Light Blue 400
            surface: const Color(0xFF1E293B), // Slate 800
          ),
          textTheme: GoogleFonts.shareTechMonoTextTheme(
            ThemeData.dark().textTheme,
          ),
        ),
        home: const GameScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 950;

    return Scaffold(
      appBar: AppBar(
        title: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              const Icon(Icons.wb_sunny, color: Color(0xFFFBBF24), size: 20),
              const SizedBox(width: 8),
              Text(
                'SOLSTICE ENGINE',
                style: GoogleFonts.orbitron(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  fontSize: 14,
                  color: const Color(0xFFFBBF24),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.brightness_3, color: Color(0xFF38BDF8), size: 16),
              if (!isMobile) ...[
                const SizedBox(width: 15),
                Text(
                  'A Turing Machine of Light & Shadow',
                  style: GoogleFonts.orbitron(
                    fontSize: 10,
                    color: Colors.grey[400],
                  ),
                ),
              ]
            ],
          ),
        ),
        backgroundColor: const Color(0xFF020617), // Deep dark slate
        elevation: 4,
      ),
      body: isMobile
          ? const SingleChildScrollView(
              child: Column(
                children: [
                  MainPanel(isMobile: true),
                  Divider(color: Color(0xFF1E293B), thickness: 2, height: 32),
                  SizedBox(
                    height: 450,
                    child: SidebarPanel(),
                  ),
                ],
              ),
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Expanded(flex: 7, child: MainPanel(isMobile: false)),
                Container(width: 1, color: Colors.blueGrey[700]),
                const Expanded(flex: 3, child: SidebarPanel()),
              ],
            ),
    );
  }
}

class MainPanel extends StatelessWidget {
  final bool isMobile;
  const MainPanel({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GameProvider>(context);
    final level = provider.currentLevel;

    // Build the tape card
    Widget tapeCard = Card(
      color: const Color(0xFF0B0F19), // Extra dark slate
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF1E293B)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: 1.0,
                child: CustomPaint(
                  painter: SolsticeTapePainter(
                    tape: provider.tape,
                    headPosition: provider.headPosition,
                    currentState: provider.currentState,
                    isRunning: provider.isRunning,
                  ),
                ),
              ),
            ),
            // Overlay showing current tape light count
            Positioned(
              bottom: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B).withOpacity(0.9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '☀️ ${provider.tape.where((v) => v == 1).length}  |  🌙 ${provider.tape.where((v) => v == 0).length}',
                  style: GoogleFonts.shareTechMono(fontSize: 11, color: Colors.grey[300]),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    // Build rule header
    Widget rulesHeader = Padding(
      padding: const EdgeInsets.only(top: 12.0, bottom: 8.0),
      child: Text(
        'TRANSITION RULES (PROGRAM)',
        style: GoogleFonts.orbitron(
          color: Colors.grey[400],
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );

    // Build rule list/grid
    Widget rulesWidget = RuleGridWidget(
      rules: provider.activeRules,
      currentState: provider.currentState,
      currentReadVal: provider.tape[provider.headPosition],
      isMobile: isMobile,
      onRuleChanged: (index, writeVal, moveDir, nextState) {
        provider.updateRule(index, writeVal: writeVal, moveDir: moveDir, nextState: nextState);
      },
    );

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Level selection & goal card
          Card(
            color: const Color(0xFF1E293B),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFF334155)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButton<int>(
                          value: provider.currentLevelIndex,
                          isExpanded: true,
                          dropdownColor: const Color(0xFF1E293B),
                          style: GoogleFonts.orbitron(
                            color: const Color(0xFFFBBF24),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          onChanged: (val) {
                            if (val != null) provider.selectLevel(val);
                          },
                          items: List.generate(provider.levels.length, (index) {
                            final lvl = provider.levels[index];
                            return DropdownMenuItem(
                              value: index,
                              child: Text('Lvl ${lvl.id}: ${lvl.name}'),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.blueGrey[700]!),
                        ),
                        child: Text(
                          'STEPS: ${provider.stepsTaken}/${level.maxSteps}',
                          style: GoogleFonts.shareTechMono(
                            color: provider.stepsTaken > level.maxSteps ? Colors.red : const Color(0xFF38BDF8),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    level.description,
                    style: TextStyle(color: Colors.blueGrey[300], fontSize: 11),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFFBBF24).withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.flag_circle, color: Color(0xFFFBBF24), size: 16),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'GOAL: ${level.goalDescription}',
                            style: GoogleFonts.shareTechMono(
                              color: const Color(0xFFFBBF24),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Responsive Middle Section
          if (isMobile) ...[
            // For mobile, stack them vertically with defined heights to prevent overlaps
            SizedBox(
              height: 300,
              child: tapeCard,
            ),
            rulesHeader,
            rulesWidget, // Height is handled internally inside responsive RuleGridWidget
          ] else ...[
            // For desktop, show them side-by-side using expanded layout
            Expanded(
              child: Row(
                children: [
                  Expanded(flex: 5, child: tapeCard),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        rulesHeader,
                        Expanded(child: rulesWidget),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),

          // Controls panel
          Card(
            color: const Color(0xFF1E293B),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFF334155)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  // Status box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: provider.hasWon ? Colors.green.withOpacity(0.5) : Colors.blueGrey[700]!),
                    ),
                    child: Text(
                      'STATUS: ${provider.statusMessage}',
                      style: GoogleFonts.shareTechMono(
                        color: provider.hasWon ? Colors.green : (provider.isRunning ? const Color(0xFFFBBF24) : Colors.grey[300]),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Button Row
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // Reset
                        IconButton(
                          icon: const Icon(Icons.replay),
                          tooltip: 'Reset',
                          color: Colors.red[300],
                          onPressed: provider.resetLevel,
                        ),
                        const SizedBox(width: 4),

                        // Step
                        ElevatedButton.icon(
                          icon: const Icon(Icons.redo, size: 14),
                          label: const Text('STEP', style: TextStyle(fontSize: 11)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueGrey[700],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          ),
                          onPressed: provider.isRunning || provider.hasWon ? null : provider.stepMachine,
                        ),
                        const SizedBox(width: 6),

                        // Run / Pause
                        ElevatedButton.icon(
                          icon: Icon(provider.isRunning ? Icons.pause : Icons.play_arrow, size: 14),
                          label: Text(provider.isRunning ? 'PAUSE' : 'RUN MACHINE', style: const TextStyle(fontSize: 11)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: provider.isRunning ? Colors.amber[700] : const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          onPressed: provider.hasWon
                              ? null
                              : (provider.isRunning ? provider.pauseMachine : provider.runMachine),
                        ),
                        const SizedBox(width: 8),

                        // Speed Indicator
                        const Icon(Icons.speed, size: 14, color: Colors.grey),
                        SizedBox(
                          width: 80,
                          child: Slider(
                            value: (600 - provider.speedMs).toDouble(),
                            min: 0,
                            max: 550,
                            divisions: 11,
                            activeColor: const Color(0xFFFBBF24),
                            onChanged: (val) {
                              provider.speedMs = 600 - val.toInt();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Side Panel: Turing AI / Gemini Chat Interface
class SidebarPanel extends StatefulWidget {
  const SidebarPanel({super.key});

  @override
  State<SidebarPanel> createState() => _SidebarPanelState();
}

class _SidebarPanelState extends State<SidebarPanel> {
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GameProvider>(context);
    _scrollToBottom();

    return Container(
      color: const Color(0xFF0F172A),
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // AI Title header
          Row(
            children: [
              const Icon(Icons.psychology, color: Color(0xFF38BDF8), size: 18),
              const SizedBox(width: 6),
              Text(
                'ALAN TURING & GEMINI AI',
                style: GoogleFonts.orbitron(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  letterSpacing: 1,
                  color: const Color(0xFF38BDF8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Stuck or curious about the science? Consult Alan Turing, hybrid-powered by Google Gemini!',
            style: TextStyle(color: Colors.grey[400], fontSize: 10),
          ),
          const SizedBox(height: 8),

          // Message log box
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF020617),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blueGrey[800]!),
              ),
              child: ListView.builder(
                controller: _scrollController,
                itemCount: provider.chatMessages.length,
                itemBuilder: (context, index) {
                  final msg = provider.chatMessages[index];
                  final isTuring = msg['sender'] == 'Alan Turing';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Column(
                      crossAxisAlignment: isTuring ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isTuring) const Icon(Icons.android, size: 10, color: Color(0xFF38BDF8)),
                            const SizedBox(width: 4),
                            Text(
                              msg['sender'] ?? '',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 9,
                                color: isTuring ? const Color(0xFF38BDF8) : const Color(0xFFFBBF24),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color: isTuring ? const Color(0xFF1E293B) : const Color(0xFF334155),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            msg['message'] ?? '',
                            style: const TextStyle(fontSize: 11, height: 1.3),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 6),

          // Quick prompt buttons
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildQuickPrompt('💡 Ask for a Hint'),
                const SizedBox(width: 4),
                _buildQuickPrompt('☀️ What is the Solstice?'),
                const SizedBox(width: 4),
                _buildQuickPrompt('🔒 How did the Bombe work?'),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Input field
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _chatController,
                  style: const TextStyle(fontSize: 11),
                  decoration: InputDecoration(
                    hintText: 'Ask Alan...',
                    hintStyle: TextStyle(color: Colors.blueGrey[500], fontSize: 11),
                    filled: true,
                    fillColor: const Color(0xFF1E293B),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (val) {
                    provider.sendUserChatMessage(val);
                    _chatController.clear();
                  },
                ),
              ),
              const SizedBox(width: 6),
              IconButton(
                icon: const Icon(Icons.send, color: Color(0xFF38BDF8), size: 18),
                onPressed: () {
                  provider.sendUserChatMessage(_chatController.text);
                  _chatController.clear();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickPrompt(String text) {
    final provider = Provider.of<GameProvider>(context, listen: false);
    return InkWell(
      onTap: () {
        provider.sendUserChatMessage(text);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blueGrey[700]!),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 9, color: Colors.white),
        ),
      ),
    );
  }
}

// Custom Painter for the Circular Solstice tape representation
class SolsticeTapePainter extends CustomPainter {
  final List<int> tape;
  final int headPosition;
  final String currentState;
  final bool isRunning;

  SolsticeTapePainter({
    required this.tape,
    required this.headPosition,
    required this.currentState,
    required this.isRunning,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width / 2;
    final Offset center = Offset(radius, radius);
    final Paint paint = Paint()..style = PaintingStyle.fill;

    // Draw the 24 sectors
    double sectorAngle = 2 * math.pi / 24;

    for (int i = 0; i < 24; i++) {
      double startAngle = i * sectorAngle - math.pi / 2 - sectorAngle / 2;
      
      // Determine sector color
      if (tape[i] == 1) {
        // Light hours: Glowing Solstice gold
        paint.color = const Color(0xFFFBBF24).withOpacity(0.85);
      } else {
        // Dark hours: Cold winter night indigo
        paint.color = const Color(0xFF1E293B);
      }

      // Draw sector arc
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sectorAngle - 0.02, // slightly smaller to create beautiful separator lines
        true,
        paint,
      );

      // Draw outer circle accent
      final borderPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = (i == headPosition) 
            ? const Color(0xFF38BDF8) // Glowing blue for head position
            : Colors.transparent;
            
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sectorAngle - 0.02,
        true,
        borderPaint,
      );
    }

    // Draw internal details of the astronomical clock
    final centerGlow = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF0F172A);
    canvas.drawCircle(center, radius * 0.70, centerGlow);

    // Draw the Earth in the center
    final earthPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF0D9488); // Teal
    canvas.drawCircle(center, radius * 0.25, earthPaint);

    // Draw golden Equator and Axial Tilt lines
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = const Color(0xFFFBBF24).withOpacity(0.6);
      
    // Draw Axial Tilt (23.5 degrees)
    double tiltRad = 23.5 * math.pi / 180;
    canvas.drawLine(
      Offset(center.dx - radius * 0.22 * math.cos(tiltRad), center.dy - radius * 0.22 * math.sin(tiltRad)),
      Offset(center.dx + radius * 0.22 * math.cos(tiltRad), center.dy + radius * 0.22 * math.sin(tiltRad)),
      linePaint,
    );

    // Draw labels around the 24 sectors
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i < 24; i++) {
      double angle = i * sectorAngle - math.pi / 2;
      double labelRadius = radius * 0.82;
      Offset labelPos = Offset(
        center.dx + labelRadius * math.cos(angle),
        center.dy + labelRadius * math.sin(angle),
      );

      textPainter.text = TextSpan(
        text: '$i',
        style: GoogleFonts.shareTechMono(
          color: (i == headPosition) ? const Color(0xFF38BDF8) : Colors.grey[400],
          fontWeight: (i == headPosition) ? FontWeight.bold : FontWeight.normal,
          fontSize: (i == headPosition) ? 10 : 8,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(labelPos.dx - textPainter.width / 2, labelPos.dy - textPainter.height / 2));
    }

    // Draw the Turing Read/Write Head Needle (Astronomical Hand)
    double targetAngle = headPosition * sectorAngle - math.pi / 2;
    final needlePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..color = const Color(0xFF38BDF8); // Glowing neon blue
      
    // Pointy mechanical pointer
    Offset needleTip = Offset(
      center.dx + radius * 0.65 * math.cos(targetAngle),
      center.dy + radius * 0.65 * math.sin(targetAngle),
    );
    canvas.drawLine(center, needleTip, needlePaint);

    // Draw a golden glowing orb at the needle tip
    final headOrb = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF38BDF8);
    canvas.drawCircle(needleTip, 4, headOrb);

    // Draw central screw/dial
    final screwOuter = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF1E293B);
    canvas.drawCircle(center, 20, screwOuter);

    final screwInner = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFFFBBF24);
    canvas.drawCircle(center, 10, screwInner);

    // Write active state inside the center screw
    final statePainter = TextPainter(textDirection: TextDirection.ltr);
    statePainter.text = TextSpan(
      text: currentState,
      style: GoogleFonts.orbitron(
        color: const Color(0xFF0F172A),
        fontWeight: FontWeight.bold,
        fontSize: 8,
      ),
    );
    statePainter.layout();
    statePainter.paint(canvas, Offset(center.dx - statePainter.width / 2, center.dy - statePainter.height / 2));
  }

  @override
  bool shouldRepaint(covariant SolsticeTapePainter oldDelegate) {
    return oldDelegate.tape != tape ||
        oldDelegate.headPosition != headPosition ||
        oldDelegate.currentState != currentState ||
        oldDelegate.isRunning != isRunning;
  }
}

// List Grid representation of editable Turing transition rules
class RuleGridWidget extends StatelessWidget {
  final List<TransitionRule> rules;
  final String currentState;
  final int currentReadVal;
  final bool isMobile;
  final Function(int, int?, String?, String?) onRuleChanged;

  const RuleGridWidget({
    super.key,
    required this.rules,
    required this.currentState,
    required this.currentReadVal,
    required this.isMobile,
    required this.onRuleChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      // For mobile: draw as a single column scrollable list (no grid layout) so elements have full width and do not overlap!
      return Column(
        children: List.generate(rules.length, (index) {
          final rule = rules[index];
          final isActive = (rule.state == currentState && rule.readVal == currentReadVal);
          return Container(
            margin: const EdgeInsets.only(bottom: 8.0),
            height: 90,
            child: _buildRuleCard(index, rule, isActive),
          );
        }),
      );
    } else {
      // For desktop: beautiful 2-column grid
      return GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.45,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: rules.length,
        itemBuilder: (context, index) {
          final rule = rules[index];
          final isActive = (rule.state == currentState && rule.readVal == currentReadVal);
          return _buildRuleCard(index, rule, isActive);
        },
      );
    }
  }

  Widget _buildRuleCard(int index, TransitionRule rule, bool isActive) {
    return Card(
      color: isActive ? const Color(0xFF1E3A8A) : const Color(0xFF1E293B),
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isActive ? const Color(0xFF38BDF8) : const Color(0xFF334155),
          width: isActive ? 2.0 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Rule header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'IF: STATE ${rule.state} & READ ${rule.readVal == 1 ? "☀️" : "🌙"}',
                    style: GoogleFonts.shareTechMono(
                      color: const Color(0xFFFBBF24),
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
                const Spacer(),
                if (isActive)
                  const Row(
                    children: [
                      Icon(Icons.bolt, color: Color(0xFF38BDF8), size: 12),
                      Text(
                        'ACTIVE',
                        style: TextStyle(color: Color(0xFF38BDF8), fontSize: 8, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
              ],
            ),
            const Divider(height: 6, color: Colors.blueGrey),

            // Editable Fields
            Expanded(
              child: Row(
                children: [
                  // Write Val
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('WRITE', style: TextStyle(fontSize: 8, color: Colors.grey)),
                        DropdownButton<int>(
                          value: rule.writeVal,
                          isDense: true,
                          style: const TextStyle(fontSize: 10, color: Colors.white),
                          onChanged: (val) => onRuleChanged(index, val, null, null),
                          items: const [
                            DropdownMenuItem(value: 0, child: Text('🌙 0')),
                            DropdownMenuItem(value: 1, child: Text('☀️ 1')),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Move Dir
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('MOVE', style: TextStyle(fontSize: 8, color: Colors.grey)),
                        DropdownButton<String>(
                          value: rule.moveDir,
                          isDense: true,
                          style: const TextStyle(fontSize: 10, color: Colors.white),
                          onChanged: (val) => onRuleChanged(index, null, val, null),
                          items: const [
                            DropdownMenuItem(value: 'R', child: Text('↻ R')),
                            DropdownMenuItem(value: 'L', child: Text('↺ L')),
                            DropdownMenuItem(value: 'S', child: Text('Stay')),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Next State
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('NEXT', style: TextStyle(fontSize: 8, color: Colors.grey)),
                        DropdownButton<String>(
                          value: rule.nextState,
                          isDense: true,
                          style: const TextStyle(fontSize: 10, color: Colors.white),
                          onChanged: (val) => onRuleChanged(index, null, null, val),
                          items: const [
                            DropdownMenuItem(value: 'A', child: Text('A')),
                            DropdownMenuItem(value: 'B', child: Text('B')),
                            DropdownMenuItem(value: 'C', child: Text('C')),
                            DropdownMenuItem(value: 'H', child: Text('HALT')),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

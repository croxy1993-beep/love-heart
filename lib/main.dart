// lib/main.dart
// Faz 1: Dış hat sık diziliş ile sağdan sola çizilir (boşluksuz).
// Faz 2: İç kısım halkalar halinde dışarıdan içeri dolar.
// Faz 3: Kalp tam dolu/parlak, ortada kelimeler tek tek değişerek yazılır,
//        arkada kıvılcım (sparkle) efekti oynar.
// Faz 4: Her şey söner, döngü baştan başlar.

import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const LoveHeartApp());

class LoveHeartApp extends StatelessWidget {
  const LoveHeartApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const HeartScreen(),
    );
  }
}

const List<String> kLoveWords = [
  "Seni seviyorum", "I love you", "Ich liebe dich", "Je t'aime", "Ti amo",
  "Te amo", "Eu te amo", "Jag älskar dig", "Ik hou van jou", "Σ' αγαπώ",
  "Я тебя люблю", "Я тебе кохаю", "我爱你", "愛してる", "사랑해",
  "ฉันรักคุณ", "Aku cinta kamu", "मैं तुमसे प्यार करता हूँ",
  "Kocham cię", "Anh yêu em", "أحبك", "دوستت دارم", "אני אוהב אותך",
  "Nakupenda", "Minä rakastan sinua", "Jeg elsker deg", "Jeg elsker dig",
  "Miluji tě", "Szeretlek", "Te iubesc", "Обичам те", "Волим те",
  "Mahal kita", "Ngiyakuthanda",
];

class HeartScreen extends StatefulWidget {
  const HeartScreen({super.key});
  @override
  State<HeartScreen> createState() => _HeartScreenState();
}

class _HeartScreenState extends State<HeartScreen>
    with TickerProviderStateMixin {
  late final AnimationController _main;
  late final AnimationController _sparkle;

  late final List<_WordSlot> _outline;
  late final List<List<_WordSlot>> _fillRings;
  late final List<_Spark> _sparks;

  static const double drawPhase = 0.32;
  static const double fillPhase = 0.18;
  static const double holdPhase = 0.35;
  static const double fadePhase = 0.15;

  @override
  void initState() {
    super.initState();
    _main = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat();
    _sparkle = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _outline = _buildOutline();
    _fillRings = _buildFillRings();
    _sparks = _buildSparks();
  }

  @override
  void dispose() {
    _main.dispose();
    _sparkle.dispose();
    super.dispose();
  }

  Offset _heartPoint(double t, double scale) {
    final x = 16 * pow(sin(t), 3).toDouble();
    final y = -(13 * cos(t) - 5 * cos(2 * t) - 2 * cos(3 * t) - cos(4 * t));
    return Offset(x * scale, y * scale);
  }

  List<_WordSlot> _buildOutline() {
    const pointCount = 70;
    final slots = <_WordSlot>[];
    for (int i = 0; i < pointCount; i++) {
      final t = (i / pointCount) * 2 * pi;
      final p = _heartPoint(t, 1.0);
      final word = kLoveWords[i % kLoveWords.length];
      slots.add(_WordSlot(
        text: word,
        pos: p,
        order: i / pointCount,
        fontScale: 1.0,
      ));
    }
    return slots;
  }

  List<List<_WordSlot>> _buildFillRings() {
    const scales = [0.82, 0.66, 0.50, 0.35, 0.20];
    final rings = <List<_WordSlot>>[];
    int wordCursor = 3;
    for (final scale in scales) {
      final count = (40 * scale).round().clamp(10, 40);
      final ring = <_WordSlot>[];
      for (int i = 0; i < count; i++) {
        final t = (i / count) * 2 * pi;
        final p = _heartPoint(t, scale);
        final word = kLoveWords[(wordCursor + i) % kLoveWords.length];
        ring.add(_WordSlot(
          text: word,
          pos: p,
          order: 0,
          fontScale: 0.55 + scale * 0.3,
        ));
      }
      rings.add(ring);
      wordCursor += 5;
    }
    return rings;
  }

  List<_Spark> _buildSparks() {
    final rnd = Random(11);
    return List.generate(28, (i) {
      return _Spark(
        angle: rnd.nextDouble() * 2 * pi,
        radius: 0.5 + rnd.nextDouble() * 0.9,
        phase: rnd.nextDouble(),
        speed: 0.6 + rnd.nextDouble() * 0.8,
        size: 1.5 + rnd.nextDouble() * 2.5,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final heartSize = min(size.width * 0.92, 380.0);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AnimatedBuilder(
          animation: Listenable.merge([_main, _sparkle]),
          builder: (context, _) {
            final v = _main.value;

            double outlineProgress;
            double fillProgress;
            double sceneOpacity;
            bool showCenterWord;
            double centerWordT = 0;

            if (v < drawPhase) {
              outlineProgress = v / drawPhase;
              fillProgress = 0;
              sceneOpacity = 1;
              showCenterWord = false;
            } else if (v < drawPhase + fillPhase) {
              outlineProgress = 1;
              fillProgress = (v - drawPhase) / fillPhase;
              sceneOpacity = 1;
              showCenterWord = false;
            } else if (v < drawPhase + fillPhase + holdPhase) {
              outlineProgress = 1;
              fillProgress = 1;
              sceneOpacity = 1;
              showCenterWord = true;
              centerWordT = (v - drawPhase - fillPhase) / holdPhase;
            } else {
              outlineProgress = 1;
              fillProgress = 1;
              final fadeT =
                  (v - drawPhase - fillPhase - holdPhase) / fadePhase;
              sceneOpacity = (1 - fadeT).clamp(0.0, 1.0);
              showCenterWord = false;
            }

            final beat = (v >= drawPhase + fillPhase &&
                    v < drawPhase + fillPhase + holdPhase)
                ? 1.0 +
                    0.035 *
                        sin((v - drawPhase - fillPhase) / holdPhase * 8 * pi)
                : 1.0;

            return SizedBox(
              width: heartSize,
              height: heartSize,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Opacity(
                    opacity: sceneOpacity,
                    child: CustomPaint(
                      size: Size(heartSize, heartSize),
                      painter: _SparklePainter(
                        sparks: _sparks,
                        time: _sparkle.value,
                        intensity: showCenterWord ? 1.0 : 0.4,
                      ),
                    ),
                  ),
                  Transform.scale(
                    scale: beat,
                    child: Opacity(
                      opacity: sceneOpacity,
                      child: SizedBox(
                        width: heartSize,
                        height: heartSize,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            for (int r = 0; r < _fillRings.length; r++)
                              if (fillProgress >=
                                  (r + 1) / _fillRings.length - 0.001)
                                for (final slot in _fillRings[r])
                                  _wordText(slot, heartSize, 1.0,
                                      glow: 0.55 + 0.45 * fillProgress),
                            for (final slot in _outline)
                              _wordText(
                                slot,
                                heartSize,
                                outlineProgress >= slot.order ? 1.0 : 0.0,
                                glow: 1.0,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (showCenterWord)
                    _CenterWordCycler(
                      t: centerWordT,
                      heartSize: heartSize,
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _wordText(_WordSlot slot, double heartSize, double opacity,
      {required double glow}) {
    return Transform.translate(
      offset: Offset(
        slot.pos.dx * (heartSize / 34),
        slot.pos.dy * (heartSize / 34),
      ),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: opacity,
        child: Text(
          slot.text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color.lerp(
              const Color(0xFF4A0A0A),
              const Color(0xFFFF3B30),
              glow,
            ),
            fontSize: heartSize * 0.026 * slot.fontScale,
            fontWeight: FontWeight.w600,
            shadows: [
              Shadow(
                color: const Color(0xFFFF3B30).withOpacity(glow * 0.85),
                blurRadius: 10 * glow,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WordSlot {
  final String text;
  final Offset pos;
  final double order;
  final double fontScale;
  _WordSlot({
    required this.text,
    required this.pos,
    required this.order,
    required this.fontScale,
  });
}

class _CenterWordCycler extends StatelessWidget {
  final double t;
  final double heartSize;
  const _CenterWordCycler({required this.t, required this.heartSize});

  @override
  Widget build(BuildContext context) {
    const wordsToCycle = 10;
    final segment = t * wordsToCycle;
    final index = segment.floor().clamp(0, wordsToCycle - 1);
    final localT = segment - index;

    double op;
    if (localT < 0.2) {
      op = localT / 0.2;
    } else if (localT < 0.8) {
      op = 1.0;
    } else {
      op = 1.0 - (localT - 0.8) / 0.2;
    }

    final word = kLoveWords[index % kLoveWords.length];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: heartSize * 0.08,
        vertical: heartSize * 0.03,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35 * op),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Opacity(
        opacity: op,
        child: Text(
          word,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: heartSize * 0.065,
            fontWeight: FontWeight.bold,
            shadows: const [
              Shadow(color: Color(0xFFFF3B30), blurRadius: 18),
              Shadow(color: Colors.white, blurRadius: 6),
            ],
          ),
        ),
      ),
    );
  }
}

class _Spark {
  final double angle;
  final double radius;
  final double phase;
  final double speed;
  final double size;
  _Spark({
    required this.angle,
    required this.radius,
    required this.phase,
    required this.speed,
    required this.size,
  });
}

class _SparklePainter extends CustomPainter {
  final List<_Spark> sparks;
  final double time;
  final double intensity;
  _SparklePainter({
    required this.sparks,
    required this.time,
    required this.intensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxR = size.width / 2;

    for (final s in sparks) {
      final twinkle = (sin(2 * pi * (time * s.speed + s.phase)) + 1) / 2;
      final opacity = (0.15 + twinkle * 0.6) * intensity;
      if (opacity <= 0.02) continue;

      final pos = center +
          Offset(
            cos(s.angle) * s.radius * maxR,
            sin(s.angle) * s.radius * maxR,
          );

      final paint = Paint()
        ..color = Color.lerp(
          const Color(0xFFFFD166),
          const Color(0xFFFF3B30),
          twinkle,
        )!
            .withOpacity(opacity.clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;

      canvas.drawCircle(pos, s.size * (0.6 + twinkle * 0.6), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SparklePainter oldDelegate) => true;
}

// lib/main.dart
// Kalp hattı boyunca kelimeler sırayla belirir ("çizilir"),
// tam tur bitince kalp dolu ve parlak kalır, sonra sönüp yeniden başlar.

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
  "Seni seviyorum",
  "I love you",
  "Ich liebe dich",
  "Je t'aime",
  "Ti amo",
  "Te amo",
  "Eu te amo",
  "Jag älskar dig",
  "Ik hou van jou",
  "Σ' αγαπώ",
  "Я тебя люблю",
  "Я тебе кохаю",
  "我爱你",
  "愛してる",
  "사랑해",
  "ฉันรักคุณ",
  "Aku cinta kamu",
  "मैं तुमसे प्यार करता हूँ",
  "Kocham cię",
  "Anh yêu em",
];

class HeartScreen extends StatefulWidget {
  const HeartScreen({super.key});
  @override
  State<HeartScreen> createState() => _HeartScreenState();
}

class _HeartScreenState extends State<HeartScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_WordSlot> _slots;

  static const double drawPhase = 0.55;
  static const double holdPhase = 0.30;
  static const double fadePhase = 0.15;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 9),
    )..repeat();
    _slots = _buildHeartSlots();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<_WordSlot> _buildHeartSlots() {
    final n = kLoveWords.length;
    final slots = <_WordSlot>[];
    for (int i = 0; i < n; i++) {
      final t = (i / n) * 2 * pi;
      final x = 16 * pow(sin(t), 3).toDouble();
      final y = -(13 * cos(t) -
          5 * cos(2 * t) -
          2 * cos(3 * t) -
          cos(4 * t));
      slots.add(_WordSlot(
        text: kLoveWords[i],
        dx: x,
        dy: y,
        order: i / n,
      ));
    }
    return slots;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final heartSize = min(size.width * 0.92, 380.0);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final v = _controller.value;

            double drawProgress;
            double fillGlow;
            if (v < drawPhase) {
              drawProgress = v / drawPhase;
              fillGlow = drawProgress;
            } else if (v < drawPhase + holdPhase) {
              drawProgress = 1.0;
              fillGlow = 1.0;
            } else {
              drawProgress = 1.0;
              final fadeT = (v - drawPhase - holdPhase) / fadePhase;
              fillGlow = 1.0 - fadeT;
            }

            final beat = (v >= drawPhase && v < drawPhase + holdPhase)
                ? 1.0 + 0.04 * sin((v - drawPhase) / holdPhase * 6 * pi)
                : 1.0;

            return Transform.scale(
              scale: beat,
              child: SizedBox(
                width: heartSize,
                height: heartSize,
                child: Stack(
                  alignment: Alignment.center,
                  children: _slots.map((slot) {
                    final reached = drawProgress >= slot.order;
                    final justAppeared =
                        (drawProgress - slot.order).clamp(0.0, 0.08) / 0.08;

                    double opacity;
                    double glow;
                    if (!reached) {
                      opacity = 0.0;
                      glow = 0.0;
                    } else {
                      opacity = 0.25 + fillGlow * 0.75;
                      glow = (justAppeared < 1.0 ? 1.0 : fillGlow)
                          .clamp(0.0, 1.0);
                    }

                    return Transform.translate(
                      offset: Offset(
                        slot.dx * (heartSize / 34),
                        slot.dy * (heartSize / 34),
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
                            fontSize: heartSize * 0.034,
                            fontWeight: FontWeight.w600,
                            shadows: [
                              Shadow(
                                color: const Color(0xFFFF3B30)
                                    .withOpacity(glow * 0.9),
                                blurRadius: 12 * glow,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _WordSlot {
  final String text;
  final double dx, dy;
  final double order;
  _WordSlot({
    required this.text,
    required this.dx,
    required this.dy,
    required this.order,
  });
}

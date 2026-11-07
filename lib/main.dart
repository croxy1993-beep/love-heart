// lib/main.dart
// Flutter tek dosya uygulama — Android ve iOS'ta aynı kodla çalışır.
// "I love you" 20 dilde, kalp şeklinde dizilir, kalp atışı gibi büyüyüp küçülür,
// kelimeler teker teker parlayarak (glow) belirip kaybolur.

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
    with TickerProviderStateMixin {
  late final AnimationController _beatController;
  late final AnimationController _wordController;
  late final List<_WordSlot> _slots;

  @override
  void initState() {
    super.initState();

    _beatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _wordController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _slots = _buildHeartSlots();
  }

  @override
  void dispose() {
    _beatController.dispose();
    _wordController.dispose();
    super.dispose();
  }

  List<_WordSlot> _buildHeartSlots() {
    final rnd = Random(7);
    final slots = <_WordSlot>[];
    final n = kLoveWords.length;
    for (int i = 0; i < n; i++) {
      final t = (i / n) * 2 * pi;
      double x = 16 * pow(sin(t), 3).toDouble();
      double y = -(13 * cos(t) -
          5 * cos(2 * t) -
          2 * cos(3 * t) -
          cos(4 * t));
      final scaleIn = 0.35 + rnd.nextDouble() * 0.65;
      x *= scaleIn;
      y *= scaleIn;

      slots.add(_WordSlot(
        text: kLoveWords[i],
        dx: x,
        dy: y,
        phase: rnd.nextDouble(),
        fontSize: 11 + rnd.nextDouble() * 7,
        bold: rnd.nextBool(),
      ));
    }
    return slots;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AnimatedBuilder(
          animation: Listenable.merge([_beatController, _wordController]),
          builder: (context, _) {
            final beat = _heartbeatCurve(_beatController.value);
            final scale = 0.9 + beat * 0.14;

            return Transform.scale(
              scale: scale,
              child: SizedBox(
                width: 340,
                height: 340,
                child: Stack(
                  alignment: Alignment.center,
                  children: _slots.map((slot) {
                    final glow = _glowFor(slot.phase, _wordController.value);
                    return Transform.translate(
                      offset: Offset(slot.dx * 10, slot.dy * 10),
                      child: Opacity(
                        opacity: 0.15 + glow * 0.85,
                        child: Text(
                          slot.text,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color.lerp(
                              const Color(0xFF3A0A0A),
                              const Color(0xFFFF3B30),
                              glow,
                            ),
                            fontSize: slot.fontSize,
                            fontWeight:
                                slot.bold ? FontWeight.bold : FontWeight.w400,
                            shadows: [
                              Shadow(
                                color: const Color(0xFFFF3B30)
                                    .withOpacity(glow * 0.9),
                                blurRadius: 10 * glow,
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

  double _heartbeatCurve(double t) {
    final a = sin(t * pi).abs();
    final b = sin(t * pi * 2).abs() * 0.4;
    return (a * 0.7 + b).clamp(0.0, 1.0);
  }

  double _glowFor(double phase, double t) {
    final v = sin(2 * pi * (t + phase));
    return (v + 1) / 2;
  }
}

class _WordSlot {
  final String text;
  final double dx, dy;
  final double phase;
  final double fontSize;
  final bool bold;
  _WordSlot({
    required this.text,
    required this.dx,
    required this.dy,
    required this.phase,
    required this.fontSize,
    required this.bold,
  });
}

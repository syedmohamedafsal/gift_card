import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome Gift',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(scaffoldBackgroundColor: Colors.transparent),
      home: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Color(0xFF1A1714),
              Color.fromARGB(255, 140, 127, 50),
              Color(0xFF1A1714),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: const WelcomeGiftScreen(),
      ),
    );
  }
}

enum _CardStyle { amazon, flipkart, swiggy, paytm, phonepe }

class GiftCard {
  final String brand;
  final String offerLine1;
  final String offerLine2;
  final String offerLine3;
  final Color cardBg;
  final Color accentColor;
  final Color offerTextColor;
  final _CardStyle style;

  const GiftCard({
    required this.brand,
    required this.offerLine1,
    required this.offerLine2,
    required this.offerLine3,
    required this.cardBg,
    required this.accentColor,
    required this.offerTextColor,
    required this.style,
  });
}

class WelcomeGiftScreen extends StatefulWidget {
  const WelcomeGiftScreen({super.key});

  @override
  State<WelcomeGiftScreen> createState() => _WelcomeGiftScreenState();
}

class _WelcomeGiftScreenState extends State<WelcomeGiftScreen>
    with TickerProviderStateMixin {
  double _currentPage = 2.0;
  late AnimationController _snapController;
  late Animation<double> _snapAnim;
  bool _isDraggingCard = false;

  bool _isDraggingDown = false;
  double _dragOffsetY = 0;

  late AnimationController _activateController;
  late Animation<double> _glowAnim;
  late Animation<double> _cardSinkAnim;
  bool _activated = false;

  late AnimationController _chevronController;
  late Animation<double> _chevronAnim;

  // Bottom bar entry animation
  late AnimationController _entryController;
  late Animation<double> _entryAnim;

  static const double cardW = 185.0;
  static const double cardH = 268.0;
  static const double cardSpacing = 220.0;

  final List<GiftCard> cards = const [
    GiftCard(
      brand: 'Flipkart',
      offerLine1: '30%',
      offerLine2: 'cashback',
      offerLine3: 'up to ₹150',
      cardBg: Color(0xFF2874F0),
      accentColor: Color(0xFFFFE500),
      offerTextColor: Colors.white,
      style: _CardStyle.flipkart,
    ),
    GiftCard(
      brand: 'PhonePe',
      offerLine1: '₹50',
      offerLine2: 'cashback',
      offerLine3: 'on recharge',
      cardBg: Color(0xFF5F259F),
      accentColor: Color(0xFFFFFFFF),
      offerTextColor: Colors.white,
      style: _CardStyle.phonepe,
    ),
    GiftCard(
      brand: 'amazon',
      offerLine1: '50%',
      offerLine2: 'cashback',
      offerLine3: 'up to ₹100',
      cardBg: Color(0xFF1B3A5C),
      accentColor: Color(0xFFFF9900),
      offerTextColor: Color(0xFFFFD700),
      style: _CardStyle.amazon,
    ),
    GiftCard(
      brand: 'Swiggy',
      offerLine1: '₹75',
      offerLine2: 'cashback',
      offerLine3: 'on orders',
      cardBg: Color(0xFFFC8019),
      accentColor: Color(0xFFFFFFFF),
      offerTextColor: Colors.white,
      style: _CardStyle.swiggy,
    ),
    GiftCard(
      brand: 'Paytm',
      offerLine1: '20%',
      offerLine2: 'cashback',
      offerLine3: 'up to ₹200',
      cardBg: Color(0xFF00BAF2),
      accentColor: Color(0xFF002970),
      offerTextColor: Colors.white,
      style: _CardStyle.paytm,
    ),
  ];

  @override
  void initState() {
    super.initState();

    _snapController = AnimationController(
      duration: const Duration(milliseconds: 380),
      vsync: this,
    );
    _snapAnim = Tween<double>(
      begin: _currentPage,
      end: _currentPage,
    ).animate(_snapController);
    _snapController.addListener(() {
      setState(() => _currentPage = _snapAnim.value);
    });

    _activateController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _glowAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _activateController, curve: Curves.easeOut),
    );
    _cardSinkAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _activateController, curve: Curves.easeIn),
    );

    _chevronController = AnimationController(
      duration: const Duration(milliseconds: 850),
      vsync: this,
    )..repeat(reverse: true);
    _chevronAnim = Tween<double>(begin: 0.0, end: 7.0).animate(
      CurvedAnimation(parent: _chevronController, curve: Curves.easeInOut),
    );

    // Entry animation — slides up + fades in on load
    _entryController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _entryAnim = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOutBack,
    );
    // Start entry after a short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _entryController.forward();
    });
  }

  @override
  void dispose() {
    _snapController.dispose();
    _activateController.dispose();
    _chevronController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  int get _centerIndex => _currentPage.round().clamp(0, cards.length - 1);

  void _snapToIndex(int index) {
    final double target = index.toDouble().clamp(0, cards.length - 1);
    _snapAnim = Tween<double>(begin: _currentPage, end: target).animate(
      CurvedAnimation(parent: _snapController, curve: Curves.easeOutCubic),
    );
    _snapController.forward(from: 0.0);
  }

  void _onHorizontalDragStart(DragStartDetails d) {
    _snapController.stop();
    _isDraggingCard = true;
  }

  void _onHorizontalDragUpdate(DragUpdateDetails d) {
    if (!_isDraggingCard) return;
    setState(() {
      _currentPage = (_currentPage - d.delta.dx / cardSpacing).clamp(
        0,
        cards.length - 1.0,
      );
    });
  }

  void _onHorizontalDragEnd(DragEndDetails d) {
    _isDraggingCard = false;
    final double velocity = d.primaryVelocity ?? 0;
    int target = _currentPage.round();
    if (velocity < -300)
      target = (_currentPage.ceil()).clamp(0, cards.length - 1);
    if (velocity > 300)
      target = (_currentPage.floor()).clamp(0, cards.length - 1);
    _snapToIndex(target);
  }

  void _onVerticalDragUpdate(DragUpdateDetails d) {
    if (d.delta.dy > 0) {
      setState(() {
        _isDraggingDown = true;
        _dragOffsetY = (_dragOffsetY + d.delta.dy).clamp(0.0, 120.0);
      });
    }
  }

  void _onVerticalDragEnd(DragEndDetails d) {
    if (_dragOffsetY > 60) {
      _triggerActivation();
    } else {
      setState(() {
        _isDraggingDown = false;
        _dragOffsetY = 0;
      });
    }
  }

  void _triggerActivation() async {
    setState(() => _activated = true);
    await _activateController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${cards[_centerIndex].brand} offer activated! 🎉'),
          backgroundColor: cards[_centerIndex].cardBg,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    await Future.delayed(const Duration(milliseconds: 200));
    _activateController.reverse();
    setState(() {
      _activated = false;
      _isDraggingDown = false;
      _dragOffsetY = 0;
    });
  }

  double get _dragProgress {
    if (_activated) return _cardSinkAnim.value;
    return (_dragOffsetY / 80.0).clamp(0.0, 1.0);
  }

  double get _borderOpacity => (1.0 - _dragProgress * 0.7).clamp(0.3, 1.0);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_activateController, _entryController]),
      builder: (context, _) {
        final double prog = _dragProgress;
        final double entry = _entryAnim.value; // 0→1 on load

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              // ── Expanding golden glow from bottom ──
              if (prog > 0)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: 40 + (prog * 400),
                      height: 40 + (prog * 500),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFFFFD700).withOpacity(0.55 * prog),
                            const Color(0xFFFFD700).withOpacity(0.18 * prog),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),

              SafeArea(
                child: Column(
                  children: [
                    // ── Top bar ──
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.maybePop(context),
                            child: const Icon(
                              Icons.chevron_left,
                              color: Colors.white70,
                              size: 26,
                            ),
                          ),
                          const Spacer(),
                          const Text(
                            'T&Cs',
                            style: TextStyle(
                              color: Color(0xFFFFD700),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),
                    _GiftBoxIcon(),
                    const SizedBox(height: 16),

                    const Text(
                      'Choose your\nwelcome gift',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── Carousel ──
                    Expanded(
                      child: GestureDetector(
                        onHorizontalDragStart: _onHorizontalDragStart,
                        onHorizontalDragUpdate: _onHorizontalDragUpdate,
                        onHorizontalDragEnd: _onHorizontalDragEnd,
                        onVerticalDragUpdate: _onVerticalDragUpdate,
                        onVerticalDragEnd: _onVerticalDragEnd,
                        behavior: HitTestBehavior.opaque,
                        child: Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: [
                            _buildStaticBorder(),
                            ..._buildSideCards(),
                            _buildCenterCard(prog),
                          ],
                        ),
                      ),
                    ),

                    // ── Dot indicators ──
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(cards.length, (i) {
                          final bool active = i == _centerIndex;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: active ? 20 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: active
                                  ? const Color(0xFFFFD700)
                                  : Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          );
                        }),
                      ),
                    ),

                    // ── Drag label ──
                    GestureDetector(
                      onVerticalDragUpdate: _onVerticalDragUpdate,
                      onVerticalDragEnd: _onVerticalDragEnd,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Column(
                          children: [
                            AnimatedBuilder(
                              animation: _chevronAnim,
                              builder: (ctx, child) => Transform.translate(
                                offset: Offset(0, _chevronAnim.value),
                                child: child,
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.expand_more,
                                    color: const Color(
                                      0xFFFFD700,
                                    ).withOpacity(0.4),
                                    size: 22,
                                  ),
                                  Icon(
                                    Icons.expand_more,
                                    color: const Color(0xFFFFD700),
                                    size: 22,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 200),
                              style: TextStyle(
                                color: Color.lerp(
                                  const Color(0xFFFFD700),
                                  Colors.white,
                                  prog,
                                )!,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              child: Text(
                                prog > 0.6
                                    ? 'Release to activate!'
                                    : 'Drag down to activate offer',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ── Custom bottom bar with entry animation ──
                    Transform.translate(
                      offset: Offset(0, (1 - entry) * 80),
                      child: Opacity(
                        opacity: entry.clamp(0.0, 1.0),
                        child: _WavePillBar(
                          dragProgress: prog,
                          isActive: _activated,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildSideCards() {
    final List<Widget> result = [];
    for (int i = 0; i < cards.length; i++) {
      if (i == _centerIndex) continue;
      final double slot = i - _currentPage;
      if (slot.abs() > 1.8) continue;
      result.add(_buildCardAtSlot(i, slot));
    }
    return result;
  }

  Widget _buildCenterCard(double prog) {
    final double slot = _centerIndex - _currentPage;
    final double dragDy =
        _dragOffsetY.clamp(0.0, 80.0) +
        (_activated ? _cardSinkAnim.value * 120 : 0);
    final double sinkScale = (1.0 - prog * 0.08).clamp(0.88, 1.0);

    return Transform.translate(
      offset: Offset(slot * cardSpacing, dragDy),
      child: Transform.scale(
        scale: sinkScale,
        child: GestureDetector(
          onTap: () => _snapToIndex(_centerIndex),
          child: _CardWidget(card: cards[_centerIndex]),
        ),
      ),
    );
  }

  Widget _buildCardAtSlot(int index, double slot) {
    final double rotate = slot * 0.22;
    final double tx = slot * cardSpacing;
    final double ty = slot.abs() * 18.0;
    final double scale = (1.0 - slot.abs() * 0.08).clamp(0.84, 1.0);
    return Transform.translate(
      offset: Offset(tx, ty),
      child: Transform.rotate(
        angle: rotate,
        child: Transform.scale(
          scale: scale,
          child: GestureDetector(
            onTap: () => _snapToIndex(index),
            child: _CardWidget(card: cards[index]),
          ),
        ),
      ),
    );
  }

  Widget _buildStaticBorder() {
    final double opacity = _borderOpacity;
    return IgnorePointer(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: cardW + 28,
            height: cardH + 28,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withOpacity(0.55 * opacity),
                  blurRadius: 32,
                  spreadRadius: 4,
                ),
              ],
            ),
          ),
          Container(
            width: cardW + 6,
            height: cardH + 6,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(23),
              border: Border.all(
                color: const Color(0xFFFFD700).withOpacity(opacity),
                width: 2.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  Custom Wave-Pill Bottom Bar  ---|_____|---
//  Shape: flat lines on sides, dips down in the center
//  The pill glows gold when drag is in progress
// ═══════════════════════════════════════════════════════════
class _WavePillBar extends StatelessWidget {
  final double dragProgress; // 0.0 → 1.0
  final bool isActive;

  const _WavePillBar({required this.dragProgress, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final Color lineColor = Color.lerp(
      Colors.white.withOpacity(0.25),
      const Color(0xFFFFD700).withOpacity(0.9),
      dragProgress,
    )!;

    final List<BoxShadow> glowShadows = dragProgress > 0.2
        ? [
            BoxShadow(
              color: const Color(0xFFFFD700).withOpacity(0.55 * dragProgress),
              blurRadius: 16,
              spreadRadius: 2,
            ),
          ]
        : [];

    return Container(
      width: double.infinity,
      height: 36,
      padding: const EdgeInsets.only(bottom: 8),
      child: CustomPaint(
        painter: _WavePillPainter(
          color: lineColor,
          glowColor: const Color(0xFFFFD700).withOpacity(0.6 * dragProgress),
          progress: dragProgress,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Painter: draws  ---|___|---  shape
// ─────────────────────────────────────────
class _WavePillPainter extends CustomPainter {
  final Color color;
  final Color glowColor;
  final double progress;

  const _WavePillPainter({
    required this.color,
    required this.glowColor,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;

    // Dip depth grows slightly with drag progress
    final double dipDepth = 10.0 + progress * 6.0;
    // Pill width at the bottom of the dip
    final double pillHalfW = 50.0;
    // Where the curve starts/ends (x offset from center)
    final double curveStartX = pillHalfW + 28.0;
    // Flat line extends to this x from center
    final double lineEndX = size.width * 0.5 - 10;

    // ── Glow pass (draw wider, blurred stroke below) ──
    if (progress > 0) {
      final glowPaint = Paint()
        ..color = glowColor
        ..strokeWidth = 6.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawPath(
        _buildPath(cx, cy, dipDepth, pillHalfW, curveStartX, lineEndX, size),
        glowPaint,
      );
    }

    // ── Main stroke ──
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(
      _buildPath(cx, cy, dipDepth, pillHalfW, curveStartX, lineEndX, size),
      paint,
    );
  }

  Path _buildPath(
    double cx,
    double cy,
    double dipDepth,
    double pillHalfW,
    double curveStartX,
    double lineEndX,
    Size size,
  ) {
    final path = Path();

    // Left flat line:  start from left edge → to curve start
    final double leftLineStart = cx - lineEndX;
    final double leftCurveStart = cx - curveStartX;
    final double rightCurveEnd = cx + curveStartX;
    final double rightLineEnd = cx + lineEndX;

    // Bottom of the dip
    final double dipY = cy + dipDepth;
    // Top of the flat lines
    final double lineY = cy;

    // Left flat line
    path.moveTo(leftLineStart, lineY);
    path.lineTo(leftCurveStart, lineY);

    // Left curve going down into the dip
    // Control point pulls the curve smoothly downward
    path.cubicTo(
      leftCurveStart + 20,
      lineY, // cp1: stay flat briefly
      cx - pillHalfW - 8,
      dipY, // cp2: arrive at dip level
      cx - pillHalfW,
      dipY, // end: left edge of pill
    );

    // Pill bottom (straight line at dip)
    path.lineTo(cx + pillHalfW, dipY);

    // Right curve going back up
    path.cubicTo(
      cx + pillHalfW + 8,
      dipY, // cp1: leave dip horizontally
      rightCurveEnd - 20,
      lineY, // cp2: arrive back at line level
      rightCurveEnd,
      lineY, // end: right curve end
    );

    // Right flat line
    path.lineTo(rightLineEnd, lineY);

    return path;
  }

  @override
  bool shouldRepaint(_WavePillPainter old) =>
      old.progress != progress || old.color != color;
}

// ─────────────────────────────────────────
// Gift box icon
// ─────────────────────────────────────────
class _GiftBoxIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFF252018),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFFFD700).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: CustomPaint(painter: _GiftPainter()),
    );
  }
}

class BottomActivateBar extends StatelessWidget {
  final double progress;
  final int total;
  final int index;

  const BottomActivateBar({
    super.key,
    required this.progress,
    required this.total,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
      width: double.infinity,
      decoration: const BoxDecoration(color: Color(0xFF1E1A15)),
      child: Column(
        children: [
          /// WAVE LINE
          SizedBox(
            height: 40,
            width: double.infinity,
            child: CustomPaint(painter: _WavePainter(progress)),
          ),

          /// DOTS
          const SizedBox(height: 6),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(total, (i) {
              final active = i == index;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: active ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: active
                      ? const Color(0xFFFFD700)
                      : Colors.white.withOpacity(.3),
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),

          const SizedBox(height: 6),

          /// CHEVRONS
          const Icon(Icons.expand_more, color: Color(0xFFFFD700), size: 22),

          const Icon(Icons.expand_more, color: Color(0xFFFFD700), size: 22),

          const SizedBox(height: 4),

          /// TEXT
          const Text(
            "Drag down to activate offer",
            style: TextStyle(
              color: Color(0xFFFFD700),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final double progress;

  _WavePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final dip = 14 + (progress * 6);

    final path = Path();

    path.moveTo(0, 0);
    path.lineTo(cx - 70, 0);

    path.cubicTo(cx - 40, 0, cx - 40, dip, cx, dip);

    path.cubicTo(cx + 40, dip, cx + 40, 0, cx + 70, 0);

    path.lineTo(size.width, 0);

    /// Glow
    final glow = Paint()
      ..color = const Color(0xFFFFD700).withOpacity(.5)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    canvas.drawPath(path, glow);

    /// Line
    final paint = Paint()
      ..color = const Color(0xFF9A7A2A)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _GiftPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 14, cy - 6, 28, 18),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFFE8541A),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 15, cy - 12, 30, 8),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFFFF6B35),
    );
    final rp = Paint()..color = const Color(0xFFFFD700);
    canvas.drawRect(Rect.fromLTWH(cx - 3, cy - 13, 6, 32), rp);
    canvas.drawRect(Rect.fromLTWH(cx - 15, cy - 9, 30, 5), rp);
    final bp = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.fill;
    canvas.drawPath(
      Path()
        ..moveTo(cx, cy - 13)
        ..quadraticBezierTo(cx - 10, cy - 22, cx - 6, cy - 14)
        ..close(),
      bp,
    );
    canvas.drawPath(
      Path()
        ..moveTo(cx, cy - 13)
        ..quadraticBezierTo(cx + 10, cy - 22, cx + 6, cy - 14)
        ..close(),
      bp,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─────────────────────────────────────────
// Card widget
// ─────────────────────────────────────────
class _CardWidget extends StatelessWidget {
  final GiftCard card;
  const _CardWidget({required this.card});

  static const double w = _WelcomeGiftScreenState.cardW;
  static const double h = _WelcomeGiftScreenState.cardH;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: w,
        height: h,
        color: card.cardBg,
        child: Stack(
          children: [
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.07),
                ),
              ),
            ),
            Positioned(
              bottom: -20,
              left: -20,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _logo(),
                  const SizedBox(height: 14),
                  Text(
                    card.offerLine1,
                    style: TextStyle(
                      color: card.offerTextColor,
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                    ),
                  ),
                  Text(
                    card.offerLine2,
                    style: TextStyle(
                      color: card.offerTextColor.withOpacity(0.9),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                  Text(
                    card.offerLine3,
                    style: TextStyle(
                      color: card.offerTextColor.withOpacity(0.85),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                  ),
                  const Spacer(),
                  _illustration(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _logo() {
    switch (card.style) {
      case _CardStyle.amazon:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'amazon',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
            CustomPaint(
              size: const Size(64, 6),
              painter: _SmilePainter(color: const Color(0xFFFF9900)),
            ),
          ],
        );
      case _CardStyle.flipkart:
        return Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                color: Color(0xFFFFE500),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  'F',
                  style: TextStyle(
                    color: Color(0xFF2874F0),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              'flipkart',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        );
      case _CardStyle.swiggy:
        return Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  'S',
                  style: TextStyle(
                    color: Color(0xFFFC8019),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              'swiggy',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        );
      case _CardStyle.paytm:
        return Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                color: Color(0xFF002970),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  'P',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              'Paytm',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        );
      case _CardStyle.phonepe:
        return Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  'Ph',
                  style: TextStyle(
                    color: Color(0xFF5F259F),
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              'PhonePe',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        );
    }
  }

  Widget _illustration() {
    switch (card.style) {
      case _CardStyle.amazon:
        return SizedBox(
          width: double.infinity,
          height: 100,
          child: CustomPaint(painter: _AmazonBoxPainter()),
        );
      case _CardStyle.flipkart:
        return SizedBox(
          width: double.infinity,
          height: 95,
          child: CustomPaint(painter: _FlipkartBagPainter()),
        );
      case _CardStyle.swiggy:
        return SizedBox(
          width: double.infinity,
          height: 95,
          child: CustomPaint(painter: _SwiggyBagPainter()),
        );
      case _CardStyle.paytm:
        return SizedBox(
          width: double.infinity,
          height: 95,
          child: CustomPaint(painter: _PaytmPainter()),
        );
      case _CardStyle.phonepe:
        return SizedBox(
          width: double.infinity,
          height: 95,
          child: CustomPaint(painter: _PhonePePainter()),
        );
    }
  }
}

// ── Painters ──
class _SmilePainter extends CustomPainter {
  final Color color;
  const _SmilePainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(
      Path()
        ..moveTo(0, 2)
        ..quadraticBezierTo(size.width / 2, size.height + 2, size.width, 2),
      p,
    );
    canvas.drawLine(Offset(size.width - 4, 0), Offset(size.width, 2), p);
    canvas.drawLine(Offset(size.width - 4, 4), Offset(size.width, 2), p);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _AmazonBoxPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    const bw = 80.0, bh = 60.0;
    final bx = cx - bw / 2;
    final by = size.height - bh - 4;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(bx + 4, by + 8, bw, bh),
        const Radius.circular(4),
      ),
      Paint()
        ..color = Colors.black.withOpacity(0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(bx, by, bw, bh),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFFFF9900),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(bx, by, bw, bh * 0.28),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFFFFB347),
    );
    canvas.drawLine(
      Offset(cx, by),
      Offset(cx, by + bh),
      Paint()
        ..color = const Color(0xFFFFD580)
        ..strokeWidth = 4,
    );
    canvas.drawPath(
      Path()
        ..moveTo(cx - 14, by + bh * 0.55)
        ..quadraticBezierTo(cx, by + bh * 0.72, cx + 14, by + bh * 0.55),
      Paint()
        ..color = const Color(0xFF1B3A5C)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

class _FlipkartBagPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    const bw = 72.0, bh = 62.0;
    final bx = cx - bw / 2;
    final by = size.height - bh;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(bx + 3, by + 6, bw, bh),
        const Radius.circular(6),
      ),
      Paint()
        ..color = Colors.black.withOpacity(0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(bx, by, bw, bh),
        const Radius.circular(6),
      ),
      Paint()..color = const Color(0xFFFFE500),
    );
    final hp = Paint()
      ..color = const Color(0xFF2874F0)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromLTWH(cx - 22, by - 16, 20, 20),
      3.14,
      3.14,
      false,
      hp,
    );
    canvas.drawArc(
      Rect.fromLTWH(cx + 2, by - 16, 20, 20),
      3.14,
      3.14,
      false,
      hp,
    );
    final tp = TextPainter(
      text: const TextSpan(
        text: 'F',
        style: TextStyle(
          color: Color(0xFF2874F0),
          fontSize: 26,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, by + bh / 2 - tp.height / 2));
  }

  @override
  bool shouldRepaint(_) => false;
}

class _SwiggyBagPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    const bw = 70.0, bh = 58.0;
    final bx = cx - bw / 2;
    final by = size.height - bh;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(bx, by, bw, bh),
        const Radius.circular(8),
      ),
      Paint()..color = Colors.white.withOpacity(0.25),
    );
    final tp = TextPainter(
      text: const TextSpan(
        text: 'S',
        style: TextStyle(
          color: Colors.white,
          fontSize: 30,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, by + bh / 2 - tp.height / 2));
    canvas.drawArc(
      Rect.fromLTWH(cx - 18, by - 14, 36, 20),
      3.14,
      3.14,
      false,
      Paint()
        ..color = Colors.white.withOpacity(0.7)
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

class _PaytmPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    const bw = 72.0, bh = 55.0;
    final bx = cx - bw / 2;
    final by = size.height - bh;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(bx, by, bw, bh),
        const Radius.circular(10),
      ),
      Paint()..color = const Color(0xFF002970),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(bx + 5, by + 5, bw - 10, bh - 15),
        const Radius.circular(6),
      ),
      Paint()..color = const Color(0xFF00BAF2),
    );
    final tp = TextPainter(
      text: const TextSpan(
        text: '₹',
        style: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(cx - tp.width / 2, by + (bh - 15) / 2 - tp.height / 2 + 5),
    );
    canvas.drawCircle(
      Offset(cx, by + bh - 6),
      4,
      Paint()..color = Colors.white.withOpacity(0.5),
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

class _PhonePePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    const r = 32.0;
    final cy = size.height - r - 4;
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()..color = const Color(0xFF5F259F).withOpacity(0.35),
    );
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..color = Colors.white.withOpacity(0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    final tp = TextPainter(
      text: const TextSpan(
        text: 'Ph',
        style: TextStyle(
          color: Colors.white,
          fontSize: 26,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));
  }

  @override
  bool shouldRepaint(_) => false;
}

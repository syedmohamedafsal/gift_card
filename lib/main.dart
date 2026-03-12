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

// ─────────────────────────────────────────
// Data model
// ─────────────────────────────────────────
class GiftCard {
  final String brand;
  final String offerLine1;
  final String offerLine2;
  final String offerLine3;
  final Color cardBg;
  final Color accentColor; // for text / logo bar
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

enum _CardStyle { amazon, flipkart, swiggy }

// ─────────────────────────────────────────
// Screen
// ─────────────────────────────────────────
class WelcomeGiftScreen extends StatefulWidget {
  const WelcomeGiftScreen({super.key});

  @override
  State<WelcomeGiftScreen> createState() => _WelcomeGiftScreenState();
}

class _WelcomeGiftScreenState extends State<WelcomeGiftScreen>
    with TickerProviderStateMixin {
  int _centerIndex = 1;

  late AnimationController _controller;
  late Animation<double> _animation;
  late AnimationController _chevronController;
  late Animation<double> _chevronAnim;

  bool _isDragging = false;
  double _dragOffsetY = 0;

  final List<GiftCard> cards = const [
    GiftCard(
      brand: 'flipkart',
      offerLine1: '30%',
      offerLine2: 'cashback',
      offerLine3: 'up to ₹150',
      cardBg: Color(0xFF2874F0),
      accentColor: Color(0xFFFFE500),
      offerTextColor: Colors.white,
      style: _CardStyle.flipkart,
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
      brand: 'swiggy',
      offerLine1: '₹75',
      offerLine2: 'cashback',
      offerLine3: 'on orders',
      cardBg: Color(0xFFFC8019),
      accentColor: Color(0xFFFFFFFF),
      offerTextColor: Colors.white,
      style: _CardStyle.swiggy,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 0.0).animate(_controller);

    _chevronController = AnimationController(
      duration: const Duration(milliseconds: 850),
      vsync: this,
    )..repeat(reverse: true);
    _chevronAnim = Tween<double>(begin: 0.0, end: 7.0).animate(
      CurvedAnimation(parent: _chevronController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _chevronController.dispose();
    super.dispose();
  }

  void _selectCard(int tappedIndex) {
    if (tappedIndex == _centerIndex) return;
    final double fromOffset = _animation.value;
    final double toOffset = (1 - tappedIndex).toDouble();
    _animation = Tween<double>(
      begin: fromOffset,
      end: toOffset,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    setState(() => _centerIndex = tappedIndex);
    _controller.forward(from: 0.0);
  }

  void _onDragUpdate(DragUpdateDetails d) {
    setState(() {
      _isDragging = true;
      _dragOffsetY += d.delta.dy;
    });
  }

  void _onDragEnd(DragEndDetails d) {
    if (_dragOffsetY > 60) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${cards[_centerIndex].brand} offer activated! 🎉'),
          backgroundColor: cards[_centerIndex].accentColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    setState(() {
      _isDragging = false;
      _dragOffsetY = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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

            // ── Gift icon ──
            _GiftBoxIcon(),

            const SizedBox(height: 16),

            // ── Title ──
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
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  final double offset = _animation.value;
                  return Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      for (int i = 0; i < cards.length; i++)
                        if (i != _centerIndex) _buildCard(i, offset),
                      _buildCard(_centerIndex, offset),
                    ],
                  );
                },
              ),
            ),

            // ── Chevrons ──
            GestureDetector(
              onVerticalDragUpdate: _onDragUpdate,
              onVerticalDragEnd: _onDragEnd,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 32),
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
                            color: const Color(0xFFFFD700).withOpacity(0.4),
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
                    const SizedBox(height: 6),
                    const Text(
                      'Drag down to activate offer',
                      style: TextStyle(
                        color: Color(0xFFFFD700),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(int index, double offset) {
    final double slot = (index - 1) + offset;
    final double absSlot = slot.abs();
    if (absSlot > 1.6) return const SizedBox.shrink();

    const double sideX = 208.0;
    const double sideY = 2.0;
    const double maxRotate = -0.28;

    final double tx = slot * sideX;
    final double ty = absSlot * sideY;
    final double rotate = slot * maxRotate;
    // final double scale = (1.0 - absSlot * 0.18).clamp(0.72, 1.0);

    final bool isCenter = index == _centerIndex;
    final double dragDy = (isCenter && _isDragging)
        ? _dragOffsetY.clamp(-20.0, 90.0)
        : 0.0;

    const double scale = 1.0;

    return Transform.translate(
      offset: Offset(tx, ty + dragDy),
      child: Transform.rotate(
        angle: rotate,
        child: Transform.scale(
          scale: scale,
          child: GestureDetector(
            onTap: () => _selectCard(index),
            onVerticalDragUpdate: isCenter ? _onDragUpdate : null,
            onVerticalDragEnd: isCenter ? _onDragEnd : null,
            child: _CardWidget(card: cards[index], isCenter: isCenter),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Gift box icon (drawn with widgets)
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

class _GiftPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Box body
    final boxPaint = Paint()..color = const Color(0xFFE8541A);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 14, cy - 6, 28, 18),
        const Radius.circular(3),
      ),
      boxPaint,
    );

    // Lid
    final lidPaint = Paint()..color = const Color(0xFFFF6B35);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 15, cy - 12, 30, 8),
        const Radius.circular(3),
      ),
      lidPaint,
    );

    // Ribbon vertical
    final ribbonPaint = Paint()..color = const Color(0xFFFFD700);
    canvas.drawRect(Rect.fromLTWH(cx - 3, cy - 13, 6, 32), ribbonPaint);

    // Ribbon horizontal
    canvas.drawRect(Rect.fromLTWH(cx - 15, cy - 9, 30, 5), ribbonPaint);

    // Bow left loop
    final bowPaint = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.fill;
    final bowPath = Path()
      ..moveTo(cx, cy - 13)
      ..quadraticBezierTo(cx - 10, cy - 22, cx - 6, cy - 14)
      ..close();
    canvas.drawPath(bowPath, bowPaint);

    // Bow right loop
    final bowPath2 = Path()
      ..moveTo(cx, cy - 13)
      ..quadraticBezierTo(cx + 10, cy - 22, cx + 6, cy - 14)
      ..close();
    canvas.drawPath(bowPath2, bowPaint);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─────────────────────────────────────────
// Individual card widget
// ─────────────────────────────────────────
class _CardWidget extends StatelessWidget {
  final GiftCard card;
  final bool isCenter;

  const _CardWidget({required this.card, required this.isCenter});

  @override
  Widget build(BuildContext context) {
    const double cW = 185.0, cH = 268.0;
    const double sW = 145.0, sH = 215.0;
    final double w = isCenter ? cW : sW;
    final double h = isCenter ? cH : sH;

    return Stack(
      alignment: Alignment.center,
      children: [
        // ── Gold glow layers (center only) ──
        if (isCenter) ...[
          Container(
            width: w + 28,
            height: h + 28,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withOpacity(0.6),
                  blurRadius: 28,
                  spreadRadius: 3,
                ),
                BoxShadow(
                  color: const Color(0xFFFFD700).withOpacity(0.20),
                  blurRadius: 60,
                  spreadRadius: 12,
                ),
              ],
            ),
          ),
          // Gold border
          Container(
            width: w + 6,
            height: h + 6,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(23),
              border: Border.all(color: const Color(0xFFFFD700), width: 2.5),
            ),
          ),
        ],

        // ── Card body ──
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: w,
            height: h,
            color: card.cardBg,
            child: Stack(
              children: [
                // Background decorative circles
                Positioned(
                  top: -30,
                  right: -30,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.06),
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

                // ── Content ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Brand logo bar
                      _buildBrandBar(isCenter),

                      SizedBox(height: isCenter ? 14 : 10),

                      // Offer text
                      Text(
                        card.offerLine1,
                        style: TextStyle(
                          color: card.offerTextColor,
                          fontSize: isCenter ? 36 : 26,
                          fontWeight: FontWeight.w900,
                          height: 1.0,
                        ),
                      ),
                      Text(
                        card.offerLine2,
                        style: TextStyle(
                          color: card.offerTextColor.withOpacity(0.9),
                          fontSize: isCenter ? 16 : 12,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                      ),
                      Text(
                        card.offerLine3,
                        style: TextStyle(
                          color: card.offerTextColor.withOpacity(0.85),
                          fontSize: isCenter ? 14 : 10,
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                        ),
                      ),

                      const Spacer(),

                      // ── Bottom illustration ──
                      _buildIllustration(w, isCenter),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBrandBar(bool isCenter) {
    switch (card.style) {
      case _CardStyle.amazon:
        return _AmazonLogo(isCenter: isCenter);
      case _CardStyle.flipkart:
        return _FlipkartLogo(isCenter: isCenter);
      case _CardStyle.swiggy:
        return _SwiggyLogo(isCenter: isCenter);
    }
  }

  Widget _buildIllustration(double cardWidth, bool isCenter) {
    switch (card.style) {
      case _CardStyle.amazon:
        return _AmazonIllustration(cardWidth: cardWidth, isCenter: isCenter);
      case _CardStyle.flipkart:
        return _FlipkartIllustration(cardWidth: cardWidth, isCenter: isCenter);
      case _CardStyle.swiggy:
        return _SwiggyIllustration(cardWidth: cardWidth, isCenter: isCenter);
    }
  }
}

// ─────────────────────────────────────────
// Amazon Logo
// ─────────────────────────────────────────
class _AmazonLogo extends StatelessWidget {
  final bool isCenter;
  const _AmazonLogo({required this.isCenter});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'amazon',
          style: TextStyle(
            color: Colors.white,
            fontSize: isCenter ? 18 : 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
        // Smile underline
        CustomPaint(
          size: Size(isCenter ? 64 : 48, 6),
          painter: _SmilePainter(color: const Color(0xFFFF9900)),
        ),
      ],
    );
  }
}

class _SmilePainter extends CustomPainter {
  final Color color;
  const _SmilePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(0, 2)
      ..quadraticBezierTo(size.width / 2, size.height + 2, size.width, 2);
    canvas.drawPath(path, paint);

    // Arrow tip
    canvas.drawLine(Offset(size.width - 4, 0), Offset(size.width, 2), paint);
    canvas.drawLine(Offset(size.width - 4, 4), Offset(size.width, 2), paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─────────────────────────────────────────
// Flipkart Logo
// ─────────────────────────────────────────
class _FlipkartLogo extends StatelessWidget {
  final bool isCenter;
  const _FlipkartLogo({required this.isCenter});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: isCenter ? 22 : 16,
          height: isCenter ? 22 : 16,
          decoration: const BoxDecoration(
            color: Color(0xFFFFE500),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              'F',
              style: TextStyle(
                color: const Color(0xFF2874F0),
                fontSize: isCenter ? 12 : 9,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          'flipkart',
          style: TextStyle(
            color: Colors.white,
            fontSize: isCenter ? 15 : 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────
// Swiggy Logo
// ─────────────────────────────────────────
class _SwiggyLogo extends StatelessWidget {
  final bool isCenter;
  const _SwiggyLogo({required this.isCenter});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: isCenter ? 22 : 16,
          height: isCenter ? 22 : 16,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              'S',
              style: TextStyle(
                color: const Color(0xFFFC8019),
                fontSize: isCenter ? 12 : 9,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          'swiggy',
          style: TextStyle(
            color: Colors.white,
            fontSize: isCenter ? 15 : 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────
// Amazon box illustration (drawn with canvas)
// ─────────────────────────────────────────
class _AmazonIllustration extends StatelessWidget {
  final double cardWidth;
  final bool isCenter;
  const _AmazonIllustration({required this.cardWidth, required this.isCenter});

  @override
  Widget build(BuildContext context) {
    final double h = isCenter ? 100.0 : 75.0;
    return SizedBox(
      width: double.infinity,
      height: h,
      child: CustomPaint(painter: _AmazonBoxPainter(isCenter: isCenter)),
    );
  }
}

class _AmazonBoxPainter extends CustomPainter {
  final bool isCenter;
  const _AmazonBoxPainter({required this.isCenter});

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double scale = isCenter ? 1.0 : 0.75;

    // Box dimensions
    final double bw = 80 * scale;
    final double bh = 60 * scale;
    final double bx = cx - bw / 2;
    final double by = size.height - bh - 4;

    // Box shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(bx + 4, by + 8, bw, bh),
        const Radius.circular(4),
      ),
      shadowPaint,
    );

    // Box body
    final bodyPaint = Paint()..color = const Color(0xFFFF9900);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(bx, by, bw, bh),
        const Radius.circular(4),
      ),
      bodyPaint,
    );

    // Box top lighter strip
    final topPaint = Paint()..color = const Color(0xFFFFB347);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(bx, by, bw, bh * 0.28),
        const Radius.circular(4),
      ),
      topPaint,
    );

    // Tape line
    final tapePaint = Paint()
      ..color = const Color(0xFFFFD580)
      ..strokeWidth = 4 * scale;
    canvas.drawLine(Offset(cx, by), Offset(cx, by + bh), tapePaint);

    // Amazon smile on box
    final smilePaint = Paint()
      ..color = const Color(0xFF1B3A5C)
      ..strokeWidth = 2 * scale
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final smilePath = Path()
      ..moveTo(cx - 14 * scale, by + bh * 0.55)
      ..quadraticBezierTo(cx, by + bh * 0.72, cx + 14 * scale, by + bh * 0.55);
    canvas.drawPath(smilePath, smilePaint);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─────────────────────────────────────────
// Flipkart bag illustration
// ─────────────────────────────────────────
class _FlipkartIllustration extends StatelessWidget {
  final double cardWidth;
  final bool isCenter;
  const _FlipkartIllustration({
    required this.cardWidth,
    required this.isCenter,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: isCenter ? 95.0 : 72.0,
      child: CustomPaint(painter: _FlipkartBagPainter(isCenter: isCenter)),
    );
  }
}

class _FlipkartBagPainter extends CustomPainter {
  final bool isCenter;
  const _FlipkartBagPainter({required this.isCenter});

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double s = isCenter ? 1.0 : 0.75;
    final double bw = 72 * s, bh = 62 * s;
    final double bx = cx - bw / 2;
    final double by = size.height - bh;

    // Shadow
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(bx + 3, by + 6, bw, bh),
        const Radius.circular(6),
      ),
      Paint()
        ..color = Colors.black.withOpacity(0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // Bag body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(bx, by, bw, bh),
        const Radius.circular(6),
      ),
      Paint()..color = const Color(0xFFFFE500),
    );

    // Handle left
    final handlePaint = Paint()
      ..color = const Color(0xFF2874F0)
      ..strokeWidth = 4 * s
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromLTWH(cx - 22 * s, by - 16 * s, 20 * s, 20 * s),
      3.14,
      3.14,
      false,
      handlePaint,
    );
    // Handle right
    canvas.drawArc(
      Rect.fromLTWH(cx + 2 * s, by - 16 * s, 20 * s, 20 * s),
      3.14,
      3.14,
      false,
      handlePaint,
    );

    // F logo on bag
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'F',
        style: TextStyle(
          color: const Color(0xFF2874F0),
          fontSize: 26 * s,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(cx - textPainter.width / 2, by + bh / 2 - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─────────────────────────────────────────
// Swiggy bag illustration
// ─────────────────────────────────────────
class _SwiggyIllustration extends StatelessWidget {
  final double cardWidth;
  final bool isCenter;
  const _SwiggyIllustration({required this.cardWidth, required this.isCenter});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: isCenter ? 95.0 : 72.0,
      child: CustomPaint(painter: _SwiggyBagPainter(isCenter: isCenter)),
    );
  }
}

class _SwiggyBagPainter extends CustomPainter {
  final bool isCenter;
  const _SwiggyBagPainter({required this.isCenter});

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double s = isCenter ? 1.0 : 0.75;
    final double bw = 70 * s, bh = 58 * s;
    final double bx = cx - bw / 2;
    final double by = size.height - bh;

    // Bag body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(bx, by, bw, bh),
        const Radius.circular(8),
      ),
      Paint()..color = Colors.white.withOpacity(0.25),
    );

    // Swiggy S
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'S',
        style: TextStyle(
          color: Colors.white,
          fontSize: 30 * s,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(cx - textPainter.width / 2, by + bh / 2 - textPainter.height / 2),
    );

    // Handle
    final handlePaint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..strokeWidth = 4 * s
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromLTWH(cx - 18 * s, by - 14 * s, 36 * s, 20 * s),
      3.14,
      3.14,
      false,
      handlePaint,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

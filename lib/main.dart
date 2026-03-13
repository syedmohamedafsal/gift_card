import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const _App());

class _App extends StatelessWidget {
  const _App();
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(scaffoldBackgroundColor: Colors.transparent),
    home: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF1A1714), Color(0xFF8C7F32), Color(0xFF1A1714)],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: const WelcomeGiftScreen(),
    ),
  );
}

// ─────────────────────────────────────────────────────────────
//  DATA
// ─────────────────────────────────────────────────────────────

enum _Brand { amazon, flipkart, swiggy, paytm, phonepe }

class GiftCard {
  final _Brand brand;
  final String name;
  final String line1, line2, line3;
  final Color bg, accent, textColor;
  const GiftCard({
    required this.brand,
    required this.name,
    required this.line1,
    required this.line2,
    required this.line3,
    required this.bg,
    required this.accent,
    required this.textColor,
  });
}

const _cards = <GiftCard>[
  GiftCard(
    brand: _Brand.flipkart,
    name: 'Flipkart',
    line1: '30%',
    line2: 'cashback',
    line3: 'up to ₹150',
    bg: Color(0xFF2874F0),
    accent: Color(0xFFFFE500),
    textColor: Colors.white,
  ),
  GiftCard(
    brand: _Brand.phonepe,
    name: 'PhonePe',
    line1: '₹50',
    line2: 'cashback',
    line3: 'on recharge',
    bg: Color(0xFF5F259F),
    accent: Colors.white,
    textColor: Colors.white,
  ),
  GiftCard(
    brand: _Brand.amazon,
    name: 'amazon',
    line1: '50%',
    line2: 'cashback',
    line3: 'up to ₹100',
    bg: Color(0xFF1B3A5C),
    accent: Color(0xFFFF9900),
    textColor: Color(0xFFFFD700),
  ),
  GiftCard(
    brand: _Brand.swiggy,
    name: 'Swiggy',
    line1: '₹75',
    line2: 'cashback',
    line3: 'on orders',
    bg: Color(0xFFFC8019),
    accent: Colors.white,
    textColor: Colors.white,
  ),
  GiftCard(
    brand: _Brand.paytm,
    name: 'Paytm',
    line1: '20%',
    line2: 'cashback',
    line3: 'up to ₹200',
    bg: Color(0xFF00BAF2),
    accent: Color(0xFF002970),
    textColor: Colors.white,
  ),
];

// ─────────────────────────────────────────────────────────────
//  CONSTANTS
// ─────────────────────────────────────────────────────────────

const _kW = 185.0;
const _kH = 268.0;
const _kGap = 220.0;
const _kGold = Color(0xFFFFD700);

const _confettiColors = <Color>[
  Color(0xFFFFD700),
  Color(0xFFFF6B35),
  Color(0xFF4CAF50),
  Color(0xFFE91E63),
  Color(0xFF2196F3),
  Color(0xFFFF9800),
  Color(0xFF9C27B0),
  Color(0xFF00BCD4),
];

// ─────────────────────────────────────────────────────────────
//  CONFETTI
// ─────────────────────────────────────────────────────────────

class _Particle {
  double x, y, vx, vy, angle, spin, size;
  Color color;
  bool circle;

  _Particle(math.Random r)
    : x = 0,
      y = 0,
      vx = 0,
      vy = 0,
      angle = r.nextDouble() * math.pi * 2,
      spin = (r.nextDouble() - 0.5) * 0.35,
      size = r.nextDouble() * 9 + 5,
      color = _confettiColors[r.nextInt(_confettiColors.length)],
      circle = r.nextBool() {
    final a = r.nextDouble() * math.pi * 2;
    final speed = r.nextDouble() * 15 + 5;
    vx = math.cos(a) * speed;
    vy = math.sin(a) * speed - 6;
  }

  void tick() {
    x += vx;
    y += vy;
    vy += 0.6;
    angle += spin;
  }

  bool get dead => y > 1200;
}

// ─────────────────────────────────────────────────────────────
//  SCREEN
// ─────────────────────────────────────────────────────────────

class WelcomeGiftScreen extends StatefulWidget {
  const WelcomeGiftScreen({super.key});
  @override
  State<WelcomeGiftScreen> createState() => _WelcomeGiftScreenState();
}

class _WelcomeGiftScreenState extends State<WelcomeGiftScreen>
    with TickerProviderStateMixin {
  // carousel
  double _page = 2.0;
  bool _hDrag = false;
  late final AnimationController _snapCtrl;
  late Animation<double> _snapAnim;

  // drag-down
  double _dragY = 0;

  // sink
  late final AnimationController _sinkCtrl;

  // overlay burst
  bool _showOverlay = false;
  late final AnimationController _overlayCtrl;
  late final Animation<double> _bgFade;
  late final Animation<double> _textFade;
  late final Animation<double> _cardSlide;
  late final Animation<double> _cardScale;
  late final Animation<double> _burstScale;
  late final Animation<double> _burstFade;

  // confetti
  final _rng = math.Random();
  final List<_Particle> _particles = [];

  // chevron
  late final AnimationController _chevCtrl;
  late final Animation<double> _chevY;

  // entry
  late final AnimationController _entryCtrl;
  late final Animation<double> _entryAnim;

  int get _center => _page.round().clamp(0, _cards.length - 1);
  double get _prog => (_dragY / 90.0).clamp(0.0, 1.0);

  double get _cardDy {
    if (_dragY <= 80) return _dragY;
    return 80 + (_dragY - 80) * 0.35;
  }

  double get _totalDy => _cardDy + _sinkCtrl.value * 400;

  @override
  void initState() {
    super.initState();

    _snapCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _snapAnim = Tween<double>(begin: _page, end: _page).animate(_snapCtrl);
    _snapCtrl.addListener(() => setState(() => _page = _snapAnim.value));

    _sinkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _sinkCtrl.addListener(() => setState(() {}));

    _overlayCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _bgFade = _interval(0.00, 0.18, Curves.easeOut);
    _textFade = _interval(0.10, 0.28, Curves.easeOut);
    _burstScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _overlayCtrl,
        curve: const Interval(0.00, 0.22, curve: Curves.easeOutBack),
      ),
    );
    _burstFade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _overlayCtrl,
        curve: const Interval(0.18, 0.38, curve: Curves.easeIn),
      ),
    );
    _cardSlide = Tween<double>(begin: 700.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _overlayCtrl,
        curve: const Interval(0.38, 1.00, curve: Curves.easeOutBack),
      ),
    );
    _cardScale = Tween<double>(begin: 0.35, end: 1.0).animate(
      CurvedAnimation(
        parent: _overlayCtrl,
        curve: const Interval(0.38, 1.00, curve: Curves.easeOutBack),
      ),
    );
    _overlayCtrl.addListener(_tickParticles);

    _chevCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    )..repeat(reverse: true);
    _chevY = Tween<double>(
      begin: 0.0,
      end: 7.0,
    ).animate(CurvedAnimation(parent: _chevCtrl, curve: Curves.easeInOut));

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _entryAnim = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutBack);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _entryCtrl.forward();
    });
  }

  Animation<double> _interval(double t0, double t1, Curve curve) =>
      Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _overlayCtrl,
          curve: Interval(t0, t1, curve: curve),
        ),
      );

  @override
  void dispose() {
    _snapCtrl.dispose();
    _sinkCtrl.dispose();
    _overlayCtrl.dispose();
    _chevCtrl.dispose();
    _entryCtrl.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────
  //  GESTURES
  // ─────────────────────────────────────────────────────

  void _onHStart(DragStartDetails d) {
    _snapCtrl.stop();
    _hDrag = true;
  }

  void _onHUpdate(DragUpdateDetails d) {
    if (!_hDrag) return;
    setState(
      () =>
          _page = (_page - d.delta.dx / _kGap).clamp(0.0, _cards.length - 1.0),
    );
  }

  void _onHEnd(DragEndDetails d) {
    _hDrag = false;
    final v = d.primaryVelocity ?? 0;
    int t = _page.round();
    if (v < -300) t = _page.ceil().clamp(0, _cards.length - 1);
    if (v > 300) t = _page.floor().clamp(0, _cards.length - 1);
    _snapTo(t);
  }

  void _snapTo(int i) {
    _snapAnim = Tween<double>(
      begin: _page,
      end: i.toDouble().clamp(0.0, _cards.length - 1.0),
    ).animate(CurvedAnimation(parent: _snapCtrl, curve: Curves.easeOutCubic));
    _snapCtrl.forward(from: 0.0);
  }

  void _onVUpdate(DragUpdateDetails d) {
    if (d.delta.dy <= 0) return;
    setState(() => _dragY = (_dragY + d.delta.dy).clamp(0.0, 160.0));
  }

  void _onVEnd(DragEndDetails d) {
    _dragY >= 65 ? _activate() : setState(() => _dragY = 0);
  }

  void _onLPStart(LongPressStartDetails _) => HapticFeedback.lightImpact();
  void _onLPMove(LongPressMoveUpdateDetails d) {
    final dy = d.offsetFromOrigin.dy;
    if (dy <= 0) return;
    setState(() => _dragY = dy.clamp(0.0, 160.0));
  }

  void _onLPEnd(LongPressEndDetails _) {
    _dragY >= 65 ? _activate() : setState(() => _dragY = 0);
  }

  // ─────────────────────────────────────────────────────
  //  ACTIVATION SEQUENCE
  // ─────────────────────────────────────────────────────

  Future<void> _activate() async {
    HapticFeedback.mediumImpact();

    await _sinkCtrl.animateTo(
      1.0,
      curve: Curves.easeIn,
      duration: const Duration(milliseconds: 480),
    );

    HapticFeedback.heavyImpact();

    for (int i = 0; i < 80; i++) _particles.add(_Particle(_rng));

    setState(() {
      _showOverlay = true;
    });
    _sinkCtrl.reset();
    _dragY = 0;

    _overlayCtrl.forward(from: 0.0);
  }

  void _closeOverlay() {
    setState(() {
      _showOverlay = false;
      _particles.clear();
    });
    _overlayCtrl.reset();
  }

  void _tickParticles() {
    if (!_showOverlay) return;
    setState(() {
      for (final p in _particles) p.tick();
      _particles.removeWhere((p) => p.dead);
    });
  }

  // ─────────────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_sinkCtrl, _entryCtrl, _chevCtrl]),
      builder: (context, _) {
        final p = _prog;
        final entry = _entryAnim.value;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              SafeArea(
                child: Column(
                  children: [
                    _topBar(),
                    const SizedBox(height: 12),
                    const _GiftIcon(),
                    const SizedBox(height: 16),
                    _title(p),
                    const SizedBox(height: 32),
                    Expanded(child: _carousel(p)),
                    Container(
  height: 160,
  decoration: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.transparent,
        const Color(0xFF6B5E1E).withOpacity(0.85),
        const Color(0xFF4A4210),
      ],
      stops: const [0.0, 0.4, 1.0],
    ),
  ),
),
                  ],
                ),
              ),
              if (_showOverlay) _overlay(),
            ],
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────
  //  TOP BAR
  // ─────────────────────────────────────────────────────

  Widget _topBar() => Padding(
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
            color: _kGold,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );

  // ─────────────────────────────────────────────────────
  //  TITLE
  // ─────────────────────────────────────────────────────

  Widget _title(double p) {
    final release = p > 0.6;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: Text(
        release ? 'Release to\nactivate offer!' : 'Choose your\nwelcome gift',
        key: ValueKey(release),
        textAlign: TextAlign.center,
        style: TextStyle(
          color: release ? _kGold : Colors.white,
          fontSize: 26,
          fontWeight: FontWeight.w700,
          height: 1.25,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────
  //  CAROUSEL
  // ─────────────────────────────────────────────────────

  Widget _carousel(double p) {
    return GestureDetector(
      onHorizontalDragStart: _onHStart,
      onHorizontalDragUpdate: _onHUpdate,
      onHorizontalDragEnd: _onHEnd,
      onVerticalDragUpdate: _onVUpdate,
      onVerticalDragEnd: _onVEnd,
      onLongPressStart: _onLPStart,
      onLongPressMoveUpdate: _onLPMove,
      onLongPressEnd: _onLPEnd,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.hardEdge,
        children: [
          // ── L1: glow pool — removed ──
          const SizedBox.shrink(),

          // ── L2: hole dark background ──
          _holeBack(p),

          // ── L3: gold border ring + side glow ──
          _borderRing(p),

          // ── L4: side cards ──
          ..._sideCards(),

          // ── L5: center card ──
          _centerCard(),

          // ── L6: hole front mask ──
          _holeMask(p),

          // ── L7: chevron ──
          if (p > 0) _chevronHint(p),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────
  //  L2 — HOLE BACK
  // ─────────────────────────────────────────────────────

  Widget _holeBack(double p) {
    if (p == 0 && _sinkCtrl.value == 0) return const SizedBox.shrink();
    final opacity = ((p + _sinkCtrl.value) * 1.6).clamp(0.0, 1.0);
    return IgnorePointer(
      child: Opacity(
        opacity: opacity,
        child: Container(
          width: _kW,
          height: _kH,
          decoration: BoxDecoration(
            color: const Color(0xFF060404),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.9),
                blurRadius: 30,
                spreadRadius: 8,
                offset: const Offset(0, 8),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────
  //  L3 — BORDER RING + SIDE GLOW
  // ─────────────────────────────────────────────────────

  Widget _borderRing(double p) {
    return IgnorePointer(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Soft side + top glow using CustomPaint
          if (p > 0)
            SizedBox(
              width: _kW + 300,
              height: _kH + 300,
              child: CustomPaint(painter: _SideGlowPainter(p)),
            ),

          // Border stroke
          Container(
            width: _kW + 6,
            height: _kH + 6,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(23),
              border: Border.all(
                color: _kGold.withOpacity((0.40 + p * 0.60).clamp(0, 1)),
                width: 2.5 + p * 2.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────
  //  L5 — CENTER CARD
  // ─────────────────────────────────────────────────────

  Widget _centerCard() {
    final slot = _center - _page;
    return Transform.translate(
      offset: Offset(slot * _kGap, _totalDy),
      child: GestureDetector(
        onTap: () => _snapTo(_center),
        child: _CardWidget(card: _cards[_center]),
      ),
    );
  }

  // ─────────────────────────────────────────────────────
  //  L6 — HOLE MASK
  // ─────────────────────────────────────────────────────

  Widget _holeMask(double p) {
    final op = (p * 2.0 + _sinkCtrl.value * 2.0).clamp(0.0, 1.0);
    if (op <= 0) return const SizedBox.shrink();
    return IgnorePointer(
      child: CustomPaint(painter: _HoleMaskPainter(opacity: op)),
    );
  }

  // ─────────────────────────────────────────────────────
  //  SIDE CARDS
  // ─────────────────────────────────────────────────────

  List<Widget> _sideCards() {
    final out = <Widget>[];
    for (int i = 0; i < _cards.length; i++) {
      if (i == _center) continue;
      final slot = i - _page;
      if (slot.abs() > 1.8) continue;
      out.add(
        Transform.translate(
          offset: Offset(slot * _kGap, slot.abs() * 18),
          child: Transform.rotate(
            angle: slot * 0.22,
            child: Transform.scale(
              scale: (1 - slot.abs() * 0.08).clamp(0.84, 1.0),
              child: GestureDetector(
                onTap: () => _snapTo(i),
                child: _CardWidget(card: _cards[i]),
              ),
            ),
          ),
        ),
      );
    }
    return out;
  }

  // ─────────────────────────────────────────────────────
  //  CHEVRON HINT
  // ─────────────────────────────────────────────────────

  Widget _chevronHint(double p) {
    final opacity = p <= 0.5 ? p * 2.0 : (1.0 - p) * 2.0;
    return Positioned(
      bottom: -(_kH / 2) + 8,
      child: IgnorePointer(
        child: Opacity(
          opacity: opacity.clamp(0.0, 1.0),
          child: AnimatedBuilder(
            animation: _chevY,
            builder: (_, child) => Transform.translate(
              offset: Offset(0, _chevY.value),
              child: child,
            ),
            child: Column(
              children: [
                Icon(Icons.expand_more, color: _kGold.withOpacity(0.4), size: 26),
                Icon(Icons.expand_more, color: _kGold, size: 26),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────
  //  DOTS
  // ─────────────────────────────────────────────────────

  Widget _dots() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_cards.length, (i) {
        final active = i == _center;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 20 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: active ? _kGold : Colors.white.withOpacity(0.30),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    ),
  );

  // ─────────────────────────────────────────────────────
  //  DRAG LABEL
  // ─────────────────────────────────────────────────────

  Widget _dragLabel(double p) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Column(
      children: [
        AnimatedBuilder(
          animation: _chevY,
          builder: (_, child) => Transform.translate(
            offset: Offset(0, _chevY.value),
            child: child,
          ),
          child: Column(
            children: [
              Icon(Icons.expand_more, color: _kGold.withOpacity(0.4), size: 22),
              Icon(Icons.expand_more, color: _kGold, size: 22),
            ],
          ),
        ),
        const SizedBox(height: 4),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            color: Color.lerp(_kGold, Colors.white, p)!,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          child: Text(
            p > 0.6 ? 'Release to activate!' : 'Drag down to activate offer',
          ),
        ),
      ],
    ),
  );

  // ─────────────────────────────────────────────────────
  //  BOTTOM BAR
  // ─────────────────────────────────────────────────────

  Widget _bottomBar(double entry, double p) => Transform.translate(
    offset: Offset(0, (1 - entry) * 80),
    child: Opacity(
      opacity: entry.clamp(0.0, 1.0),
      child: _WavePillBar(progress: p),
    ),
  );

  // ─────────────────────────────────────────────────────
  //  OVERLAY
  // ─────────────────────────────────────────────────────

  Widget _overlay() {
    return AnimatedBuilder(
      animation: _overlayCtrl,
      builder: (context, _) {
        final bg = _bgFade.value;
        final text = _textFade.value;
        final bScale = _burstScale.value;
        final bFade = _burstFade.value;
        final slide = _cardSlide.value;
        final scale = _cardScale.value;
        final card = _cards[_center];

        return Positioned.fill(
          child: GestureDetector(
            onTap: _closeOverlay,
            child: Container(
              color: Colors.black.withOpacity(0.92 * bg),
              child: SafeArea(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _ConfettiPainter(particles: _particles),
                      ),
                    ),

                    if (bScale > 0)
                      Opacity(
                        opacity: bFade,
                        child: Transform.scale(
                          scale: bScale,
                          child: Container(
                            width: 320,
                            height: 320,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _kGold.withOpacity(0.8),
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _kGold.withOpacity(0.6),
                                  blurRadius: 40,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    Positioned(
                      top: 50,
                      left: 0,
                      right: 0,
                      child: Opacity(
                        opacity: text,
                        child: Column(
                          children: [
                            const _GiftIcon(),
                            const SizedBox(height: 14),
                            _ActivatingText(progress: text),
                          ],
                        ),
                      ),
                    ),

                    Transform.translate(
                      offset: Offset(0, slide),
                      child: Transform.scale(
                        scale: scale,
                        child: Opacity(
                          opacity: (scale * 1.8).clamp(0.0, 1.0),
                          child: _ActivatedCard(card: card),
                        ),
                      ),
                    ),

                    Positioned(
                      top: 14,
                      left: 20,
                      child: Opacity(
                        opacity: bg,
                        child: GestureDetector(
                          onTap: _closeOverlay,
                          child: const Icon(
                            Icons.close,
                            color: Colors.white70,
                            size: 26,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 14,
                      right: 20,
                      child: Opacity(
                        opacity: bg,
                        child: const Text(
                          'T&Cs',
                          style: TextStyle(
                            color: _kGold,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Opacity(
                        opacity: bg,
                        child: Container(
                          height: 3,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                _kGold.withOpacity(0.85),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  PAINTERS
// ─────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────
//  SIDE GLOW PAINTER
//  Soft blurred glow on left, right, and top sides only.
//  Bottom edge stays clean/sharp.
// ─────────────────────────────────────────────────────────────

class _SideGlowPainter extends CustomPainter {
  final double p;
  const _SideGlowPainter(this.p);

  @override
  void paint(Canvas canvas, Size s) {
    final cx = s.width / 2;
    final cy = s.height / 2;
    final blur = 35.0 * p;

    // Left side glow
    canvas.drawRect(
      Rect.fromLTWH(0, cy - _kH / 2 - 30, cx - _kW / 2 + 10, _kH + 60),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [
            _kGold.withOpacity(0.75 * p),
            _kGold.withOpacity(0.0),
          ],
        ).createShader(
          Rect.fromLTWH(0, cy - _kH / 2 - 30, cx - _kW / 2 + 10, _kH + 60),
        )
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur),
    );

    // Right side glow
    final rx = cx + _kW / 2 - 10;
    canvas.drawRect(
      Rect.fromLTWH(rx, cy - _kH / 2 - 30, cx - _kW / 2 + 10, _kH + 60),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            _kGold.withOpacity(0.75 * p),
            _kGold.withOpacity(0.0),
          ],
        ).createShader(
          Rect.fromLTWH(rx, cy - _kH / 2 - 30, cx - _kW / 2 + 10, _kH + 60),
        )
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur),
    );

    // Top glow
    final topH = cy - _kH / 2 + 10;
    if (topH > 0) {
      canvas.drawRect(
        Rect.fromLTWH(cx - _kW / 2 - 30, 0, _kW + 60, topH),
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              _kGold.withOpacity(0.75 * p),
              _kGold.withOpacity(0.0),
            ],
          ).createShader(
            Rect.fromLTWH(cx - _kW / 2 - 30, 0, _kW + 60, topH),
          )
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur),
      );
    }
  }

  @override
  bool shouldRepaint(_SideGlowPainter o) => o.p != p;
}

// ─────────────────────────────────────────────────────────────
//  HOLE MASK PAINTER
// ─────────────────────────────────────────────────────────────

class _HoleMaskPainter extends CustomPainter {
  final double opacity;
  const _HoleMaskPainter({required this.opacity});

  static const _r = Radius.circular(20);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy), width: _kW, height: _kH),
      _r,
    );

    canvas.saveLayer(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.white.withOpacity(opacity),
    );

    canvas.drawRRect(rect, Paint()..color = const Color(0xFF060404));

    canvas.drawRRect(
      rect,
      Paint()
        ..color = _kGold.withOpacity(0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx, cy - _kH * 0.48),
          width: _kW - 8,
          height: 12,
        ),
        const Radius.circular(6),
      ),
      Paint()
        ..color = Colors.black.withOpacity(0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(_HoleMaskPainter o) => o.opacity != opacity;
}

// Confetti
class _ConfettiPainter extends CustomPainter {
  final List<_Particle> particles;
  const _ConfettiPainter({required this.particles});
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height * 0.42;
    for (final p in particles) {
      canvas.save();
      canvas.translate(cx + p.x, cy + p.y);
      canvas.rotate(p.angle);
      final paint = Paint()..color = p.color;
      if (p.circle) {
        canvas.drawCircle(Offset.zero, p.size / 2, paint);
      } else {
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: p.size,
            height: p.size * 0.55,
          ),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_) => true;
}

// Wave-pill bottom bar
class _WavePillBar extends StatelessWidget {
  final double progress;
  const _WavePillBar({required this.progress});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 36,
      child: CustomPaint(painter: _WavePainter(progress)),
    );
  }
}

class _WavePainter extends CustomPainter {
  final double p;
  const _WavePainter(this.p);
  @override
  void paint(Canvas canvas, Size s) {
    final path = _makePath(s);
    final color = Color.lerp(
      Colors.white.withOpacity(0.25),
      _kGold.withOpacity(0.9),
      p,
    )!;
    if (p > 0) {
      canvas.drawPath(
        path,
        Paint()
          ..color = _kGold.withOpacity(0.6 * p)
          ..strokeWidth = 6
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..strokeWidth = 2.8
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  Path _makePath(Size s) {
    final cx = s.width / 2, cy = s.height / 2;
    final dip = 10.0 + p * 6;
    const hw = 50.0, curve = 28.0;
    final end = s.width * 0.5 - 10;
    return Path()
      ..moveTo(cx - end, cy)
      ..lineTo(cx - hw - curve, cy)
      ..cubicTo(
        cx - hw - curve + 20, cy,
        cx - hw - 8, cy + dip,
        cx - hw, cy + dip,
      )
      ..lineTo(cx + hw, cy + dip)
      ..cubicTo(
        cx + hw + 8, cy + dip,
        cx + hw + curve - 20, cy,
        cx + hw + curve, cy,
      )
      ..lineTo(cx + end, cy);
  }

  @override
  bool shouldRepaint(_WavePainter o) => o.p != p;
}

// ─────────────────────────────────────────────────────────────
//  OVERLAY WIDGETS
// ─────────────────────────────────────────────────────────────

class _ActivatingText extends StatelessWidget {
  final double progress;
  const _ActivatingText({required this.progress});
  @override
  Widget build(BuildContext context) => ShaderMask(
    shaderCallback: (b) => LinearGradient(
      colors: const [_kGold, Colors.white, _kGold],
      stops: [
        (progress - 0.3).clamp(0, 1),
        progress.clamp(0, 1),
        (progress + 0.3).clamp(0, 1),
      ],
    ).createShader(b),
    child: const Text(
      'Activating the\noffer for you...',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 1.3,
      ),
    ),
  );
}

class _ActivatedCard extends StatelessWidget {
  final GiftCard card;
  const _ActivatedCard({required this.card});
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 270,
        height: 355,
        color: card.bg,
        child: Stack(
          children: [
            Positioned(
              top: -40,
              right: -40,
              child: _blob(150, Colors.white.withOpacity(0.07)),
            ),
            Positioned(
              bottom: -30,
              left: -30,
              child: _blob(120, Colors.white.withOpacity(0.05)),
            ),
            const Positioned(
              top: 16,
              right: 16,
              child: Text('🎧', style: TextStyle(fontSize: 22)),
            ),
            const Positioned(
              top: 16,
              left: 16,
              child: Text('🛍️', style: TextStyle(fontSize: 18)),
            ),
            const Positioned(
              bottom: 64,
              right: 18,
              child: Text('➡️', style: TextStyle(fontSize: 16)),
            ),
            const Positioned(
              bottom: 72,
              left: 18,
              child: Text('📦', style: TextStyle(fontSize: 20)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.name,
                    style: TextStyle(
                      color: card.textColor.withOpacity(0.75),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    card.line1,
                    style: TextStyle(
                      color: card.textColor,
                      fontSize: 54,
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                    ),
                  ),
                  Text(
                    card.line2,
                    style: TextStyle(
                      color: card.textColor.withOpacity(0.9),
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Use FamPay to shop on ${card.name}',
                    style: TextStyle(
                      color: card.textColor.withOpacity(0.70),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Expires on 27 Jan',
                      style: TextStyle(
                        color: card.textColor.withOpacity(0.8),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
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

  Widget _blob(double s, Color c) => Container(
    width: s,
    height: s,
    decoration: BoxDecoration(shape: BoxShape.circle, color: c),
  );
}

// ─────────────────────────────────────────────────────────────
//  GIFT ICON
// ─────────────────────────────────────────────────────────────

class _GiftIcon extends StatelessWidget {
  const _GiftIcon();
  @override
  Widget build(BuildContext context) => Container(
    width: 56,
    height: 56,
    decoration: BoxDecoration(
      color: const Color(0xFF252018),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: _kGold.withOpacity(0.30), width: 1),
    ),
    child: CustomPaint(painter: _GiftPainter()),
  );
}

class _GiftPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final cx = s.width / 2, cy = s.height / 2;
    void rr(Rect r, double rad, Color c) => canvas.drawRRect(
      RRect.fromRectAndRadius(r, Radius.circular(rad)),
      Paint()..color = c,
    );
    rr(Rect.fromLTWH(cx - 14, cy - 6, 28, 18), 3, const Color(0xFFE8541A));
    rr(Rect.fromLTWH(cx - 15, cy - 12, 30, 8), 3, const Color(0xFFFF6B35));
    final g = Paint()..color = _kGold;
    canvas.drawRect(Rect.fromLTWH(cx - 3, cy - 13, 6, 32), g);
    canvas.drawRect(Rect.fromLTWH(cx - 15, cy - 9, 30, 5), g);
    for (final sign in [-1.0, 1.0]) {
      canvas.drawPath(
        Path()
          ..moveTo(cx, cy - 13)
          ..quadraticBezierTo(cx + sign * 10, cy - 22, cx + sign * 6, cy - 14)
          ..close(),
        g,
      );
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─────────────────────────────────────────────────────────────
//  CARD WIDGET
// ─────────────────────────────────────────────────────────────

class _CardWidget extends StatelessWidget {
  final GiftCard card;
  const _CardWidget({required this.card});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: _kW,
        height: _kH,
        color: card.bg,
        child: Stack(
          children: [
            Positioned(
              top: -30,
              right: -30,
              child: _blob(120, Colors.white.withOpacity(0.07)),
            ),
            Positioned(
              bottom: -20,
              left: -20,
              child: _blob(90, Colors.white.withOpacity(0.05)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _logo(),
                  const SizedBox(height: 14),
                  Text(
                    card.line1,
                    style: TextStyle(
                      color: card.textColor,
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                    ),
                  ),
                  Text(
                    card.line2,
                    style: TextStyle(
                      color: card.textColor.withOpacity(0.9),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                  Text(
                    card.line3,
                    style: TextStyle(
                      color: card.textColor.withOpacity(0.85),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                  ),
                  const Spacer(),
                  _illus(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _blob(double s, Color c) => Container(
    width: s,
    height: s,
    decoration: BoxDecoration(shape: BoxShape.circle, color: c),
  );

  Widget _logo() {
    switch (card.brand) {
      case _Brand.amazon:
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
      case _Brand.flipkart:
        return _row(
          _badge('F', const Color(0xFFFFE500), const Color(0xFF2874F0), 12),
          'flipkart',
        );
      case _Brand.swiggy:
        return _row(
          _badge('S', Colors.white, const Color(0xFFFC8019), 12),
          'swiggy',
        );
      case _Brand.paytm:
        return _row(
          _badge('P', const Color(0xFF002970), Colors.white, 11),
          'Paytm',
        );
      case _Brand.phonepe:
        return _row(
          _badge('Ph', Colors.white, const Color(0xFF5F259F), 8),
          'PhonePe',
        );
    }
  }

  Widget _row(Widget icon, String label) => Row(
    children: [
      icon,
      const SizedBox(width: 6),
      Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );

  Widget _badge(String t, Color bg, Color fg, double fs) => Container(
    width: 22,
    height: 22,
    decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
    child: Center(
      child: Text(
        t,
        style: TextStyle(color: fg, fontSize: fs, fontWeight: FontWeight.w900),
      ),
    ),
  );

  Widget _illus() {
    switch (card.brand) {
      case _Brand.amazon:
        return SizedBox(
          width: double.infinity,
          height: 100,
          child: CustomPaint(painter: _AmazonPainter()),
        );
      case _Brand.flipkart:
        return SizedBox(
          width: double.infinity,
          height: 95,
          child: CustomPaint(painter: _FlipkartPainter()),
        );
      case _Brand.swiggy:
        return SizedBox(
          width: double.infinity,
          height: 95,
          child: CustomPaint(painter: _SwiggyPainter()),
        );
      case _Brand.paytm:
        return SizedBox(
          width: double.infinity,
          height: 95,
          child: CustomPaint(painter: _PaytmPainter()),
        );
      case _Brand.phonepe:
        return SizedBox(
          width: double.infinity,
          height: 95,
          child: CustomPaint(painter: _PhonePePainter()),
        );
    }
  }
}

// ─────────────────────────────────────────────────────────────
//  ILLUSTRATION PAINTERS
// ─────────────────────────────────────────────────────────────

class _SmilePainter extends CustomPainter {
  final Color color;
  const _SmilePainter({required this.color});
  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(
      Path()
        ..moveTo(0, 2)
        ..quadraticBezierTo(s.width / 2, s.height + 2, s.width, 2),
      p,
    );
    canvas.drawLine(Offset(s.width - 4, 0), Offset(s.width, 2), p);
    canvas.drawLine(Offset(s.width - 4, 4), Offset(s.width, 2), p);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _AmazonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final cx = s.width / 2;
    const bw = 80.0, bh = 60.0;
    final bx = cx - bw / 2, by = s.height - bh - 4;
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

class _FlipkartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final cx = s.width / 2;
    const bw = 72.0, bh = 62.0;
    final bx = cx - bw / 2, by = s.height - bh;
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
      math.pi,
      math.pi,
      false,
      hp,
    );
    canvas.drawArc(
      Rect.fromLTWH(cx + 2, by - 16, 20, 20),
      math.pi,
      math.pi,
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

class _SwiggyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final cx = s.width / 2;
    const bw = 70.0, bh = 58.0;
    final bx = cx - bw / 2, by = s.height - bh;
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
      math.pi,
      math.pi,
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
  void paint(Canvas canvas, Size s) {
    final cx = s.width / 2;
    const bw = 72.0, bh = 55.0;
    final bx = cx - bw / 2, by = s.height - bh;
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
  void paint(Canvas canvas, Size s) {
    final cx = s.width / 2;
    const r = 32.0;
    final cy = s.height - r - 4;
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
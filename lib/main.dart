import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';

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
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0D0B1E),
            Color(0xFF1A1040),
            Color(0xFF2D1B69),
            Color(0xFF1A2744),
            Color(0xFF0F1E2E),
          ],
          stops: [0.0, 0.25, 0.5, 0.75, 1.0],
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
const _kPurple = Color(0xFF9B59FF);

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

// ─────────────────────────────────────────────────────────────
//  CANNON CONFETTI
//  Each particle fires from the left OR right edge of the screen,
//  shoots inward at a randomised upward angle (like a party cannon),
//  gravity pulls it down, and it recycles when it exits the bottom.
// ─────────────────────────────────────────────────────────────

enum _Side { left, right }

class _Particle {
  double x, y, vx, vy, angle, spin, size;
  Color color;
  bool circle;
  double screenW, screenH;
  _Side side;

  _Particle(math.Random r, {this.screenW = 400, this.screenH = 800})
    : x = 0,
      y = 0,
      vx = 0,
      vy = 0,
      angle = r.nextDouble() * math.pi * 2,
      spin = (r.nextDouble() - 0.5) * 0.32,
      size = r.nextDouble() * 11 + 5,
      color = _confettiColors[r.nextInt(_confettiColors.length)],
      circle = r.nextBool(),
      side = r.nextBool() ? _Side.left : _Side.right {
    _reset(r);
  }

  void _reset(math.Random r) {
    side = r.nextBool() ? _Side.left : _Side.right;
    // Cannon mouth: fixed at the edge, at a random height in the upper 65%
    // Stagger y so bursts don't all appear at once
    y = r.nextDouble() * screenH * 0.65;
    x = side == _Side.left ? -screenW / 2 : screenW / 2;

    // Fire angle: shoot inward + upward
    // Left cannon fires right (positive vx), right cannon fires left (negative vx)
    final inwardAngle = side == _Side.left
        ? -math.pi *
              (0.08 + r.nextDouble() * 0.30) // -15° to -69° from horizontal
        : math.pi + math.pi * (0.08 + r.nextDouble() * 0.30);
    final speed = 8.0 + r.nextDouble() * 12.0;
    vx = math.cos(inwardAngle) * speed;
    vy = math.sin(inwardAngle) * speed;

    color = _confettiColors[r.nextInt(_confettiColors.length)];
    size = r.nextDouble() * 11 + 5;
    circle = r.nextBool();
  }

  void tick() {
    x += vx;
    y += vy;
    vy += 0.28; // gravity — pulls particles downward
    vx *= 0.992; // gentle air drag
    angle += spin;

    // Recycle when particle exits bottom or goes way off side
    if (y > screenH + 30 || x.abs() > screenW) {
      _reset(math.Random());
    }
  }

  bool get dead => false; // recycled, never permanently dead
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
  // ── carousel ──────────────────────────────────────────
  double _page = 2.0;
  bool _hDrag = false;
  late final AnimationController _snapCtrl;
  late Animation<double> _snapAnim;

  // ── ATM insert animation ───────────────────────────────
  // _insertCtrl: 0→1 drives the card sliding into the slot
  //   0.0 = card at rest in carousel
  //   0.0→0.6 = card moves right + shrinks toward slot mouth
  //   0.6→1.0 = card fully inside (invisible), slot reads "ACCEPTED"
  late final AnimationController _insertCtrl;
  bool _isInserting = false; // true while long-press held or animating

  // ── overlay / burst ────────────────────────────────────
  bool _showOverlay = false;
  late final AnimationController _overlayCtrl;
  late final Animation<double> _bgFade,
      _textFade,
      _cardSlide,
      _cardScale,
      _burstScale,
      _burstFade;

  final _rng = math.Random();
  final List<_Particle> _particles = [];

  // ── pulse for slot scan beam ───────────────────────────
  late final AnimationController _pulseCtrl;

  // ── card eject controllers ─────────────────────────────
  // Phase 0.00→0.12  scaleY snaps 0.04→1.0 (pops out of slot gap)
  // Phase 0.12→0.65  flies upward with easeOutBack overshoot
  // Phase 0.65→1.00  settled, bob controller takes over
  late final AnimationController _ejectCtrl;
  late final AnimationController _bobCtrl;
  late final Animation<double> _bobAnim;

  // ── dedicated 60fps ticker for confetti ──────────────
  late final Ticker _confettiTicker;

  int get _center => _page.round().clamp(0, _cards.length - 1);

  // _prog feeds the CoinSlotPainter — driven by _insertCtrl
  double get _prog => _insertCtrl.value;

  @override
  void initState() {
    super.initState();

    // carousel snap
    _snapCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _snapAnim = Tween<double>(begin: _page, end: _page).animate(_snapCtrl);
    _snapCtrl.addListener(() => setState(() => _page = _snapAnim.value));

    // ATM insert — card drops into slot over 700 ms
    _insertCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _insertCtrl.addListener(() => setState(() {}));

    // overlay burst (bg fade + burst ring) — short 800ms
    _overlayCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _bgFade = _iv(0.00, 0.50, Curves.easeOut);
    _textFade = _iv(0.20, 0.70, Curves.easeOut);
    _burstScale = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _overlayCtrl,
        curve: const Interval(0.00, 0.45, curve: Curves.easeOutBack),
      ),
    );
    _burstFade = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _overlayCtrl,
        curve: const Interval(0.35, 0.65, curve: Curves.easeIn),
      ),
    );
    // unused but kept for type safety
    _cardSlide = Tween<double>(begin: 0, end: 0).animate(_overlayCtrl);
    _cardScale = Tween<double>(begin: 1, end: 1).animate(_overlayCtrl);
    // Remove old particle tick from overlayCtrl — it stops after 800ms
    // Instead use a dedicated Ticker that runs at 60fps while overlay is shown
    _confettiTicker = createTicker((_) {
      if (_showOverlay && _particles.isNotEmpty) {
        setState(() {
          for (final p in _particles) p.tick();
        });
      }
    });

    // eject — card pops from slot and flies up — 900 ms
    _ejectCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _ejectCtrl.addListener(() => setState(() {}));

    // bob — gentle float after card settles
    _bobCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _bobAnim = Tween<double>(
      begin: -5.0,
      end: 5.0,
    ).animate(CurvedAnimation(parent: _bobCtrl, curve: Curves.easeInOut));
    _bobCtrl.addListener(() => setState(() {}));

    // slot scan pulse
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulseCtrl.addListener(() => setState(() {}));
  }

  Animation<double> _iv(double t0, double t1, Curve c) =>
      Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _overlayCtrl,
          curve: Interval(t0, t1, curve: c),
        ),
      );

  @override
  void dispose() {
    _snapCtrl.dispose();
    _insertCtrl.dispose();
    _overlayCtrl.dispose();
    _ejectCtrl.dispose();
    _bobCtrl.dispose();
    _pulseCtrl.dispose();
    _confettiTicker.dispose();
    super.dispose();
  }

  // ── Carousel swipe ─────────────────────────────────────
  void _onHStart(DragStartDetails d) {
    _snapCtrl.stop();
    _hDrag = true;
  }

  void _onHUpdate(DragUpdateDetails d) {
    if (!_hDrag) return;
    setState(
      () => _page = (_page - d.delta.dx / _kGap)
          .clamp(0.0, _cards.length - 1.0)
          .toDouble(),
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
      end: i.toDouble().clamp(0.0, _cards.length - 1.0).toDouble(),
    ).animate(CurvedAnimation(parent: _snapCtrl, curve: Curves.easeOutCubic));
    _snapCtrl.forward(from: 0);
  }

  // ── Long press = ATM insert ────────────────────────────
  void _onLongPress() async {
    if (_isInserting) return;
    _isInserting = true;
    HapticFeedback.mediumImpact();

    // Make sure selected card is snapped to center first
    _snapTo(_center);
    await Future.delayed(const Duration(milliseconds: 200));

    // Animate insert 0 → 1
    await _insertCtrl.animateTo(1.0, curve: Curves.easeInCubic);

    // Brief pause at "ACCEPTED" moment
    HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 320));

    // Fire overlay burst + card eject sequence
    // Spawn cannon confetti — fires from both sides
    // Use 160 particles: 80 from left, 80 from right
    if (!mounted) return;
    final sz = MediaQuery.of(context).size;
    for (int i = 0; i < 160; i++) {
      final p = _Particle(_rng, screenW: sz.width, screenH: sz.height);
      // Force alternating sides so both cannons are equally loaded
      if (i < 80) {
        p.side = _Side.left;
        p.x = -sz.width / 2;
        // stagger y positions so they don't all fire at the same height
        p.y = (i / 80.0) * sz.height * 0.70;
        final angle = -math.pi * (0.08 + _rng.nextDouble() * 0.30);
        final speed = 8.0 + _rng.nextDouble() * 12.0;
        p.vx = math.cos(angle) * speed;
        p.vy = math.sin(angle) * speed;
      } else {
        p.side = _Side.right;
        p.x = sz.width / 2;
        p.y = ((i - 80) / 80.0) * sz.height * 0.70;
        final angle = math.pi + math.pi * (0.08 + _rng.nextDouble() * 0.30);
        final speed = 8.0 + _rng.nextDouble() * 12.0;
        p.vx = math.cos(angle) * speed;
        p.vy = math.sin(angle) * speed;
      }
      _particles.add(p);
    }
    setState(() => _showOverlay = true);
    _overlayCtrl.forward(from: 0);
    _ejectCtrl.forward(from: 0);
    _confettiTicker.start(); // start 60fps confetti loop
  }

  void _closeOverlay() {
    _confettiTicker.stop();
    setState(() {
      _showOverlay = false;
      _particles.clear();
      _isInserting = false;
    });
    _overlayCtrl.reset();
    _ejectCtrl.reset();
    _insertCtrl.reset();
  }

  // _tickParticles removed — confetti is driven by _confettiTicker (60fps Ticker)

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final p = _prog; // 0..1 insert progress

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // ambient bg glow
          Positioned(
            top: sh * 0.2,
            left: sw / 2 - 160,
            child: IgnorePointer(
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [_kPurple.withOpacity(0.10), Colors.transparent],
                  ),
                ),
              ),
            ),
          ),

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

                // ── COIN SLOT PANEL ──────────────────────────
                SizedBox(
                  height: sh * 0.32,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: _CoinSlotPainter(
                      progress: p,
                      pulse: _pulseCtrl.value,
                      cardWidth: _kW,
                      cardColor: _cards[_center].bg,
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
  }

  // ─────────────────────────────────────────────────────
  Widget _topBar() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    child: Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.maybePop(context),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.08),
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.chevron_left,
              color: Colors.white70,
              size: 22,
            ),
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: _kGold.withOpacity(0.12),
            border: Border.all(color: _kGold.withOpacity(0.30), width: 1),
          ),
          child: const Text(
            'T&Cs',
            style: TextStyle(
              color: _kGold,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _title(double p) {
    final inserting = p > 0.05;
    final accepted = p > 0.85;
    final text = accepted
        ? 'Offer activated!'
        : inserting
        ? 'Inserting card...'
        : 'Choose your\nwelcome gift';
    final color = accepted
        ? const Color(0xFF44FF88)
        : inserting
        ? _kGold
        : Colors.white;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: Text(
        text,
        key: ValueKey(text),
        textAlign: TextAlign.center,
        style: TextStyle(
          color: color,
          fontSize: 26,
          fontWeight: FontWeight.w700,
          height: 1.25,
          shadows: [Shadow(color: color.withOpacity(0.5), blurRadius: 14)],
        ),
      ),
    );
  }

  Widget _carousel(double p) => GestureDetector(
    onHorizontalDragStart: _isInserting ? null : _onHStart,
    onHorizontalDragUpdate: _isInserting ? null : _onHUpdate,
    onHorizontalDragEnd: _isInserting ? null : _onHEnd,
    behavior: HitTestBehavior.opaque,
    child: Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.hardEdge,
      children: [
        const SizedBox.shrink(),
        _holeBack(p),
        _borderRing(p),
        ..._sideCards(),
        _centerCard(p),
        _holeMask(p),
      ],
    ),
  );

  Widget _holeBack(double p) {
    if (p == 0) return const SizedBox.shrink();
    final opacity = (p * 1.8).clamp(0.0, 1.0).toDouble();
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

  Widget _borderRing(double p) {
    // Border glows at idle, fades as card inserts
    final op = (0.40 - p * 0.40).clamp(0.0, 1.0).toDouble();
    return IgnorePointer(
      child: Container(
        width: _kW + 6,
        height: _kH + 6,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(23),
          border: Border.all(color: _kGold.withOpacity(op), width: 2.5),
        ),
      ),
    );
  }

  // ATM vertical insert animation:
  //   p=0.00→0.45  card floats down toward the slot (moves downward)
  //   p=0.45→0.72  card aligns over slot, scaleY starts collapsing
  //   p=0.72→0.90  card flattens edge-on — scaleY → 0 (going through the gap)
  //   p=0.90→1.00  fully inside, fades out
  Widget _centerCard(double p) {
    final slot = _center - _page;
    final screenH = MediaQuery.of(context).size.height;

    double insertDy, scaleX, scaleY, opacity;

    if (p <= 0.45) {
      // floating downward toward slot
      final t = p / 0.45;
      final ease = 1 - math.pow(1 - t, 3).toDouble();
      insertDy = ease * (screenH * 0.18); // moves down toward slot area
      scaleX = 1.0;
      scaleY = 1.0;
      opacity = 1.0;
    } else if (p <= 0.72) {
      // aligning — nearly at slot top, begins to narrow
      final t = (p - 0.45) / 0.27;
      final ease = t * t * t;
      insertDy = (screenH * 0.18) + ease * (screenH * 0.04);
      scaleX = 1.0;
      scaleY = 1.0 - ease * 0.35; // slight squish preview
      opacity = 1.0;
    } else if (p <= 0.90) {
      // ENTERING SLOT — scaleY collapses to near zero (card going in edge-first)
      final t = (p - 0.72) / 0.18;
      final ease = t * t * t;
      insertDy = (screenH * 0.22) + ease * (screenH * 0.03);
      scaleX = 1.0;
      scaleY = (0.65 - ease * 0.65).clamp(0.0, 1.0).toDouble(); // 0.65 → 0
      opacity = 1.0;
    } else {
      // fully inside — fade out
      final t = (p - 0.90) / 0.10;
      insertDy = screenH * 0.25;
      scaleX = 1.0;
      scaleY = 0.0;
      opacity = (1.0 - t).clamp(0.0, 1.0).toDouble();
    }

    // Gold glow ring appears around card as it approaches slot
    final glowOpacity = p > 0.3
        ? ((p - 0.3) / 0.5).clamp(0.0, 0.6).toDouble()
        : 0.0;

    return Transform.translate(
      offset: Offset(slot * _kGap, insertDy),
      child: Transform.scale(
        scaleX: scaleX,
        scaleY: scaleY.clamp(0.0, 1.0).toDouble(),
        child: Opacity(
          opacity: opacity,
          child: GestureDetector(
            onTap: _isInserting ? null : () => _snapTo(_center),
            onLongPress: _isInserting ? null : _onLongPress,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // gold glow halo when near slot
                if (glowOpacity > 0)
                  Container(
                    width: _kW + 20,
                    height: _kH + 20,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: _kGold.withOpacity(glowOpacity),
                          blurRadius: 24,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                  ),
                _CardWidget(card: _cards[_center]),
                // "hold to insert" hint
                if (!_isInserting)
                  Positioned(
                    bottom: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _kGold.withOpacity(0.35),
                          width: 0.8,
                        ),
                      ),
                      child: const Text(
                        'Hold to insert',
                        style: TextStyle(
                          color: _kGold,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
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
  }

  Widget _holeMask(double p) {
    final op = (p * 2.0).clamp(0.0, 1.0).toDouble();
    if (op <= 0) return const SizedBox.shrink();
    return IgnorePointer(
      child: CustomPaint(painter: _HoleMaskPainter(opacity: op)),
    );
  }

  List<Widget> _sideCards() {
    return [
      for (int i = 0; i < _cards.length; i++)
        if (i != _center && (i - _page).abs() <= 1.8)
          Transform.translate(
            offset: Offset((i - _page) * _kGap, (i - _page).abs() * 18),
            child: Transform.rotate(
              angle: (i - _page) * 0.22,
              child: Transform.scale(
                scale: (1.0 - (i - _page).abs() * 0.08)
                    .clamp(0.84, 1.0)
                    .toDouble(),
                child: GestureDetector(
                  onTap: () => _snapTo(i),
                  child: _CardWidget(card: _cards[i]),
                ),
              ),
            ),
          ),
    ];
  }

  Widget _overlay() {
    // Listen to both overlayCtrl (bg/burst) and ejectCtrl (card physics)
    return AnimatedBuilder(
      animation: Listenable.merge([_overlayCtrl, _ejectCtrl, _bobCtrl]),
      builder: (context, _) {
        final bg = _bgFade.value;
        final text = _textFade.value;
        final bScale = _burstScale.value;
        final bFade = _burstFade.value;
        final card = _cards[_center];
        final sh = MediaQuery.of(context).size.height;
        final sw = MediaQuery.of(context).size.width;

        // ── Slot screen-space position ─────────────────────
        // Slot panel = bottom sh*0.32 of screen → slot housing center at ~sh*0.73
        final slotScreenCY = sh * 0.74;
        // Card rests lower so the title text above has breathing room
        // Layout: title zone = top 0→0.30, card zone = 0.38→0.78, slot = 0.74+
        final cardRestY =
            sh * 0.53; // lower center — card sits in middle-lower area

        // ── Eject physics (driven by _ejectCtrl 0→1) ──────
        final e = _ejectCtrl.value;

        double cardY, scaleY, cardOpacity, cardRot;

        if (e <= 0.12) {
          // ── Phase 1: SNAP OPEN from slot gap ──────────────
          // scaleY pops from near-zero to full height rapidly
          final t = (e / 0.12).clamp(0.0, 1.0);
          final ease = 1.0 - math.pow(1.0 - t, 2).toDouble();
          cardY = slotScreenCY; // starts at slot level
          scaleY = 0.04 + ease * 0.96; // 0.04 → 1.0
          cardOpacity = 1.0;
          cardRot = 0.0;
        } else if (e <= 0.65) {
          // ── Phase 2: FLY UP with easeOutBack overshoot ────
          final t = ((e - 0.12) / 0.53).clamp(0.0, 1.0);
          // easeOutBack: overshoots target then settles
          const c1 = 1.70158, c3 = c1 + 1.0;
          final ease =
              1.0 + c3 * math.pow(t - 1.0, 3) + c1 * math.pow(t - 1.0, 2);
          cardY = slotScreenCY + (cardRestY - slotScreenCY) * ease;
          scaleY = 1.0;
          cardOpacity = 1.0;
          // slight tilt at peak of flight
          cardRot = math.sin(t * math.pi) * 0.05;
        } else {
          // ── Phase 3: FLOAT gently with bob ────────────────
          cardY = cardRestY + _bobAnim.value;
          scaleY = 1.0;
          cardOpacity = 1.0;
          cardRot = 0.0;
        }

        // Translate from absolute screen Y to offset from screen center
        final centerY = sh / 2.0;
        final offsetY = cardY - centerY;

        // Card glow — strong when first ejected, fades after settle
        final glowAlpha = e < 0.65
            ? (e / 0.65).clamp(0.0, 0.7).toDouble()
            : (1.0 - (e - 0.65) / 0.35).clamp(0.0, 0.5).toDouble();

        // "ACTIVE" stamp opacity — appears after card settles
        final stampAlpha = e > 0.60
            ? ((e - 0.60) / 0.25).clamp(0.0, 1.0).toDouble()
            : 0.0;

        return Positioned.fill(
          child: GestureDetector(
            onTap: _closeOverlay,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF0D0B1E).withOpacity(0.96 * bg),
                    const Color(0xFF2D1B69).withOpacity(0.94 * bg),
                  ],
                ),
              ),
              child: SafeArea(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // ── LAYER 1: Full-screen confetti rain ────
                    Positioned.fill(
                      child: IgnorePointer(
                        child: CustomPaint(
                          painter: _ConfettiPainter(particles: _particles),
                        ),
                      ),
                    ),

                    // ── LAYER 2: Burst ring at slot mouth ─────
                    if (bScale > 0)
                      Positioned(
                        top: sh * 0.60,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Opacity(
                            opacity: bFade,
                            child: Transform.scale(
                              scale: bScale,
                              child: Container(
                                width: 260,
                                height: 260,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: _kGold.withOpacity(0.85),
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _kGold.withOpacity(0.55),
                                      blurRadius: 60,
                                      spreadRadius: 16,
                                    ),
                                    BoxShadow(
                                      color: _kPurple.withOpacity(0.35),
                                      blurRadius: 80,
                                      spreadRadius: 22,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                    // ── LAYER 3: Light rays from slot ─────────
                    if (e > 0 && e < 0.45)
                      Positioned(
                        top: sh * 0.68,
                        left: 0,
                        right: 0,
                        child: IgnorePointer(
                          child: CustomPaint(
                            painter: _SlotRaysPainter(
                              progress: (e / 0.45).clamp(0.0, 1.0),
                              screenWidth: sw,
                            ),
                          ),
                        ),
                      ),

                    // ── LAYER 4: TITLE ZONE — top of screen ───
                    // Pinned to top, fades in with bg
                    // Zone: 0 → sh*0.28  (gift icon + "Offer activated!")
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Opacity(
                        opacity: bg,
                        child: SafeArea(
                          bottom: false,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 56),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const _GiftIcon(),
                                const SizedBox(height: 12),
                                // Shimmer title "Offer activated!"
                                ShaderMask(
                                  shaderCallback: (b) => const LinearGradient(
                                    colors: [_kGold, Colors.white, _kGold],
                                  ).createShader(b),
                                  child: const Text(
                                    'Offer activated!',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Opacity(
                                  opacity: text,
                                  child: Text(
                                    'Your welcome gift is ready to use',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.65),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // ── LAYER 5: EJECTED CARD ─────────────────
                    // Absolutely positioned by eject physics
                    // Zone: card rests at sh*0.53 (center-lower area)
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.center,
                        child: Transform.translate(
                          offset: Offset(0, offsetY),
                          child: Transform.scale(
                            scaleX: 1.0,
                            scaleY: scaleY,
                            child: Transform.rotate(
                              angle: cardRot,
                              child: Opacity(
                                opacity: cardOpacity,
                                child: _EjectedCard(
                                  card: card,
                                  glowAlpha: glowAlpha,
                                  stampAlpha: stampAlpha,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // ── Close button ──────────────────────────
                    Positioned(
                      top: 14,
                      left: 20,
                      child: Opacity(
                        opacity: bg,
                        child: GestureDetector(
                          onTap: _closeOverlay,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.08),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.15),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white70,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // ── T&Cs ──────────────────────────────────
                    Positioned(
                      top: 18,
                      right: 20,
                      child: Opacity(
                        opacity: bg,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: _kGold.withOpacity(0.12),
                            border: Border.all(
                              color: _kGold.withOpacity(0.30),
                              width: 1,
                            ),
                          ),
                          child: const Text(
                            'T&Cs',
                            style: TextStyle(
                              color: _kGold,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // ── Gold bottom line ──────────────────────
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
//  SLOT RAYS PAINTER
//  Light rays that shoot upward from the slot mouth during eject
// ─────────────────────────────────────────────────────────────

class _SlotRaysPainter extends CustomPainter {
  final double progress; // 0→1
  final double screenWidth;
  const _SlotRaysPainter({required this.progress, required this.screenWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = screenWidth / 2;
    final p = progress;
    const numRays = 8;
    for (int i = 0; i < numRays; i++) {
      final angle = -math.pi / 2 + (i - (numRays - 1) / 2.0) * 0.22;
      final len = 30.0 + p * 100.0;
      final alpha = p * 0.55 * (0.5 + 0.5 * math.sin(i * 1.3));
      final x2 = cx + math.cos(angle) * len;
      final y2 = math.sin(angle) * len;
      canvas.drawLine(
        Offset(cx, 0),
        Offset(x2, y2.abs()),
        Paint()
          ..color = _kGold.withOpacity(alpha)
          ..strokeWidth = 0.8 + p * 1.4
          ..strokeCap = StrokeCap.round,
      );
    }
    // horizontal spread glow at origin
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, 0), width: 160 * p, height: 14 * p),
      Paint()
        ..color = _kGold.withOpacity(p * 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
  }

  @override
  bool shouldRepaint(_SlotRaysPainter o) =>
      o.progress != progress || o.screenWidth != screenWidth;
}

// ─────────────────────────────────────────────────────────────
//  EJECTED CARD WIDGET
//  The full activated card that pops out of the slot.
//  Includes gold glow halo and "ACTIVE" green stamp.
// ─────────────────────────────────────────────────────────────

class _EjectedCard extends StatelessWidget {
  final GiftCard card;
  final double glowAlpha;
  final double stampAlpha;

  const _EjectedCard({
    required this.card,
    required this.glowAlpha,
    required this.stampAlpha,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // gold glow halo behind card
        if (glowAlpha > 0)
          Container(
            width: 258,
            height: 336,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: _kGold.withOpacity(glowAlpha * 0.55),
                  blurRadius: 40,
                  spreadRadius: 8,
                ),
                BoxShadow(
                  color: _kPurple.withOpacity(glowAlpha * 0.30),
                  blurRadius: 60,
                  spreadRadius: 12,
                ),
              ],
            ),
          ),

        // card body
        ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Container(
            width: 240,
            height: 318,
            color: card.bg,
            child: Stack(
              children: [
                // decorative blobs
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

                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 48, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // brand name
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
                      // cashback amount
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
                          color: Colors.black.withOpacity(0.20),
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

                // ── ACTIVE STAMP — fades in after card settles ──
                if (stampAlpha > 0)
                  Positioned(
                    top: 14,
                    right: 14,
                    child: Opacity(
                      opacity: stampAlpha,
                      child: Transform.rotate(
                        angle: -0.25,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF44FF88).withOpacity(0.18),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: const Color(0xFF44FF88).withOpacity(0.85),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF44FF88).withOpacity(0.3),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Text(
                            'ACTIVE',
                            style: TextStyle(
                              color: Color(0xFF44FF88),
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _blob(double s, Color c) => Container(
    width: s,
    height: s,
    decoration: BoxDecoration(shape: BoxShape.circle, color: c),
  );
}

// ─────────────────────────────────────────────────────────────
//  ★ COIN SLOT PAINTER ★
//
//  Slot machine / ATM card-insert vibe.
//  Layers (back → front):
//   1. Dark recessed slot throat (deep interior behind the slot)
//   2. Scan-line pulse (moving light inside slot)
//   3. Dot indicators (5 dots along slot mouth, light up on drag)
//   4. Card color glow bleed (slot tints with inserted card's color)
//   5. Slot housing — bevelled metal frame with 3D top/bottom faces
//   6. Slot mouth — thin horizontal gap, inner shadow for depth
//   7. Gold rim + glow intensifies with drag progress
//   8. Side panel screws (machine detail)
//   9. Background surface gradient (app bg)
//  10. Readout display — "INSERT CARD" → progress bar → "ACCEPTED"
// ─────────────────────────────────────────────────────────────

class _CoinSlotPainter extends CustomPainter {
  final double progress; // 0..1 from drag
  final double pulse; // 0..1 slow sine from AnimationController
  final double cardWidth;
  final Color cardColor; // current card's bg color

  const _CoinSlotPainter({
    required this.progress,
    required this.pulse,
    required this.cardWidth,
    required this.cardColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final p = progress;
    final pulseMod = 0.5 + 0.5 * pulse;

    // ── Slot dimensions ───────────────────────────────────
    // The slot housing is a wide rectangular unit, centered
    const housingW = 260.0; // full machine housing width
    const housingH = 72.0; // total housing height
    const housingBR = 14.0; // housing border radius
    const slotW = 200.0; // actual card-insert opening width
    const slotH = 10.0; // slot gap height (thin like a real ATM)
    const slotBR = 4.0; // slight rounding on slot corners
    final hx = cx - housingW / 2; // housing left x
    final hy = 18.0; // housing top y (gives room for glow above)
    final slotX = cx - slotW / 2;
    final slotY =
        hy + (housingH - slotH) / 2; // slot vertically centered in housing

    // ─────────────────────────────────────────────────────
    // 1. DEEP SLOT THROAT — recessed darkness behind opening
    // ─────────────────────────────────────────────────────
    final throatPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(slotX - 2, slotY - 1, slotW + 4, slotH + 2),
          const Radius.circular(slotBR),
        ),
      );
    canvas.drawPath(throatPath, Paint()..color = const Color(0xFF010108));
    // inner top shadow — depth illusion
    canvas.drawRect(
      Rect.fromLTWH(slotX, slotY, slotW, slotH * 0.4),
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(0, slotY),
          Offset(0, slotY + slotH * 0.4),
          [Colors.black.withOpacity(0.80), Colors.transparent],
          [0.0, 1.0],
        ),
    );
    // inner bottom highlight — thin bright line at floor of slot
    canvas.drawRect(
      Rect.fromLTWH(slotX + 4, slotY + slotH - 2, slotW - 8, 1.5),
      Paint()..color = Colors.white.withOpacity(0.08),
    );

    // ─────────────────────────────────────────────────────
    // 2. SCAN-LINE PULSE — moving horizontal beam inside slot
    //    Runs left→right continuously, speeds up with drag
    // ─────────────────────────────────────────────────────
    if (p > 0) {
      final scanSpeed = 0.4 + p * 0.5;
      final scanX = slotX + ((pulse * scanSpeed * slotW * 3) % slotW);
      final scanAlpha = (p * 0.85 * pulseMod).clamp(0.0, 1.0);
      // beam
      canvas.drawRect(
        Rect.fromLTWH(scanX - 18, slotY + 1, 36, slotH - 2),
        Paint()
          ..shader = ui.Gradient.linear(
            Offset(scanX - 18, 0),
            Offset(scanX + 18, 0),
            [
              Colors.transparent,
              _kGold.withOpacity(scanAlpha * 0.9),
              Colors.white.withOpacity(scanAlpha),
              _kGold.withOpacity(scanAlpha * 0.9),
              Colors.transparent,
            ],
            [0.0, 0.3, 0.5, 0.7, 1.0],
          ),
      );
      // scan glow blur layer
      canvas.drawRect(
        Rect.fromLTWH(scanX - 30, slotY - 2, 60, slotH + 4),
        Paint()
          ..color = _kGold.withOpacity(scanAlpha * 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
    }

    // ─────────────────────────────────────────────────────
    // 3. DOT INDICATORS — 5 dots below slot, light up L→R with progress
    // ─────────────────────────────────────────────────────
    const dotCount = 5;
    const dotR = 3.5;
    const dotGap = 18.0;
    final dotStartX = cx - (dotCount - 1) * dotGap / 2;
    final dotY = slotY + slotH + 14.0;
    for (int i = 0; i < dotCount; i++) {
      final dx = dotStartX + i * dotGap;
      final lit = p * dotCount > i; // lights up sequentially
      final litFrac = (p * dotCount - i).clamp(0.0, 1.0).toDouble();

      // outer ring
      canvas.drawCircle(
        Offset(dx, dotY),
        dotR + 1,
        Paint()
          ..color = _kGold.withOpacity(0.12 + litFrac * 0.25)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8,
      );
      // filled dot
      canvas.drawCircle(
        Offset(dx, dotY),
        dotR,
        Paint()
          ..color = lit
              ? _kGold.withOpacity(0.5 + litFrac * 0.5)
              : const Color(0xFF1A1540),
      );
      // glow on lit dots
      if (lit && litFrac > 0.3) {
        canvas.drawCircle(
          Offset(dx, dotY),
          dotR + 3,
          Paint()
            ..color = _kGold.withOpacity(litFrac * 0.35)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
        );
      }
    }

    // ─────────────────────────────────────────────────────
    // 4. CARD COLOR BLEED — slot glows with card's color
    // ─────────────────────────────────────────────────────
    if (p > 0.1) {
      final bleedAlpha = ((p - 0.1) / 0.9 * 0.30).clamp(0.0, 0.30).toDouble();
      canvas.drawRect(
        Rect.fromLTWH(slotX, slotY, slotW, slotH),
        Paint()..color = cardColor.withOpacity(bleedAlpha),
      );
      // color bleeds outward above/below slot
      canvas.drawRect(
        Rect.fromLTWH(slotX + 10, slotY - 8, slotW - 20, 10),
        Paint()
          ..shader = ui.Gradient.linear(
            Offset(0, slotY - 8),
            Offset(0, slotY),
            [Colors.transparent, cardColor.withOpacity(bleedAlpha * 0.5)],
            [0.0, 1.0],
          ),
      );
    }

    // ─────────────────────────────────────────────────────
    // 5. SLOT HOUSING — bevelled metal body
    //    Three faces: top bevel, bottom bevel, front face
    // ─────────────────────────────────────────────────────

    // Front face (main housing body)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(hx, hy, housingW, housingH),
        const Radius.circular(housingBR),
      ),
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(cx, hy),
          Offset(cx, hy + housingH),
          [
            const Color(0xFF1C1845),
            const Color(0xFF151230),
            const Color(0xFF0E0C22),
          ],
          [0.0, 0.5, 1.0],
        ),
    );

    // Top bevel face — lit edge (3D top surface)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(hx + 2, hy + 2, housingW - 4, 10),
        const Radius.circular(housingBR - 2),
      ),
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(0, hy + 2),
          Offset(0, hy + 12),
          [Colors.white.withOpacity(0.12), Colors.transparent],
          [0.0, 1.0],
        ),
    );

    // Bottom bevel — shadow face
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(hx + 2, hy + housingH - 10, housingW - 4, 10),
        const Radius.circular(housingBR - 2),
      ),
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(0, hy + housingH - 10),
          Offset(0, hy + housingH),
          [Colors.transparent, Colors.black.withOpacity(0.40)],
          [0.0, 1.0],
        ),
    );

    // Left edge shadow (side face)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(hx, hy, 18, housingH),
        const Radius.circular(housingBR),
      ),
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(hx, 0),
          Offset(hx + 18, 0),
          [Colors.black.withOpacity(0.35), Colors.transparent],
          [0.0, 1.0],
        ),
    );

    // Right edge shadow (side face)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(hx + housingW - 18, hy, 18, housingH),
        const Radius.circular(housingBR),
      ),
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(hx + housingW - 18, 0),
          Offset(hx + housingW, 0),
          [Colors.transparent, Colors.black.withOpacity(0.35)],
          [0.0, 1.0],
        ),
    );

    // ─────────────────────────────────────────────────────
    // 6. SLOT MOUTH — the actual card-insert gap
    //    Punched through the housing face
    // ─────────────────────────────────────────────────────

    // Outer slot cutout (slightly larger, darker border)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(slotX - 3, slotY - 3, slotW + 6, slotH + 6),
        const Radius.circular(slotBR + 2),
      ),
      Paint()..color = const Color(0xFF07051A),
    );

    // Inner slot void
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(slotX, slotY, slotW, slotH),
        const Radius.circular(slotBR),
      ),
      Paint()..color = const Color(0xFF010108),
    );

    // Slot top inner-edge shadow
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(slotX, slotY, slotW, slotH * 0.45),
        const Radius.circular(slotBR),
      ),
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(0, slotY),
          Offset(0, slotY + slotH * 0.45),
          [Colors.black.withOpacity(0.70), Colors.transparent],
          [0.0, 1.0],
        ),
    );

    // ─────────────────────────────────────────────────────
    // 7. GOLD RIM + GLOW — housing border brightens with drag
    // ─────────────────────────────────────────────────────
    final rimAlpha = 0.35 + p * 0.60;
    final rimBlur = p * 18.0;

    // Outer glow
    if (p > 0) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(hx - 1, hy - 1, housingW + 2, housingH + 2),
          const Radius.circular(housingBR + 1),
        ),
        Paint()
          ..color = _kGold.withOpacity(p * 0.55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3 + p * 3
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, rimBlur),
      );
    }

    // Crisp housing border
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(hx, hy, housingW, housingH),
        const Radius.circular(housingBR),
      ),
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(hx, hy),
          Offset(hx + housingW, hy + housingH),
          [
            _kGold.withOpacity(rimAlpha),
            Colors.white.withOpacity(rimAlpha * 0.6),
            _kGold.withOpacity(rimAlpha * 0.8),
            _kGold.withOpacity(rimAlpha),
          ],
          [0.0, 0.35, 0.65, 1.0],
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5 + p * 0.8,
    );

    // Slot mouth rim — tight gold line around the opening
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(slotX - 1, slotY - 1, slotW + 2, slotH + 2),
        const Radius.circular(slotBR + 1),
      ),
      Paint()
        ..color = _kGold.withOpacity(0.30 + p * 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8 + p * 0.6,
    );

    // ─────────────────────────────────────────────────────
    // 8. SCREWS — four corner detail bolts on housing face
    // ─────────────────────────────────────────────────────
    final screwPositions = [
      Offset(hx + 12, hy + 12),
      Offset(hx + housingW - 12, hy + 12),
      Offset(hx + 12, hy + housingH - 12),
      Offset(hx + housingW - 12, hy + housingH - 12),
    ];
    for (final sp in screwPositions) {
      // screw head circle
      canvas.drawCircle(
        sp,
        4.5,
        Paint()
          ..shader = ui.Gradient.radial(
            sp,
            4.5,
            [const Color(0xFF2A2650), const Color(0xFF0D0B1E)],
            [0.0, 1.0],
          ),
      );
      // screw ring
      canvas.drawCircle(
        sp,
        4.5,
        Paint()
          ..color = _kGold.withOpacity(0.25 + p * 0.20)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8,
      );
      // cross notch horizontal
      canvas.drawLine(
        Offset(sp.dx - 2.5, sp.dy),
        Offset(sp.dx + 2.5, sp.dy),
        Paint()
          ..color = _kGold.withOpacity(0.30)
          ..strokeWidth = 0.7,
      );
      // cross notch vertical
      canvas.drawLine(
        Offset(sp.dx, sp.dy - 2.5),
        Offset(sp.dx, sp.dy + 2.5),
        Paint()
          ..color = _kGold.withOpacity(0.30)
          ..strokeWidth = 0.7,
      );
    }

    // ─────────────────────────────────────────────────────
    // 9. BACKGROUND SURFACE — app bg gradient fills rest
    // ─────────────────────────────────────────────────────
    final bgPath = Path()
      ..addRect(Rect.fromLTWH(-10, -10, size.width + 20, size.height + 20))
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(hx - 2, hy - 2, housingW + 4, housingH + 4),
          const Radius.circular(housingBR + 2),
        ),
      )
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(
      bgPath,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(0, 0),
          Offset(0, size.height),
          [
            const Color(0xFF1A1040).withOpacity(0.0),
            const Color(0xFF1A1040).withOpacity(0.96),
            const Color(0xFF0D0B1E),
          ],
          [0.0, 0.16, 1.0],
        ),
    );

    // ─────────────────────────────────────────────────────
    // 10. READOUT DISPLAY — small LCD-style text above slot
    //     idle: "INSERT CARD"   dragging: progress bar   done: "ACCEPTED ✓"
    // ─────────────────────────────────────────────────────
    final displayY = hy - 36.0;
    const displayW = 160.0;
    const displayH = 22.0;
    final displayX = cx - displayW / 2;

    // Display background (LCD panel look)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(displayX, displayY, displayW, displayH),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF050A14),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(displayX, displayY, displayW, displayH),
        const Radius.circular(4),
      ),
      Paint()
        ..color = _kGold.withOpacity(0.20 + p * 0.30)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );

    if (p < 0.05) {
      // "INSERT CARD" text segments — drawn as pixel-art lines
      _drawPixelText(
        canvas,
        'INSERT CARD',
        cx,
        displayY + displayH / 2,
        _kGold.withOpacity(0.45),
      );
    } else if (p >= 0.95) {
      // ACCEPTED
      _drawPixelText(
        canvas,
        'ACCEPTED  OK',
        cx,
        displayY + displayH / 2,
        const Color(0xFF44FF88).withOpacity(0.85),
      );
    } else {
      // Progress bar
      final barX = displayX + 10;
      const barH = 5.0;
      final barY = displayY + (displayH - barH) / 2;
      final barW = displayW - 20;
      // track
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(barX, barY, barW, barH),
          const Radius.circular(3),
        ),
        Paint()..color = const Color(0xFF1A2040),
      );
      // fill
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(barX, barY, barW * p, barH),
          const Radius.circular(3),
        ),
        Paint()
          ..shader = ui.Gradient.linear(
            Offset(barX, 0),
            Offset(barX + barW, 0),
            [_kGold, const Color(0xFFFFFFAA)],
            [0.0, 1.0],
          ),
      );
      // glow on fill tip
      if (p > 0.05) {
        canvas.drawCircle(
          Offset(barX + barW * p, barY + barH / 2),
          4,
          Paint()
            ..color = _kGold.withOpacity(0.6 * pulseMod)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
        );
      }
    }
  }

  // Simple pixel-text renderer — draws text as tiny gold rectangles
  // so it looks like a real LCD readout without needing TextPainter
  void _drawPixelText(
    Canvas canvas,
    String text,
    double cx,
    double cy,
    Color color,
  ) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
          fontFamily: 'monospace',
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));
  }

  @override
  bool shouldRepaint(_CoinSlotPainter o) =>
      o.progress != progress ||
      o.pulse != pulse ||
      o.cardColor != cardColor ||
      o.cardWidth != cardWidth;
}

// ─────────────────────────────────────────────────────────────
//  STANDARD PAINTERS
// ─────────────────────────────────────────────────────────────

class _HoleMaskPainter extends CustomPainter {
  final double opacity;
  const _HoleMaskPainter({required this.opacity});
  static const _r = Radius.circular(20);
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2;
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

class _ConfettiPainter extends CustomPainter {
  final List<_Particle> particles;
  const _ConfettiPainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    // p.x is relative to screen center; p.y is absolute from screen top
    final cx = size.width / 2;
    for (final p in particles) {
      final px = cx + p.x;
      final py = p.y;
      // skip if not yet on screen or far below
      if (py < -p.size || py > size.height + p.size) continue;
      // clip to screen width with a small margin
      if (px < -p.size || px > size.width + p.size) continue;

      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(p.angle);

      final paint = Paint()..color = p.color;

      if (p.circle) {
        // Round dot
        canvas.drawCircle(Offset.zero, p.size / 2, paint);
      } else {
        // Rectangle ribbon — elongated for better visual flutter
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset.zero,
              width: p.size,
              height: p.size * 0.42,
            ),
            const Radius.circular(2),
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
        (progress - 0.3).clamp(0.0, 1.0).toDouble(),
        progress.clamp(0.0, 1.0).toDouble(),
        (progress + 0.3).clamp(0.0, 1.0).toDouble(),
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
  Widget build(BuildContext context) => ClipRRect(
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
      color: const Color(0xFF1E1650),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: _kGold.withOpacity(0.35), width: 1),
      boxShadow: [
        BoxShadow(
          color: _kPurple.withOpacity(0.25),
          blurRadius: 12,
          spreadRadius: 2,
        ),
      ],
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
    for (final sign in [-1.0, 1.0])
      canvas.drawPath(
        Path()
          ..moveTo(cx, cy - 13)
          ..quadraticBezierTo(cx + sign * 10, cy - 22, cx + sign * 6, cy - 14)
          ..close(),
        g,
      );
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
  Widget build(BuildContext context) => ClipRRect(
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

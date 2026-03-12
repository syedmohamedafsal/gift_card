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
            begin: Alignment.centerLeft, // ← changed
            end: Alignment.centerRight, // ← changed
            colors: [
              Color(0xFF805A34),
              Color(0xFF805A34),
              // Color.fromARGB(255, 140, 79, 38),
              Color(0xFF000000),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: const WelcomeGiftScreen(),
      ),
    );
  }
}

class GiftCard {
  final String title;
  final String subtitle;
  final Color color;
  final Color textColor;
  final IconData icon;

  const GiftCard({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.textColor,
    required this.icon,
  });
}

class WelcomeGiftScreen extends StatefulWidget {
  const WelcomeGiftScreen({super.key});

  @override
  State<WelcomeGiftScreen> createState() => _WelcomeGiftScreenState();
}

class _WelcomeGiftScreenState extends State<WelcomeGiftScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 1;
  bool _isDragging = false;
  double _dragOffset = 0;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final List<GiftCard> cards = const [
    GiftCard(
      title: 'Flipkart',
      subtitle: '30%\ncashback\nup to ₹150',
      color: Color(0xFFF5F5F5),
      textColor: Color(0xFF333333),
      icon: Icons.shopping_bag_outlined,
    ),
    GiftCard(
      title: 'amazon',
      subtitle: '50%\ncashback\nup to ₹100',
      color: Color(0xFF00B2FF),
      textColor: Colors.white,
      icon: Icons.shopping_cart_outlined,
    ),
    GiftCard(
      title: 'Swiggy',
      subtitle: '₹75\ncashback\non orders',
      color: Color(0xFFFF6B35),
      textColor: Colors.white,
      icon: Icons.delivery_dining_outlined,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _isDragging = true;
      _dragOffset += details.delta.dy;
    });
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
      _dragOffset = 0;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${cards[_selectedIndex].title} offer activated! 🎉'),
        backgroundColor: cards[_selectedIndex].color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ── Exact warm dark background from your screenshot ──
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.maybePop(context),
                    child: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white70,
                      size: 20,
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

            const SizedBox(height: 24),

            // ── Gift icon — warm orange/red matching your screenshot ──
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFF2A2320),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.card_giftcard,
                color: Color(0xFFE8541A), // warm orange-red from gift icon
                size: 34,
              ),
            ),

            const SizedBox(height: 20),

            // ── Title ──
            const Text(
              'Choose your\nwelcome gift',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),

            const SizedBox(height: 48),

            // ── Cards fan layout ──
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  for (int i = 0; i < cards.length; i++)
                    if (i != _selectedIndex) _buildFanCard(i),
                  _buildSelectedCard(),
                ],
              ),
            ),

            // ── Drag down indicator ──
            GestureDetector(
              onVerticalDragUpdate: _onVerticalDragUpdate,
              onVerticalDragEnd: _onVerticalDragEnd,
              child: Column(
                children: [
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) => Transform.scale(
                      scale: _pulseAnimation.value,
                      child: child,
                    ),
                    child: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Color(0xFFFFD700),
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Drag down to activate offer',
                    style: TextStyle(
                      color: Color(0xFFFFD700),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFanCard(int index) {
    final isLeft = index < _selectedIndex;
    final angle = isLeft ? -0.25 : 0.25;
    final xOffset = isLeft ? -80.0 : 80.0;

    return Transform.translate(
      offset: Offset(xOffset, 20),
      child: Transform.rotate(
        angle: angle,
        child: GestureDetector(
          onTap: () => setState(() => _selectedIndex = index),
          child: _buildCard(cards[index], false),
        ),
      ),
    );
  }

  Widget _buildSelectedCard() {
    final offset = _isDragging ? _dragOffset.clamp(-30.0, 60.0) : 0.0;

    return Transform.translate(
      offset: Offset(0, offset),
      child: GestureDetector(
        onVerticalDragUpdate: _onVerticalDragUpdate,
        onVerticalDragEnd: _onVerticalDragEnd,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Glow behind selected card
            Container(
              width: 200,
              height: 280,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: cards[_selectedIndex].color.withOpacity(0.45),
                    blurRadius: 48,
                    spreadRadius: 10,
                  ),
                ],
              ),
            ),
            _buildCard(cards[_selectedIndex], true),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(GiftCard card, bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      width: isSelected ? 190 : 160,
      height: isSelected ? 270 : 230,
      decoration: BoxDecoration(
        color: card.color,
        borderRadius: BorderRadius.circular(20),
        border: isSelected
            ? Border.all(color: Colors.white.withOpacity(0.5), width: 2)
            : null,
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          // Decorative circle — top right
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          // Decorative circle — bottom left
          Positioned(
            bottom: -20,
            left: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          // Card content
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.title,
                  style: TextStyle(
                    color: card.textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: card.title == 'amazon' ? 1.2 : 0,
                  ),
                ),
                const Spacer(),
                Text(
                  card.subtitle,
                  style: TextStyle(
                    color: card.textColor,
                    fontSize: isSelected ? 22 : 18,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(card.icon, color: card.textColor, size: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    this.displayName = 'Rehan',
    this.showWelcome = true,
  });
  final String displayName;
  final bool showWelcome;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late final _welcome = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  );
  bool _started = false;
  bool _showPopup = false;
  int _tab = 1;

  @override
  void initState() {
    super.initState();
    _showPopup = widget.showWelcome;
    _welcome.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() => _showPopup = false);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (!widget.showWelcome || MediaQuery.disableAnimationsOf(context)) {
      _showPopup = false;
    } else {
      precacheImage(
        const AssetImage('assets/images/mhasla_wheels.jpg'),
        context,
      ).then((_) {
        if (mounted) _welcome.forward();
      });
    }
  }

  @override
  void dispose() {
    _welcome.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
    value: SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.white,
    ),
    child: Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
                    child: AnimatedSwitcher(
                      duration: Duration(
                        milliseconds: MediaQuery.disableAnimationsOf(context)
                            ? 0
                            : 250,
                      ),
                      child: _tab == 1 ? _dashboard() : _explore(),
                    ),
                  ),
                ),
                _navigation(),
              ],
            ),
          ),
          if (_showPopup) Positioned.fill(child: _welcomePopup()),
        ],
      ),
    ),
  );

  Widget _dashboard() => Column(
    key: const ValueKey('dashboard'),
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Row(
        children: [
          SizedBox(
            width: 28,
            child: IconButton(
              padding: EdgeInsets.zero,
              alignment: Alignment.centerLeft,
              tooltip: 'Explore',
              onPressed: () => setState(() => _tab = 0),
              icon: const Icon(
                Icons.chevron_left,
                color: Color(0xFF103B33),
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Your dashboard',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      Text(
        'Hello, ${widget.displayName}.',
        style: const TextStyle(
          fontFamily: 'Lora',
          fontSize: 38,
          height: 1.2,
          fontWeight: FontWeight.w600,
          color: Colors.black,
          letterSpacing: -1.2,
        ),
      ),
      const SizedBox(height: 18),
      const Text(
        'A little overview of everywhere you’re going.',
        style: TextStyle(fontSize: 11.5, color: Color(0xFF8A9690)),
      ),
      const SizedBox(height: 16),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _stat('01', 'Upcoming trip')),
          const SizedBox(width: 12),
          Expanded(child: _stat('08', 'Completed trips')),
        ],
      ),
      const SizedBox(height: 16),
      _stat('100', 'Total Credits', wide: true),
      const SizedBox(height: 16),
      const Text(
        'Your Journeys Flashbacks',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: Colors.black,
        ),
      ),
      const SizedBox(height: 16),
      const Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mhasla → Mumbai',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  '02 Oct 2026 · Completed',
                  style: TextStyle(fontSize: 11, color: Color(0xFF8A9690)),
                ),
              ],
            ),
          ),
          SizedBox(width: 12),
          Text(
            '₹2,800',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
        ],
      ),
    ],
  );

  Widget _stat(String number, String label, {bool wide = false}) => Container(
    constraints: BoxConstraints(minHeight: wide ? 90 : 94),
    padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 18),
    decoration: BoxDecoration(
      color: const Color(0xFFFF343D),
      borderRadius: BorderRadius.circular(19),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          number,
          style: const TextStyle(
            fontFamily: 'Lora',
            fontSize: 29,
            height: 1.05,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.white)),
      ],
    ),
  );

  Widget _navigation() => Container(
    margin: const EdgeInsets.fromLTRB(24, 8, 24, 8),
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: .06),
          blurRadius: 24,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: Row(
      children: [
        _navItem(0, Icons.home_outlined, 'Explore'),
        const SizedBox(width: 4),
        _navItem(1, Icons.grid_view_rounded, 'Dashboard'),
      ],
    ),
  );

  Widget _navItem(int index, IconData icon, String label) => Expanded(
    child: Semantics(
      selected: _tab == index,
      child: AnimatedContainer(
        duration: Duration(
          milliseconds: MediaQuery.disableAnimationsOf(context) ? 0 : 220,
        ),
        decoration: BoxDecoration(
          color: _tab == index ? const Color(0xFFEAF0E7) : Colors.white,
          borderRadius: BorderRadius.circular(17),
        ),
        child: TextButton(
          onPressed: () => setState(() => _tab = index),
          style: TextButton.styleFrom(
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 19,
                color: _tab == index ? Colors.black : const Color(0xFF87978D),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _explore() => Column(
    key: const ValueKey('explore'),
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const SizedBox(height: 20),
      const Text(
        'Explore Kokan.',
        style: TextStyle(
          fontFamily: 'Lora',
          fontSize: 36,
          fontWeight: FontWeight.w600,
          color: Color(0xFF103B33),
        ),
      ),
      const SizedBox(height: 12),
      const Text(
        'Your next journey starts here.',
        style: TextStyle(color: Color(0xFF829087)),
      ),
      const SizedBox(height: 24),
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F5EC),
          borderRadius: BorderRadius.circular(22),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.route_rounded, color: Color(0xFF103B33), size: 32),
            SizedBox(height: 16),
            Text(
              'Mhasla → Mumbai',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 8),
            Text(
              'Travel comfortably with Mhasla Wheels.',
              style: TextStyle(color: Color(0xFF829087)),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _welcomePopup() => AnimatedBuilder(
    animation: _welcome,
    builder: (context, child) {
      final progress = _welcome.value;
      final opacity = progress < .16
          ? Curves.easeOut.transform(progress / .16)
          : progress > .74
          ? 1 - Curves.easeIn.transform(((progress - .74) / .26).clamp(0, 1))
          : 1.0;
      final scale = progress < .25
          ? .65 + .35 * Curves.easeOutBack.transform(progress / .25)
          : progress > .74
          ? 1 - .12 * ((progress - .74) / .26)
          : 1.0;
      return AbsorbPointer(
        child: Opacity(
          opacity: opacity,
          child: ColoredBox(
            color: Colors.white.withValues(alpha: .86),
            child: Center(
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: MediaQuery.sizeOf(context).shortestSide * .7 > 300
                      ? 300
                      : MediaQuery.sizeOf(context).shortestSide * .7,
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: .12),
                        blurRadius: 36,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Image.asset(
                      'assets/images/mhasla_wheels.jpg',
                      semanticLabel: 'Welcome to Mhasla Wheels',
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

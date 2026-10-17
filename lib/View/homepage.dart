import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mhasla_wheels_mobile_application/Model/Userdashboard.model.dart';
import 'package:mhasla_wheels_mobile_application/ViewModel/geruserdetails.vm.dart';

const _green = Color(0xFF103B33);
const _cream = Color(0xFFF7F5EC);
const _muted = Color(0xFF697B70);

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

  var username;
  var useremail;
  var completedtrips;
  var upcomingtrips;


  late final _welcome = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  );
  bool _started = false;
  bool _showPopup = false;
  int _tab = 1;

  void initializedashboard(){
    print("upcming trips : ${Userdashboard.upcomingtrips}") ;
    setState(() {
      username = Userdashboard.name;
      useremail = Userdashboard.useremail;
      upcomingtrips = Userdashboard.upcomingtrips;
      completedtrips = Userdashboard.completedtrips;
    });
  }
  @override
  void initState() {
    super.initState();
    print("inside homepage initialization");
    initializedashboard();
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
      systemNavigationBarColor: _cream,
    ),
    child: Scaffold(
      backgroundColor: _cream,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
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

  Widget _dashboard() => LayoutBuilder(
    builder: (context, constraints) {
      final wide = constraints.maxWidth >= 760;
      return Column(
        key: const ValueKey('dashboard'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _enter(
            0,
            Row(
              children: [

                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.route_rounded,
                    color: _cream,
                    size: 21,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MHASLA WHEELS',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.8,
                          color: _muted,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Your dashboard',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _green,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Semantics(
                  label: '${widget.displayName}’s profile',
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFFEAEFE7),
                    child: Text(
                      widget.displayName.trim().isEmpty
                          ? 'M'
                          : widget.displayName
                                .trim()
                                .characters
                                .first
                                .toUpperCase(),
                      style: const TextStyle(
                        fontFamily: 'Lora',
                        fontWeight: FontWeight.w600,
                        fontSize: 19,
                        color: _green,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 23),

          _enter(
            1,
            Text(
              'Hello, ${username}.',
              style: TextStyle(
                fontFamily: 'Lora',
                fontSize: wide ? 44 : 35,
                height: 1.18,
                fontWeight: FontWeight.w600,
                color: _green,
                letterSpacing: -1.3,
              ),
            ),
          ),
          const SizedBox(height: 9),
          _enter(
            1,

            const Text(
              'A little overview of everywhere you’re going.',
              style: TextStyle(fontSize: 12, height: 1.5, color: _muted),
            ),

          ),
      const SizedBox(height: 22),
          if (wide) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 6, child: _enter(2, _journeyHero())),
                const SizedBox(width: 20),
                Expanded(flex: 5, child: _enter(3, _overview())),
              ],
            ),
          ] else ...[
            _enter(2, _journeyHero()),
            const SizedBox(height: 18),
            _enter(3, _overview()),
          ],
          const SizedBox(height: 25),
          _enter(
            4,
            const Row(
              children: [
                Expanded(
                  child: Text(
                    'Your journey flashbacks',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: _green,
                      letterSpacing: -.4,
                    ),
                  ),
                ),
                SizedBox(width: 10),

                Text(
                  'RECENT',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.6,
                    color: _muted,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 13),
          _enter(4, _recentJourney()),
          const SizedBox(height: 16),
          _enter(
            5,
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border_rounded, size: 12, color: _muted),
                SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Made for the roads you love.',
                    style: TextStyle(fontSize: 10, color: _muted),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    },
  );

  Widget _enter(int order, Widget child) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 1),
    duration: Duration(
      milliseconds: MediaQuery.disableAnimationsOf(context)
          ? 0
          : 480 + order * 65,
    ),
    curve: Curves.easeOutCubic,
    builder: (context, value, child) => Opacity(
      opacity: value,
      child: Transform.translate(
        offset: Offset(0, 14 * (1 - value)),
        child: child,
      ),
    ),
    child: child,
  );

  Widget _journeyHero() => Container(
    decoration: BoxDecoration(
      color: _green,
      borderRadius: BorderRadius.circular(24),
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -42,
            child: ExcludeSemantics(
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: .07),
                    width: 28,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.near_me_outlined,
                      size: 13,
                      color: Color(0xFFF3CF83),
                    ),
                    SizedBox(width: 7),
                    Flexible(
                      child: Text(
                        'THE ROAD IS CALLING',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.7,
                          color: Color(0xFFF3CF83),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Your next journey,\nmade easy.',
                  style: TextStyle(
                    fontFamily: 'Lora',
                    fontSize: 25,
                    height: 1.2,
                    fontWeight: FontWeight.w500,
                    color: _cream,
                    letterSpacing: -.5,
                  ),
                ),
                const SizedBox(height: 18),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton(
                    onPressed: () => setState(() => _tab = 0),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFFF454D),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 13,
                      ),
                      minimumSize: const Size(0, 46),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            'Explore routes',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        SizedBox(width: 14),
                        Icon(Icons.arrow_forward_rounded, size: 17),
                      ],
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

  Widget _overview() => LayoutBuilder(
    builder: (context, constraints) {
      final stack =
          MediaQuery.textScalerOf(context).scale(1) > 1.4 ||
          constraints.maxWidth < 260;
      final cards = [
        _stat(
          upcomingtrips.toString(),
          'Upcoming',
          Icons.route_outlined,
          color: const Color(0xFFFF454D),
          active: true,
        ),
        _stat(completedtrips.toString(), 'Completed', Icons.task_alt_rounded, color: Colors.white),
        _stat(
          '100',
          'Credits',
          Icons.stars_outlined,
          color: const Color(0xFFEAF0E5),
        ),
      ];
      if (stack) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < cards.length; i++) ...[
              if (i > 0) const SizedBox(height: 10),
              cards[i],
            ],
          ],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < cards.length; i++) ...[
            if (i > 0) const SizedBox(width: 10),
            Expanded(child: cards[i]),
          ],
        ],
      );
    },
  );

  Widget _stat(
    String number,
    String label,
    IconData icon, {
    required Color color,
    bool active = false,
  }) => Container(
    constraints: const BoxConstraints(minHeight: 122),
    padding: const EdgeInsets.fromLTRB(13, 15, 10, 15),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(19),
      border: active ? null : Border.all(color: const Color(0xFFE4E8E0)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 19, color: active ? Colors.white : _green),
        const SizedBox(height: 12),
        Text(
          number,
          style: TextStyle(
            fontFamily: 'Lora',
            fontSize: 28,
            height: 1,
            color: active ? Colors.white : _green,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            height: 1.3,
            fontWeight: FontWeight.w500,
            color: active ? Colors.white : _muted,
          ),
        ),
      ],
    ),
  );

  Widget _recentJourney() => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: const Color(0xFFE4E8E0)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 8,
          children: [
            const Text(
              '02 OCT 2026',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: _muted,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEDF4EB),
                borderRadius: BorderRadius.circular(7),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF416D49),
                    size: 11,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Completed',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF416D49),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 17),
        const Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 16,
          runSpacing: 12,
          children: [
            Text(
              'Mhasla → Mumbai',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: _green,
                letterSpacing: -.4,
              ),
            ),
            Text(
              '₹2,800',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        const Divider(height: 1, color: Color(0xFFEDF0E9)),
        const SizedBox(height: 12),
        const Row(
          children: [
            Icon(Icons.directions_car_outlined, size: 15, color: _muted),
            SizedBox(width: 7),
            Expanded(
              child: Text(
                'A journey to remember',
                style: TextStyle(fontSize: 10, color: _muted),
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _navigation() => Container(
    margin: const EdgeInsets.fromLTRB(20, 8, 20, 12),
    padding: const EdgeInsets.all(6),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(23),
      border: Border.all(color: const Color(0xFFE8ECE4)),
      boxShadow: [
        BoxShadow(
          color: _green.withValues(alpha: .05),
          blurRadius: 24,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Row(
      children: [
        _navItem(0, Icons.explore_outlined, 'Explore'),
        const SizedBox(width: 6),
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
          color: _tab == index ? _green : Colors.white,
          borderRadius: BorderRadius.circular(17),
        ),
        child: TextButton(
          onPressed: () => setState(() => _tab = index),
          style: TextButton.styleFrom(
            foregroundColor: _tab == index ? Colors.white : _muted,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 19),
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

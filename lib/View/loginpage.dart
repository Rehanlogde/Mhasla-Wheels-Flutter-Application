import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'homepage.dart';
import 'registration.dart';
import 'page_route.dart';
import 'rental_header.dart';

const _cream = Color(0xFFF7F5EC);
const _ink = Color(0xFF103B33);
const _red = Color(0xFFED0008);

/// Reference-matched login UI. Supply callbacks to connect authentication.
class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    this.onSignIn,
    this.onGoogleSignIn,
    this.onCreateAccount,
  });

  final Future<void> Function(String email, String password)? onSignIn;
  final Future<void> Function()? onGoogleSignIn;
  final VoidCallback? onCreateAccount;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 950),
  );
  bool _busy = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _entrance.value = 1;
    } else {
      _entrance.forward();
    }
  }

  @override
  void dispose() {
    _entrance.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _notice(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _authenticate({bool google = false}) async {
    if (_busy || (!google && !_form.currentState!.validate())) return;
    FocusScope.of(context).unfocus();
    if (google && widget.onGoogleSignIn == null) {
      _notice('Google sign-in is not connected yet.');
      return;
    }
    setState(() => _busy = true);
    try {
      if (google) {
        await widget.onGoogleSignIn!();
      } else {
        await widget.onSignIn?.call(_email.text.trim(), _password.text);
      }
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        animatedPage(context, const HomePage()),
        (_) => false,
      );
    } catch (_) {
      if (mounted) _notice('Unable to sign in. Please try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _reveal(double start, Widget child) {
    final animation = CurvedAnimation(
      parent: _entrance,
      curve: Interval(start, 1, curve: Curves.easeOutCubic),
    );
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0, .07),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: _cream,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: _cream,
        body: LayoutBuilder(
          builder: (context, viewport) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: viewport.maxHeight),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: BoxConstraints.tightFor(
                      width: viewport.maxWidth,
                    ),
                    child: LayoutBuilder(
                      builder: (context, panel) {
                        // The supplied design is 390 logical pixels wide.
                        final scale = (panel.maxWidth / 390).clamp(.78, 1.23);
                        final top = MediaQuery.paddingOf(context).top;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(
                              height: 230 * scale + top,
                              child: ClipRect(
                                child: Stack(
                                  children: [
                                    const Positioned.fill(
                                      child: CustomPaint(
                                        painter: RentalRoadPainter(),
                                      ),
                                    ),
                                    Positioned(
                                      left: 24 * scale,
                                      top: top + 12,
                                      child: _reveal(
                                        0,
                                        Row(
                                          children: [
                                            CustomPaint(
                                              size: Size(
                                                29 * scale,
                                                22 * scale,
                                              ),
                                              painter: RentalLogoPainter(),
                                            ),
                                            SizedBox(width: 12 * scale),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'MHASLA WHEELS',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12 * scale,
                                                    fontWeight: FontWeight.w800,
                                                    letterSpacing: 1.6 * scale,
                                                  ),
                                                ),
                                                SizedBox(height: 3 * scale),
                                                Text(
                                                  'YOUR JOURNEY. BEAUTIFULLY SIMPLE.',
                                                  style: TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 5.5 * scale,
                                                    letterSpacing: .7 * scale,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      left: 24 * scale,
                                      right: 10 * scale,
                                      top: top + 112 * scale,
                                      child: _reveal(
                                        .06,
                                        Text(
                                          'Best Car Rental\nOut there in Kokan',
                                          style: TextStyle(
                                            fontFamily: 'BarlowCondensed',
                                            fontStyle: FontStyle.italic,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                            fontSize: 40 * scale,
                                            height: 1.18,
                                            letterSpacing: 1.1 * scale,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Rounded cream sheet overlays the bottom of the artwork.
                            Transform.translate(
                              offset: Offset(0, -14 * scale),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _cream,
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(23 * scale),
                                  ),
                                ),
                                padding: EdgeInsets.fromLTRB(
                                  24 * scale,
                                  24 * scale,
                                  24 * scale,
                                  32 * scale,
                                ),
                                child: Form(
                                  key: _form,
                                  child: AutofillGroup(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        _reveal(
                                          .12,
                                          Text(
                                            'Welcome back.',
                                            style: TextStyle(
                                              fontFamily: 'Lora',
                                              fontSize: 32 * scale,
                                              height: 1.25,
                                              fontWeight: FontWeight.w600,
                                              color: _ink,
                                              letterSpacing: -1.1 * scale,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 16 * scale),
                                        _reveal(
                                          .16,
                                          Text(
                                            'Sign in to enjoy exclusive services we provide',
                                            style: TextStyle(
                                              color: const Color(0xFF829087),
                                              fontSize: 11.5 * scale,
                                              height: 1.5,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 12 * scale),
                                        _reveal(
                                          .2,
                                          _PressButton(
                                            color: const Color(0xFF0064B7),
                                            radius: 16 * scale,
                                            onTap: _busy
                                                ? null
                                                : () => _authenticate(
                                                    google: true,
                                                  ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'G',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 15 * scale,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                SizedBox(width: 20 * scale),
                                                Flexible(
                                                  child: FittedBox(
                                                    fit: BoxFit.scaleDown,
                                                    child: Text(
                                                      'Continue with Google',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 14 * scale,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 16 * scale),
                                        _reveal(
                                          .24,
                                          Row(
                                            children: [
                                              SizedBox(
                                                width: 40 * scale,
                                                child: const Divider(
                                                  color: Color(0xFFB9C3BA),
                                                ),
                                              ),
                                              Flexible(
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 9 * scale,
                                                  ),
                                                  child: Text(
                                                    'or use your credentials',
                                                    style: TextStyle(
                                                      fontSize: 10 * scale,
                                                      color: const Color(
                                                        0xFF829087,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 40 * scale,
                                                child: const Divider(
                                                  color: Color(0xFFB9C3BA),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 12 * scale),
                                        _reveal(
                                          .28,
                                          _field(scale, password: false),
                                        ),
                                        SizedBox(height: 14 * scale),
                                        _reveal(
                                          .32,
                                          _field(scale, password: true),
                                        ),
                                        SizedBox(height: 40 * scale),
                                        _reveal(
                                          .36,
                                          _PressButton(
                                            color: _red,
                                            radius: 17 * scale,
                                            onTap: _busy
                                                ? null
                                                : () => _authenticate(),
                                            child: _busy
                                                ? const SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child:
                                                        CircularProgressIndicator(
                                                          color: Colors.white,
                                                          strokeWidth: 2,
                                                        ),
                                                  )
                                                : Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        'Sign in',
                                                        style: TextStyle(
                                                          fontFamily: 'Lora',
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          fontSize: 14 * scale,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 7 * scale,
                                                      ),
                                                      Icon(
                                                        Icons
                                                            .arrow_forward_rounded,
                                                        color: Colors.white,
                                                        size: 16 * scale,
                                                      ),
                                                    ],
                                                  ),
                                          ),
                                        ),
                                        SizedBox(height: 7 * scale),
                                        _reveal(
                                          .4,
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: TextButton(
                                              style: TextButton.styleFrom(
                                                foregroundColor: _ink,
                                                padding: EdgeInsets.zero,
                                                alignment: Alignment.centerLeft,
                                                minimumSize: const Size(0, 44),
                                              ),
                                              onPressed: _busy
                                                  ? null
                                                  : () {
                                                      if (widget
                                                              .onCreateAccount !=
                                                          null) {
                                                        widget
                                                            .onCreateAccount!();
                                                      } else {
                                                        Navigator.of(
                                                          context,
                                                        ).push(
                                                          animatedPage(
                                                            context,
                                                            const RegistrationPage(),
                                                          ),
                                                        );
                                                      }
                                                    },
                                              child: Text(
                                                'New here?  Create an account ↗',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 12 * scale,
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
                            ),
                            SizedBox(
                              height: math.max(
                                50 * scale,
                                MediaQuery.paddingOf(context).bottom,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _field(double scale, {required bool password}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 18 * scale,
        vertical: 14 * scale,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17 * scale),
        border: Border.all(color: const Color(0xFFD9DFD8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            password ? 'PASSWORD' : 'EMAIL ADDRESS',
            style: TextStyle(
              color: const Color(0xFF6D8076),
              fontSize: 9 * scale,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5 * scale,
            ),
          ),
          SizedBox(height: 5 * scale),
          TextFormField(
            controller: password ? _password : _email,
            enabled: !_busy,
            obscureText: password,
            obscuringCharacter: '•',
            keyboardType: password
                ? TextInputType.visiblePassword
                : TextInputType.emailAddress,
            textInputAction: password
                ? TextInputAction.done
                : TextInputAction.next,
            autofillHints: [
              password ? AutofillHints.password : AutofillHints.email,
            ],
            autocorrect: false,
            enableSuggestions: !password,
            style: TextStyle(color: _ink, fontSize: 14 * scale),
            onFieldSubmitted: password ? (_) => _authenticate() : null,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return password
                    ? 'Enter your password'
                    : 'Enter your email address';
              }
              if (!password &&
                  !RegExp(
                    r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                  ).hasMatch(value.trim())) {
                return 'Enter a valid email address';
              }
              return null;
            },
            decoration: InputDecoration(
              isDense: true,
              hintText: password ? '••••••••••••' : 'you@example.com',
              hintStyle: TextStyle(color: _ink, fontSize: 14 * scale),
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }
}

class _PressButton extends StatefulWidget {
  const _PressButton({
    required this.color,
    required this.radius,
    required this.child,
    this.onTap,
  });
  final Color color;
  final double radius;
  final Widget child;
  final VoidCallback? onTap;
  @override
  State<_PressButton> createState() => _PressButtonState();
}

class _PressButtonState extends State<_PressButton> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) => AnimatedScale(
    scale: _pressed ? .98 : 1,
    duration: Duration(
      milliseconds: MediaQuery.disableAnimationsOf(context) ? 0 : 120,
    ),
    child: Material(
      color: widget.color,
      borderRadius: BorderRadius.circular(widget.radius),
      child: InkWell(
        borderRadius: BorderRadius.circular(widget.radius),
        onTap: widget.onTap,
        onHighlightChanged: (value) => setState(() => _pressed = value),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 52),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: widget.child,
          ),
        ),
      ),
    ),
  );
}

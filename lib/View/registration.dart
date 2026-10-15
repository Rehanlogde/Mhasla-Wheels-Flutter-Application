import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'homepage.dart';
import 'page_route.dart';
import 'rental_header.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key, this.onRegister, this.onGoogleSignIn});

  final Future<void> Function(
    String name,
    String email,
    String mobile,
    String password,
  )?
  onRegister;
  final Future<void> Function()? onGoogleSignIn;

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage>
    with SingleTickerProviderStateMixin {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _mobile = TextEditingController();
  final _password = TextEditingController();
  late final _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
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
    for (final controller in [_name, _email, _mobile, _password]) {
      controller.dispose();
    }
    _entrance.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_busy || !_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _busy = true);
    try {
      await widget.onRegister?.call(
        _name.text.trim(),
        _email.text.trim(),
        '+91${_mobile.text}',
        _password.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        animatedPage(
          context,
          HomePage(displayName: _name.text.trim().split(RegExp(r'\s+')).first),
        ),
        (_) => false,
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to create your account. Please try again.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _google() async {
    if (_busy) return;
    if (widget.onGoogleSignIn == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Google sign-in is not connected yet.')),
      );
      return;
    }
    setState(() => _busy = true);
    try {
      await widget.onGoogleSignIn!();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          animatedPage(context, const HomePage()),
          (_) => false,
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to sign in with Google. Please try again.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
    value: SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: const Color(0xFFF7F5EC),
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
    child: Scaffold(
      backgroundColor: const Color(0xFFF7F5EC),
      body: LayoutBuilder(
        builder: (context, viewport) {
          final scale = (viewport.maxWidth / 390).clamp(.78, 1.23);
          return SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: viewport.maxHeight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  RentalHeader(
                    scale: scale,
                    top: MediaQuery.paddingOf(context).top,
                  ),
                  Transform.translate(
                    offset: Offset(0, -14 * scale),
                    child: Container(
                      padding: EdgeInsets.fromLTRB(
                        24 * scale,
                        24 * scale,
                        24 * scale,
                        8 * scale,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F5EC),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(23 * scale),
                        ),
                      ),
                      child: FadeTransition(
                        opacity: CurvedAnimation(
                          parent: _entrance,
                          curve: Curves.easeOut,
                        ),
                        child: Form(
                          key: _form,
                          child: AutofillGroup(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Be a chill tourist,\nEnroll now',
                                  style: TextStyle(
                                    fontFamily: 'Lora',
                                    fontSize: 32 * scale,
                                    height: 1.2,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF103B33),
                                    letterSpacing: -1.1 * scale,
                                  ),
                                ),
                                SizedBox(height: 16 * scale),
                                Text(
                                  'Create your Mhasla Wheels account.',
                                  style: TextStyle(
                                    color: const Color(0xFF829087),
                                    fontSize: 11.5 * scale,
                                  ),
                                ),
                                SizedBox(height: 12 * scale),
                                FilledButton(
                                  onPressed: _busy ? null : _google,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFF0064B7),
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size.fromHeight(52),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        16 * scale,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text('G'),
                                      SizedBox(width: 20 * scale),
                                      const Flexible(
                                        child: Text('Continue with Google'),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 12 * scale),
                                _field(
                                  scale,
                                  controller: _name,
                                  label: 'FULL NAME',
                                  hint: 'Your full name',
                                  autofill: AutofillHints.name,
                                  validator: (value) => value.trim().isEmpty
                                      ? 'Enter your full name'
                                      : null,
                                ),
                                SizedBox(height: 12 * scale),
                                _field(
                                  scale,
                                  controller: _email,
                                  label: 'EMAIL ADDRESS',
                                  hint: 'you@example.com',
                                  autofill: AutofillHints.email,
                                  type: TextInputType.emailAddress,
                                  validator: (value) =>
                                      RegExp(
                                        r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                                      ).hasMatch(value.trim())
                                      ? null
                                      : 'Enter a valid email address',
                                ),
                                SizedBox(height: 12 * scale),
                                _field(
                                  scale,
                                  controller: _mobile,
                                  label: 'MOBILE NUMBER',
                                  hint: 'Enter mobile number',
                                  autofill:
                                      AutofillHints.telephoneNumberNational,
                                  type: TextInputType.phone,
                                  validator: (value) =>
                                      RegExp(r'^[6-9]\d{9}$').hasMatch(value)
                                      ? null
                                      : 'Enter a valid 10-digit mobile number',
                                ),
                                SizedBox(height: 12 * scale),
                                _field(
                                  scale,
                                  controller: _password,
                                  label: 'CREATE PASSWORD',
                                  hint: 'At least 8 characters',
                                  autofill: AutofillHints.newPassword,
                                  password: true,
                                  validator: (value) => value.length >= 8
                                      ? null
                                      : 'Use at least 8 characters',
                                ),
                                SizedBox(height: 12 * scale),
                                Text(
                                  'By continuing, you agree to our Terms of Service\nand Privacy Policy.',
                                  style: TextStyle(
                                    color: const Color(0xFF829087),
                                    fontSize: 9.5 * scale,
                                    height: 1.4,
                                  ),
                                ),
                                SizedBox(height: 10 * scale),
                                FilledButton(
                                  onPressed: _busy ? null : _register,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFFED0008),
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size.fromHeight(52),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        17 * scale,
                                      ),
                                    ),
                                  ),
                                  child: _busy
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Create account',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Icon(
                                              Icons.arrow_forward_rounded,
                                              size: 18,
                                            ),
                                          ],
                                        ),
                                ),
                                TextButton(
                                  onPressed: _busy
                                      ? null
                                      : () => Navigator.of(context).maybePop(),
                                  style: TextButton.styleFrom(
                                    foregroundColor: const Color(0xFF103B33),
                                  ),
                                  child: const Text(
                                    'Already have an account?  Sign in',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.paddingOf(context).bottom),
                ],
              ),
            ),
          );
        },
      ),
    ),
  );

  Widget _field(
    double scale, {
    required TextEditingController controller,
    required String label,
    required String hint,
    required String autofill,
    required String? Function(String) validator,
    TextInputType? type,
    bool password = false,
  }) => Container(
    padding: EdgeInsets.symmetric(horizontal: 17 * scale, vertical: 13 * scale),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(17 * scale),
      border: Border.all(color: const Color(0xFFD9DFD8)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 9 * scale,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.4 * scale,
            color: const Color(0xFF6D8076),
          ),
        ),
        SizedBox(height: 5 * scale),
        TextFormField(
          controller: controller,
          enabled: !_busy,
          obscureText: password,
          obscuringCharacter: '•',
          autocorrect: false,
          enableSuggestions: !password,
          autofillHints: [autofill],
          keyboardType: type,
          textCapitalization: controller == _name
              ? TextCapitalization.words
              : TextCapitalization.none,
          inputFormatters: controller == _mobile
              ? [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ]
              : null,
          textInputAction: password
              ? TextInputAction.done
              : TextInputAction.next,
          onFieldSubmitted: password ? (_) => _register() : null,
          validator: (value) => validator(value ?? ''),
          style: TextStyle(
            fontSize: 14 * scale,
            color: const Color(0xFF103B33),
          ),
          decoration: InputDecoration(
            isDense: true,
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 14 * scale,
              color: const Color(0xFF103B33),
            ),
            prefixIcon: controller == _mobile
                ? Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Text(
                      '+91',
                      style: TextStyle(
                        fontSize: 14 * scale,
                        color: const Color(0xFF103B33),
                      ),
                    ),
                  )
                : null,
            prefixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),
          ),
        ),
      ],
    ),
  );
}

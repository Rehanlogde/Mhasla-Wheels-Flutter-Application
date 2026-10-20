import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// UI only. No network calls, authentication, fare calculation or OTP logic.
// Open with BookingPage(vehicleid: yourVehicleId).
// Vehicle name/capacity and the places list use temporary UI defaults.
// Supply your quote through estimatedFare and your driver list through drivers.
// onChanged reports UI selections; onBook is called only after review/confirmation.
const _cream = Color(0xFFF7F5EC);
const _green = Color(0xFF103B33);
const _muted = Color(0xFF697B70);
const _red = Color(0xFFFF454D);
const _border = Color(0xFFE4E8E0);

enum JourneyType {
  oneWay('one_way', 'One way', Icons.arrow_forward_rounded),
  roundTrip('round_trip', 'Round trip', Icons.sync_rounded),
  shared('shared', 'Shared / seat', Icons.people_outline_rounded),
  custom('customize', 'Customize', Icons.tune_rounded);

  const JourneyType(this.value, this.label, this.icon);
  final String value;
  final String label;
  final IconData icon;
}

class BookingDriver {
  const BookingDriver({required this.id, required this.name});
  final String id;
  final String name;
}

/// Form selections only; the server remains responsible for prices and booking.
class BookingDraft {
  const BookingDraft({
    required this.vehicleid,
    required this.vehicleName,
    required this.pickup,
    required this.drop,
    required this.journeyType,
    required this.departure,
    required this.returnAt,
    required this.members,
    required this.address,
    required this.phone,
    required this.driverId,
    required this.customDetails,
    required this.customRate,
    required this.customUnit,
    required this.redeemCredits,
  });
  final String vehicleid;
  final String vehicleName;
  final String? pickup;
  final String? drop;
  final JourneyType journeyType;
  final DateTime? departure;
  final DateTime? returnAt;
  final int members;
  final String address;
  final String phone;
  final String? driverId;
  final String? customDetails;
  final double? customRate;
  final String? customUnit;
  final bool redeemCredits;
}

class BookingPage extends StatefulWidget {
  const BookingPage({
    super.key,
    required this.vehicleid,
    this.vehicleName = 'Selected vehicle',
    this.capacity = 4,
    this.vehicleImageAsset,
    this.estimatedFare,
    this.availableCredits = 0,
    this.initialPhone = '',
    this.drivers = const [],
    this.locations = const [
      'Mhasla', 'Shrivardhan', 'Borli', 'Mumbai', 'Mangaon', 'Pune',
      'Indapur', 'Mahad', 'Chiplun', 'Divegar', 'Goregaon (Lonere)',
      'Kharsai', 'Warwatna',
    ],
    this.onChanged,
    this.onBook,
    this.onCancel,
  }) : assert(capacity > 0),
        assert(availableCredits >= 0),
        assert(estimatedFare == null || estimatedFare >= 0);

  final String vehicleid;
  final String vehicleName;
  final int capacity;
  final String? vehicleImageAsset;
  /// Pass a current server quote, or null while the quote is unavailable.
  final double? estimatedFare;
  final int availableCredits;
  final String initialPhone;
  final List<BookingDriver> drivers;
  final List<String> locations;
  final ValueChanged<BookingDraft>? onChanged;
  final Future<void> Function(BookingDraft draft)? onBook;
  final VoidCallback? onCancel;

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage>
    with SingleTickerProviderStateMixin {
  final _form = GlobalKey<FormState>();
  final _address = TextEditingController();
  final _customDetails = TextEditingController();
  final _customRate = TextEditingController();
  final _departureText = TextEditingController();
  final _returnText = TextEditingController();
  late final _entrance = AnimationController(
    vsync: this, duration: const Duration(milliseconds: 360),
  );
  late final Animation<double> _fade = _entrance.drive(
    CurveTween(curve: Curves.easeOutCubic),
  );
  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, .012), end: Offset.zero,
  ).animate(_fade);
  bool _started = false;
  bool _busy = false;
  bool _redeem = false;
  String? _from;
  String? _to;
  String? _driver;
  String? _unit;
  late String _phone = widget.initialPhone;
  int _members = 1;
  JourneyType _journey = JourneyType.oneWay;
  DateTime? _departure;
  DateTime? _returnAt;

  bool get _canRedeem => widget.availableCredits >= 1000 &&
      (widget.estimatedFare ?? 0) >= 1000;
  Duration get _motion => MediaQuery.disableAnimationsOf(context)
      ? Duration.zero : const Duration(milliseconds: 220);
  String get _fare => widget.estimatedFare == null
      ? 'To be confirmed' : '₹${widget.estimatedFare!.toStringAsFixed(0)}';
  List<String> get _locations => widget.locations.toSet().toList()..sort();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncDateText();
    if (MediaQuery.disableAnimationsOf(context)) {
      _entrance.value = 1;
      _started = true;
    } else if (!_started) {
      _started = true;
      _entrance.forward();
    }
  }

  @override
  void didUpdateWidget(covariant BookingPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_members > widget.capacity) _members = widget.capacity;
    if (!widget.locations.contains(_from)) _from = null;
    if (!widget.locations.contains(_to)) _to = null;
    if (!widget.drivers.any((driver) => driver.id == _driver)) _driver = null;
    if (!_canRedeem || oldWidget.estimatedFare != widget.estimatedFare) _redeem = false;
    if (oldWidget.initialPhone != widget.initialPhone && _phone == oldWidget.initialPhone) {
      _phone = widget.initialPhone;
    }
  }

  @override
  void dispose() {
    _entrance.dispose();
    for (final controller in [
      _address, _customDetails, _customRate, _departureText, _returnText,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  BookingDraft get _draft => BookingDraft(
    vehicleid: widget.vehicleid,
    vehicleName: widget.vehicleName, pickup: _from, drop: _to,
    journeyType: _journey, departure: _departure,
    returnAt: _journey == JourneyType.roundTrip ? _returnAt : null,
    members: _members, address: _address.text.trim(), phone: _phone,
    driverId: _driver,
    customDetails: _journey == JourneyType.custom ? _customDetails.text.trim() : null,
    customRate: _journey == JourneyType.custom ? double.tryParse(_customRate.text) : null,
    customUnit: _journey == JourneyType.custom ? _unit : null,
    redeemCredits: _redeem && _canRedeem,
  );

  void _notify() => widget.onChanged?.call(_draft);
  void _change(VoidCallback action, {bool invalidateCredits = false}) {
    setState(() {
      action();
      if (invalidateCredits) _redeem = false;
    });
    _notify();
  }

  ThemeData _theme(BuildContext context) => Theme.of(context).copyWith(
    colorScheme: ColorScheme.fromSeed(seedColor: _green).copyWith(
      primary: _green, surface: _cream,
    ),
    scaffoldBackgroundColor: _cream,
    inputDecorationTheme: InputDecorationTheme(
      filled: true, fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
      labelStyle: const TextStyle(color: _muted, fontSize: 13),
      hintStyle: const TextStyle(color: _muted, fontSize: 13),
      errorMaxLines: 2,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: _border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: _green, width: 1.5),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(
      backgroundColor: _red, foregroundColor: Colors.white,
      minimumSize: const Size(0, 52),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
    )),
  );

  String _dateLabel(DateTime date) =>
      '${MaterialLocalizations.of(context).formatMediumDate(date)} · '
          '${TimeOfDay.fromDateTime(date).format(context)}';

  void _syncDateText() {
    _departureText.text = _departure == null ? '' : _dateLabel(_departure!);
    _returnText.text = _returnAt == null ? '' : _dateLabel(_returnAt!);
  }

  Future<void> _pickDate({bool returning = false}) async {
    FocusScope.of(context).unfocus();
    final now = DateTime.now();
    final earliest = returning && _departure != null && _departure!.isAfter(now)
        ? _departure! : now;
    final previous = returning ? _returnAt : _departure;
    final initial = previous != null && previous.isAfter(earliest) ? previous : earliest;
    final day = await showDatePicker(
      context: context, initialDate: initial,
      firstDate: DateUtils.dateOnly(earliest),
      lastDate: DateTime(earliest.year + 2, 12, 31),
      helpText: returning ? 'When are you heading back?' : 'When are we picking you up?',
      builder: (context, child) => Theme(data: _theme(context), child: child!),
    );
    if (day == null || !mounted) return;
    final time = await showTimePicker(
      context: context, initialTime: TimeOfDay.fromDateTime(initial),
      builder: (context, child) => Theme(data: _theme(context), child: child!),
    );
    if (time == null || !mounted) return;
    final value = DateTime(day.year, day.month, day.day, time.hour, time.minute);
    if (!value.isAfter(DateTime.now()) ||
        (returning && _departure != null && !value.isAfter(_departure!))) {
      _message(returning ? 'Choose a return time after your pickup.' : 'Choose a pickup time in the future.');
      return;
    }
    _change(() {
      if (returning) {
        _returnAt = value;
      } else {
        _departure = value;
        if (_returnAt != null && !_returnAt!.isAfter(value)) _returnAt = null;
      }
      _syncDateText();
    }, invalidateCredits: true);
  }

  void _message(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _cancel() {
    if (widget.onCancel != null) {
      widget.onCancel!();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  Future<void> _review() async {
    if (_busy || !_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    if (!RegExp(r'^\d{10}$').hasMatch(_phone)) {
      final phone = await showModalBottomSheet<String>(
        context: context, isScrollControlled: true, useSafeArea: true,
        backgroundColor: _cream,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
        builder: (context) => Theme(
          data: _theme(context), child: _PhoneEntry(initialPhone: _phone),
        ),
      );
      if (phone == null || !mounted) return;
      _change(() => _phone = phone);
    }
    if (!mounted) return;
    final draft = _draft;
    final confirm = await showModalBottomSheet<bool>(
      context: context, isScrollControlled: true, useSafeArea: true,
      backgroundColor: _cream,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
      builder: (sheetContext) => Theme(
        data: _theme(sheetContext),
        child: SafeArea(child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            _handle(),
            const SizedBox(height: 18),
            const Text('One last look.', style: TextStyle(fontFamily: 'Lora', fontSize: 28, color: _green)),
            const SizedBox(height: 6),
            const Text('Your journey, just the way you planned it.', style: TextStyle(color: _muted)),
            const SizedBox(height: 22),
            _detail('Route', '${draft.pickup} → ${draft.drop}'),
            _detail('Ride', '${widget.vehicleName} · ${draft.journeyType.label}'),
            _detail('Pickup', _dateLabel(draft.departure!)),
            if (draft.returnAt != null) _detail('Return', _dateLabel(draft.returnAt!)),
            _detail('Passengers', '${draft.members}'),
            _detail('Pickup address', draft.address),
            _detail('Driver', _driverName()),
            _detail('Phone', '+91 ${draft.phone}'),
            if (draft.customDetails != null) ...[
              _detail('Custom journey', draft.customDetails!),
              _detail('Requested rate', '₹${draft.customRate} / ${draft.customUnit}'),
            ],
            if (draft.redeemCredits) _detail('Credits', 'Redemption requested'),
            const Divider(height: 28, color: _border),
            _detail('Estimated fare', _fare),
            const Text('Final fare and availability will be confirmed.', style: TextStyle(fontSize: 12, color: _muted)),
            const SizedBox(height: 22),
            FilledButton(
              onPressed: () => Navigator.pop(sheetContext, true),
              child: Text(widget.onBook == null ? 'Looks good' : 'Book a ride'),
            ),
            TextButton(onPressed: () => Navigator.pop(sheetContext, false), child: const Text('Edit details')),
          ]),
        )),
      ),
    );
    if (confirm != true || !mounted || widget.onBook == null) return;
    setState(() => _busy = true);
    try {
      await widget.onBook!(draft);
    } catch (_) {
      if (mounted) _message('Unable to submit your ride. Please try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _driverName() {
    for (final driver in widget.drivers) {
      if (driver.id == _driver) return driver.name;
    }
    return 'No preference';
  }

  @override
  Widget build(BuildContext context) => Theme(
    data: _theme(context),
    child: Builder(builder: (context) => PopScope(
      canPop: !_busy,
      child: Scaffold(
        backgroundColor: _cream,
        appBar: AppBar(
          backgroundColor: _cream, foregroundColor: _green,
          surfaceTintColor: Colors.transparent, elevation: 0,
          leading: IconButton(onPressed: _busy ? null : _cancel, tooltip: 'Back', icon: const Icon(Icons.arrow_back_rounded)),
          title: const Text('MHASLA WHEELS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 2)),
          centerTitle: true,
        ),
        body: AbsorbPointer(
          absorbing: _busy,
          child: FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _slide,
              child: RepaintBoundary(
                child: SingleChildScrollView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                  child: Center(child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: Form(
                      key: _form,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                        const Text('Let’s get you going.', style: TextStyle(fontFamily: 'Lora', fontSize: 32, height: 1.2, letterSpacing: -1, color: _green)),
                        const SizedBox(height: 8),
                        const Text('A few details. A beautiful journey ahead.', style: TextStyle(color: _muted, fontSize: 13)),
                        const SizedBox(height: 24),
                        _vehicle(),
                        const SizedBox(height: 22),
                        LayoutBuilder(builder: (context, constraints) {
                          final journey = _journeyFields();
                          final people = _passengerFields();
                          if (constraints.maxWidth < 800) {
                            return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [journey, const SizedBox(height: 20), people]);
                          }
                          return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Expanded(flex: 6, child: journey), const SizedBox(width: 22),
                            Expanded(flex: 5, child: people),
                          ]);
                        }),
                      ]),
                    ),
                  )),
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Container(
            decoration: const BoxDecoration(color: _cream, border: Border(top: BorderSide(color: _border))),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: Center(heightFactor: 1, child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: LayoutBuilder(builder: (context, constraints) {
                final fare = Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('ESTIMATED FARE', style: TextStyle(fontSize: 9, letterSpacing: 1.4, color: _muted, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(_fare, style: const TextStyle(fontSize: 18, color: _green, fontWeight: FontWeight.w800)),
                    ]);
                final action = FilledButton(
                  onPressed: _busy ? null : _review,
                  child: _busy
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Row(mainAxisSize: MainAxisSize.min, children: [Text('Review ride'), SizedBox(width: 12), Icon(Icons.arrow_forward_rounded, size: 19)]),
                );
                if (constraints.maxWidth < 360 || MediaQuery.textScalerOf(context).scale(1) > 1.3) {
                  return Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [fare, const SizedBox(height: 10), action]);
                }
                return Row(children: [Expanded(child: fare), const SizedBox(width: 12), action]);
              }),
            )),
          ),
        ),
      ),
    )),
  );

  Widget _vehicle() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: _green, borderRadius: BorderRadius.circular(23)),
    child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('YOUR RIDE', style: TextStyle(color: Color(0xFFF3CF83), fontSize: 9, letterSpacing: 1.8, fontWeight: FontWeight.w700)),
        const SizedBox(height: 9),
        Text(widget.vehicleName, style: const TextStyle(fontFamily: 'Lora', color: Colors.white, fontSize: 26)),
        const SizedBox(height: 8),
        Text('Up to ${widget.capacity} passengers', style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ])),
      const SizedBox(width: 12),
      SizedBox(width: 80, height: 68, child: widget.vehicleImageAsset == null
          ? const Icon(Icons.directions_car_outlined, color: Color(0xFFF3CF83), size: 54)
          : Image.asset(widget.vehicleImageAsset!, fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Icon(Icons.directions_car_outlined, color: Colors.white70, size: 54))),
    ]),
  );

  Widget _journeyFields() => _card('01', 'Plan your journey', [
    Wrap(spacing: 8, runSpacing: 8, children: JourneyType.values.map((type) => ChoiceChip(
      label: Text(type.label), avatar: Icon(type.icon, size: 17, color: _journey == type ? Colors.white : _green),
      selected: _journey == type, showCheckmark: false,
      selectedColor: _green, backgroundColor: _cream,
      labelStyle: TextStyle(color: _journey == type ? Colors.white : _green, fontSize: 12, fontWeight: FontWeight.w600),
      side: BorderSide(color: _journey == type ? _green : _border),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (_) { if (_journey != type) _change(() => _journey = type, invalidateCredits: true); },
    )).toList()),
    const SizedBox(height: 22),
    _locationField(pickup: true),
    Align(alignment: Alignment.centerRight, child: IconButton(
      tooltip: 'Swap pickup and drop', icon: const Icon(Icons.swap_vert_rounded, color: _green),
      onPressed: _from == null && _to == null ? null : () => _change(() {
        final old = _from; _from = _to; _to = old;
      }, invalidateCredits: true),
    )),
    _locationField(pickup: false),
    const SizedBox(height: 18),
    TextFormField(
      controller: _departureText, readOnly: true,
      decoration: const InputDecoration(labelText: 'Pickup date & time', prefixIcon: Icon(Icons.calendar_today_outlined, size: 20), suffixIcon: Icon(Icons.expand_more_rounded)),
      onTap: () => _pickDate(),
      validator: (_) => _departure == null ? 'Choose your pickup date and time.'
          : !_departure!.isAfter(DateTime.now()) ? 'Pickup time must be in the future.' : null,
    ),
    // Only the small conditional region animates its layout.
    AnimatedSize(duration: _motion, curve: Curves.easeOutCubic, alignment: Alignment.topCenter,
      child: _journey == JourneyType.roundTrip ? Padding(
        padding: const EdgeInsets.only(top: 16),
        child: TextFormField(
          controller: _returnText, readOnly: true,
          decoration: const InputDecoration(labelText: 'Return date & time', prefixIcon: Icon(Icons.event_repeat_rounded, size: 20)),
          onTap: () => _pickDate(returning: true),
          validator: (_) => _returnAt == null ? 'Choose your return date and time.'
              : _departure != null && !_returnAt!.isAfter(_departure!) ? 'Return must be after pickup.' : null,
        ),
      ) : const SizedBox(width: double.infinity),
    ),
    AnimatedSize(duration: _motion, curve: Curves.easeOutCubic, alignment: Alignment.topCenter,
      child: _journey == JourneyType.custom ? Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Column(children: [
          TextFormField(controller: _customDetails, minLines: 3, maxLines: 5,
            decoration: const InputDecoration(labelText: 'Your custom journey', hintText: 'Stops, plans, and anything we should know…', alignLabelWithHint: true),
            onChanged: (_) => _notify(),
            validator: (value) => value == null || value.trim().isEmpty ? 'Tell us a little about your journey.' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(controller: _customRate,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Custom rate', prefixText: '₹ '),
            onChanged: (_) => _notify(),
            validator: (value) {
              final amount = double.tryParse(value ?? '');
              return amount == null || !amount.isFinite || amount <= 0 ? 'Enter a valid rate above zero.' : null;
            },
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: _unit, isExpanded: true,
            decoration: const InputDecoration(labelText: 'Rate unit'),
            items: const [DropdownMenuItem(value: 'km', child: Text('Per kilometre')), DropdownMenuItem(value: 'hour', child: Text('Per hour')), DropdownMenuItem(value: 'day', child: Text('Per day')), DropdownMenuItem(value: 'trip', child: Text('Per trip'))],
            onChanged: (value) => _change(() => _unit = value),
            validator: (value) => value == null ? 'Select a rate unit.' : null,
          ),
        ]),
      ) : const SizedBox(width: double.infinity),
    ),
  ]);

  Widget _locationField({required bool pickup}) {
    final value = pickup ? _from : _to;
    final options = _locations.where((place) => pickup || place != _from).toList();
    return DropdownButtonFormField<String>(
      key: ValueKey('${pickup ? 'pickup' : 'drop'}-$value'),
      initialValue: options.contains(value) ? value : null,
      isExpanded: true,
      decoration: InputDecoration(labelText: pickup ? 'Pickup location' : 'Drop location',
          prefixIcon: Icon(pickup ? Icons.trip_origin_rounded : Icons.location_on_outlined, size: 20, color: pickup ? _green : _red)),
      items: options.map((place) => DropdownMenuItem(value: place, child: Text(place, overflow: TextOverflow.ellipsis))).toList(),
      onChanged: (selection) => _change(() {
        if (pickup) { _from = selection; if (_from == _to) _to = null; }
        else { _to = selection; }
      }, invalidateCredits: true),
      validator: (selection) => selection == null ? 'Select a ${pickup ? 'pickup' : 'drop'} location.' : null,
    );
  }

  Widget _passengerFields() => _card('02', 'Make it yours', [
    const Text('Who’s coming along?', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _green)),
    const SizedBox(height: 6),
    Text('Choose 1–${widget.capacity} passengers', style: const TextStyle(fontSize: 12, color: _muted)),
    const SizedBox(height: 10),
    Row(children: [
      IconButton.filledTonal(tooltip: 'Remove passenger', onPressed: _members <= 1 ? null : () => _change(() => _members--, invalidateCredits: true), icon: const Icon(Icons.remove_rounded)),
      Expanded(child: Semantics(liveRegion: true, label: '$_members passengers', child: Text('$_members', textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Lora', fontSize: 28, color: _green)))),
      IconButton.filledTonal(tooltip: 'Add passenger', onPressed: _members >= widget.capacity ? null : () => _change(() => _members++, invalidateCredits: true), icon: const Icon(Icons.add_rounded)),
    ]),
    const SizedBox(height: 20),
    TextFormField(controller: _address, minLines: 2, maxLines: 4,
      textCapitalization: TextCapitalization.sentences,
      decoration: const InputDecoration(labelText: 'Pickup address', hintText: 'Building, street or a nearby landmark', alignLabelWithHint: true),
      onChanged: (_) => _notify(),
      validator: (value) => value == null || value.trim().isEmpty ? 'Add your pickup address.' : null,
    ),
    const SizedBox(height: 16),
    DropdownButtonFormField<String>(
      key: ValueKey('driver-$_driver'),
      initialValue: _driver ?? '', isExpanded: true,
      decoration: const InputDecoration(labelText: 'Preferred driver', prefixIcon: Icon(Icons.person_outline_rounded)),
      items: [
        const DropdownMenuItem(value: '', child: Text('No preference')),
        ...widget.drivers.map((driver) => DropdownMenuItem(value: driver.id, child: Text(driver.name, overflow: TextOverflow.ellipsis))),
      ],
      onChanged: (value) => _change(() => _driver = value == '' ? null : value),
    ),
    const SizedBox(height: 20),
    Container(
      decoration: BoxDecoration(color: _cream, borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [const Icon(Icons.stars_outlined, color: _green, size: 22), const SizedBox(width: 9),
          Expanded(child: Text('${widget.availableCredits} credits', style: const TextStyle(fontWeight: FontWeight.w700, color: _green))),
          Switch.adaptive(value: _redeem && _canRedeem, onChanged: _canRedeem ? (value) => _change(() => _redeem = value) : null),
        ]),
        Text(_canRedeem ? 'Use my credits for this ride'
            : widget.availableCredits < 1000 ? '${1000 - widget.availableCredits} more credits to unlock redemption.'
            : 'Available for fares of ₹1,000 or more.',
            style: const TextStyle(fontSize: 11, height: 1.5, color: _muted)),
      ]),
    ),
    const SizedBox(height: 10),
    TextButton(onPressed: _cancel, child: const Text('Cancel booking', style: TextStyle(color: _muted))),
  ]);

  Widget _card(String number, String title, List<Widget> children) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: _border)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        Text(number, style: const TextStyle(fontSize: 11, color: _muted, fontWeight: FontWeight.w700)),
        const SizedBox(width: 10),
        Expanded(child: Text(title, style: const TextStyle(fontSize: 17, color: _green, fontWeight: FontWeight.w800))),
      ]),
      const SizedBox(height: 22), ...children,
    ]),
  );
}

Widget _handle() => Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: _border, borderRadius: BorderRadius.circular(4))));

Widget _detail(String label, String value) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 7),
  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(color: _muted, fontSize: 11)),
    const SizedBox(height: 3),
    Text(value, style: const TextStyle(color: _green, fontSize: 14, fontWeight: FontWeight.w600)),
  ]),
);

class _PhoneEntry extends StatefulWidget {
  const _PhoneEntry({required this.initialPhone});
  final String initialPhone;
  @override
  State<_PhoneEntry> createState() => _PhoneEntryState();
}

class _PhoneEntryState extends State<_PhoneEntry> {
  final _form = GlobalKey<FormState>();
  late final _phone = TextEditingController(text: widget.initialPhone);
  @override
  void dispose() { _phone.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
    child: SafeArea(child: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: Form(key: _form, child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _handle(), const SizedBox(height: 22),
        const Text('Stay in the loop.', style: TextStyle(fontFamily: 'Lora', fontSize: 28, color: _green)),
        const SizedBox(height: 8),
        const Text('Add a phone number for your ride updates.', style: TextStyle(color: _muted, fontSize: 13)),
        const SizedBox(height: 22),
        TextFormField(controller: _phone, keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.telephoneNumberNational],
          inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
          decoration: const InputDecoration(labelText: 'Phone number', prefixText: '+91 '),
          validator: (value) => !RegExp(r'^\d{10}$').hasMatch(value ?? '') ? 'Enter a 10-digit phone number.' : null,
          onFieldSubmitted: (_) => _submit(),
        ),
        const SizedBox(height: 18),
        FilledButton(onPressed: _submit, child: const Text('Continue')),
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Go back')),
      ])),
    )),
  );

  void _submit() {
    if (_form.currentState!.validate()) Navigator.pop(context, _phone.text.trim());
  }
}

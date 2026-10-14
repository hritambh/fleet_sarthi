part of 'welcome_screen.dart';

/// The use cases the page walks through, each with a mock screen.
enum _UseCase { fuel, trips, settlement, documents, offline }

extension on _UseCase {
  IconData get icon => switch (this) {
    _UseCase.fuel => Icons.local_gas_station_rounded,
    _UseCase.trips => Icons.route_rounded,
    _UseCase.settlement => Icons.account_balance_wallet_rounded,
    _UseCase.documents => Icons.verified_user_rounded,
    _UseCase.offline => Icons.signal_wifi_off_rounded,
  };

  Color get color => switch (this) {
    _UseCase.fuel => _amber,
    _UseCase.trips => _violet,
    _UseCase.settlement => _green,
    _UseCase.documents => _rose,
    _UseCase.offline => _cyan,
  };

  String tab(AppLocalizations l) => switch (this) {
    _UseCase.fuel => l.welcomeTabFuel,
    _UseCase.trips => l.welcomeMockTrips,
    _UseCase.settlement => l.welcomeTabSettlement,
    _UseCase.documents => l.welcomeTabDocuments,
    _UseCase.offline => l.welcomeTabOffline,
  };

  String title(AppLocalizations l) => switch (this) {
    _UseCase.fuel => l.welcomeUcFuelTitle,
    _UseCase.trips => l.welcomeUcTripsTitle,
    _UseCase.settlement => l.welcomeUcSettleTitle,
    _UseCase.documents => l.welcomeUcDocsTitle,
    _UseCase.offline => l.welcomeUcOfflineTitle,
  };

  String body(AppLocalizations l) => switch (this) {
    _UseCase.fuel => l.welcomeUcFuelBody,
    _UseCase.trips => l.welcomeUcTripsBody,
    _UseCase.settlement => l.welcomeUcSettleBody,
    _UseCase.documents => l.welcomeUcDocsBody,
    _UseCase.offline => l.welcomeUcOfflineBody,
  };

  List<String> points(AppLocalizations l) => switch (this) {
    _UseCase.fuel => [
      l.welcomeUcFuelPoint1,
      l.welcomeUcFuelPoint2,
      l.welcomeUcFuelPoint3,
    ],
    _UseCase.trips => [
      l.welcomeUcTripsPoint1,
      l.welcomeUcTripsPoint2,
      l.welcomeUcTripsPoint3,
    ],
    _UseCase.settlement => [
      l.welcomeUcSettlePoint1,
      l.welcomeUcSettlePoint2,
      l.welcomeUcSettlePoint3,
    ],
    _UseCase.documents => [
      l.welcomeUcDocsPoint1,
      l.welcomeUcDocsPoint2,
      l.welcomeUcDocsPoint3,
    ],
    _UseCase.offline => [
      l.welcomeUcOfflinePoint1,
      l.welcomeUcOfflinePoint2,
      l.welcomeUcOfflinePoint3,
    ],
  };

  Widget get mock => switch (this) {
    _UseCase.fuel => const _FuelMock(),
    _UseCase.trips => const _TripMock(),
    _UseCase.settlement => const _SettlementMock(),
    _UseCase.documents => const _DocumentsMock(),
    _UseCase.offline => const _OfflineMock(),
  };
}

// ---------------------------------------------------------------------------
// Hero carousel

/// The hero's slides: the owner's day, then a use case per slide. Advances on
/// its own every few seconds (paused under the mouse, off with reduced
/// motion); the tabs and a swipe pick a slide.
class _HeroCarousel extends StatefulWidget {
  const _HeroCarousel();

  @override
  State<_HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<_HeroCarousel>
    with SingleTickerProviderStateMixin {
  /// Null is the "Today" overview.
  static const _slides = <_UseCase?>[
    null,
    _UseCase.trips,
    _UseCase.settlement,
    _UseCase.documents,
    _UseCase.offline,
  ];

  late final _progress =
      AnimationController(vsync: this, duration: const Duration(seconds: 5))
        ..addStatusListener((status) {
          if (status == AnimationStatus.completed) _show(_index + 1);
        });
  var _index = 0;
  var _auto = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _auto = !MediaQuery.disableAnimationsOf(context);
    _auto ? _progress.forward() : _progress.stop();
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  void _show(int index) {
    setState(() => _index = index % _slides.length);
    if (_auto) _progress.forward(from: 0);
  }

  void _pause(bool paused) {
    if (!_auto) return;
    paused ? _progress.stop() : _progress.forward();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final slide = _slides[_index];
    return MouseRegion(
      onEnter: (_) => _pause(true),
      onExit: (_) => _pause(false),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onHorizontalDragEnd: (details) {
              final v = details.primaryVelocity ?? 0;
              if (v.abs() < 200) return;
              _show(_index + (v < 0 ? 1 : _slides.length - 1));
            },
            child: _GlassFrame(
              child: AnimatedSize(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 450),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  layoutBuilder: (current, previous) => Stack(
                    alignment: Alignment.topCenter,
                    children: [...previous, ?current],
                  ),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween(
                        begin: const Offset(0.06, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  ),
                  child: KeyedSubtree(
                    key: ValueKey(_index),
                    child: slide?.mock ?? const _TodayMock(),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 6,
            runSpacing: 8,
            children: [
              for (final (i, s) in _slides.indexed)
                _SlideTab(
                  key: Key('welcome-slide-$i'),
                  label: s?.tab(l) ?? l.welcomeMockToday,
                  icon: s?.icon ?? Icons.dashboard_rounded,
                  selected: i == _index,
                  progress: _auto && i == _index ? _progress : null,
                  onTap: () => _show(i),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A tab under the carousel; the selected one shows its icon and fills up as
/// its slide's time runs out.
class _SlideTab extends StatelessWidget {
  const _SlideTab({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.progress,
    super.key,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final Animation<double>? progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? TaxcyColors.blue950 : Colors.white;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: selected
                ? Colors.white
                : Colors.white.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: Colors.white.withValues(alpha: selected ? 1 : 0.14),
            ),
          ),
          child: Stack(
            children: [
              if (progress case final progress?)
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: progress,
                    builder: (context, _) => FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress.value,
                      child: const ColoredBox(color: TaxcyColors.blue100),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Only the selected tab shows its icon, so the row fits
                    // in one line next to the hero copy.
                    if (selected) ...[
                      Icon(icon, size: 16, color: fg),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      label,
                      style: TextStyle(
                        color: fg,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Frosted glass around a white mock screen.
class _GlassFrame extends StatelessWidget {
  const _GlassFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(30),
      border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      boxShadow: [
        BoxShadow(
          color: _violet.withValues(alpha: 0.35),
          blurRadius: 80,
          offset: const Offset(0, 30),
        ),
      ],
    ),
    child: Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: child,
    ),
  );
}

// ---------------------------------------------------------------------------
// Scroll showcase

/// "See it in action": one use case per row, text and mock side by side
/// (alternating on wide screens, stacked on phones), each sliding in as it
/// scrolls into view.
class _Showcase extends StatelessWidget {
  const _Showcase();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return _Content(
      child: Column(
        children: [
          _SectionHeader(
            kicker: l.welcomeShowcaseKicker,
            title: l.welcomeShowcaseTitle,
            subtitle: l.welcomeShowcaseSubtitle,
          ),
          const SizedBox(height: 56),
          for (final (i, useCase) in _UseCase.values.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: 72),
              child: _ScrollReveal(
                child: _ShowcaseRow(useCase: useCase, flip: i.isOdd),
              ),
            ),
        ],
      ),
    );
  }
}

class _ShowcaseRow extends StatelessWidget {
  const _ShowcaseRow({required this.useCase, required this.flip});

  final _UseCase useCase;
  final bool flip;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final wide = _isWide(context);
    final text = Column(
      key: Key('welcome-usecase-${useCase.name}'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: useCase.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(useCase.icon, size: 16, color: useCase.color),
              const SizedBox(width: 6),
              Text(
                useCase.tab(l),
                style: TextStyle(
                  color: Color.lerp(useCase.color, Colors.black, 0.35),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          useCase.title(l),
          style: TextStyle(
            color: TaxcyColors.blue950,
            fontSize: wide ? 34 : 26,
            height: 1.15,
            fontWeight: FontWeight.w800,
            letterSpacing: _tracking(context, -0.9),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          useCase.body(l),
          style: const TextStyle(
            color: TaxcyColors.muted,
            fontSize: 16.5,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 18),
        for (final point in useCase.points(l))
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.check_circle_rounded, size: 20, color: _green),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    point,
                    style: const TextStyle(
                      color: TaxcyColors.ink,
                      fontSize: 15.5,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
    final stage = ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Stack(
        children: [
          const Positioned.fill(child: _NightSky()),
          Padding(
            padding: EdgeInsets.all(wide ? 36 : 18),
            child: _GlassFrame(child: useCase.mock),
          ),
        ],
      ),
    );
    if (!wide) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [text, const SizedBox(height: 28), stage],
      );
    }
    final cells = [
      Expanded(flex: 10, child: text),
      const SizedBox(width: 64),
      Expanded(flex: 11, child: stage),
    ];
    return Row(children: flip ? cells.reversed.toList() : cells);
  }
}

/// Fades and slides [child] in the first time it scrolls into view.
class _ScrollReveal extends StatefulWidget {
  const _ScrollReveal({required this.child});

  final Widget child;

  @override
  State<_ScrollReveal> createState() => _ScrollRevealState();
}

class _ScrollRevealState extends State<_ScrollReveal> {
  ScrollPosition? _position;
  var _shown = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) _shown = true;
    final position = Scrollable.maybeOf(context)?.position;
    if (position != _position) {
      _position?.removeListener(_check);
      _position = position?..addListener(_check);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  @override
  void dispose() {
    _position?.removeListener(_check);
    super.dispose();
  }

  void _check() {
    if (_shown || !mounted) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final top = box.localToGlobal(Offset.zero).dy;
    if (top < MediaQuery.sizeOf(context).height * 0.85) {
      setState(() => _shown = true);
      _position?.removeListener(_check);
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedOpacity(
    opacity: _shown ? 1 : 0,
    duration: const Duration(milliseconds: 700),
    curve: Curves.easeOutCubic,
    child: AnimatedSlide(
      offset: _shown ? Offset.zero : const Offset(0, 0.08),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      child: widget.child,
    ),
  );
}

// ---------------------------------------------------------------------------
// Mock screens

class _MockHeader extends StatelessWidget {
  const _MockHeader({required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: TaxcyColors.blue950,
            ),
          ),
        ),
        ?trailing,
      ],
    ),
  );
}

class _Tag extends StatelessWidget {
  const _Tag(this.label, this.color, {this.icon});

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon ?? Icons.circle, size: icon == null ? 8 : 14, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: Color.lerp(color, Colors.black, 0.35),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class _FuelMock extends StatelessWidget {
  const _FuelMock();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _MockHeader(
          title: 'MH 12 AB 4521',
          trailing: _Tag(l.welcomeMockFuelTitle, _amber),
        ),
        Row(
          children: [
            Expanded(
              child: _Figure(
                value: '9.1 km/l',
                label: l.welcomeUcFuelThisCycle,
                color: _rose,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _Figure(
                value: '11.7 km/l',
                label: l.welcomeUcFuelUsual,
                color: TaxcyColors.blue950,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const _MileageChart(),
        const SizedBox(height: 8),
        _Event(
          icon: Icons.local_gas_station_rounded,
          color: _amber,
          title: l.welcomeMockFuelTitle,
          body: l.welcomeMockFuelBody,
        ),
      ],
    );
  }
}

class _Figure extends StatelessWidget {
  const _Figure({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      border: Border.all(color: TaxcyColors.border),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: TaxcyColors.muted, fontSize: 12),
        ),
      ],
    ),
  );
}

class _TripMock extends StatelessWidget {
  const _TripMock();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _MockHeader(
          title: l.welcomeUcTripRoute,
          trailing: _Tag(
            l.welcomeMockGpsTitle,
            _green,
            icon: Icons.check_rounded,
          ),
        ),
        Row(
          children: [
            Expanded(child: _Odometer(l.welcomeUcTripStart, '45,210')),
            const SizedBox(width: 8),
            Expanded(child: _Odometer(l.welcomeUcTripEnd, '45,361')),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 110,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: const Color(0xFFEFF4FA),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const CustomPaint(painter: _RoutePainter()),
        ),
        const SizedBox(height: 8),
        _Event(
          icon: Icons.person_rounded,
          color: TaxcyColors.blue600,
          title: l.welcomeUcTripDriver,
          body: l.welcomeUcTripCheck,
        ),
      ],
    );
  }
}

/// A stylised odometer photo: dark glass with the reading in it.
class _Odometer extends StatelessWidget {
  const _Odometer(this.label, this.reading);

  final String label;
  final String reading;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF1F2937), Color(0xFF0B1220)],
      ),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.photo_camera_rounded,
              size: 14,
              color: Colors.white70,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 8),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            reading,
            style: const TextStyle(
              color: Color(0xFF7DD3FC),
              fontSize: 22,
              fontWeight: FontWeight.w700,
              fontFeatures: [FontFeature.tabularFigures()],
              letterSpacing: 2,
            ),
          ),
        ),
      ],
    ),
  );
}

/// A winding route between two pins over faint map blocks.
class _RoutePainter extends CustomPainter {
  const _RoutePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final block = Paint()..color = Colors.white;
    for (var y = 10.0; y < size.height; y += 34) {
      for (var x = 10.0 + (y % 68 == 10 ? 0 : 22); x < size.width; x += 56) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x, y, 40, 22),
            const Radius.circular(4),
          ),
          block,
        );
      }
    }
    final start = Offset(size.width * 0.08, size.height * 0.75);
    final end = Offset(size.width * 0.92, size.height * 0.25);
    final route = Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(
        size.width * 0.35,
        size.height * 1.05,
        size.width * 0.45,
        size.height * -0.1,
        size.width * 0.65,
        size.height * 0.45,
      )
      ..quadraticBezierTo(size.width * 0.78, size.height * 0.8, end.dx, end.dy);
    canvas.drawPath(
      route,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..shader = _brand.createShader(Offset.zero & size),
    );
    for (final (point, color) in [(start, _green), (end, _rose)]) {
      canvas
        ..drawCircle(point, 9, Paint()..color = color.withValues(alpha: 0.25))
        ..drawCircle(point, 5, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(_RoutePainter oldDelegate) => false;
}

class _SettlementMock extends StatelessWidget {
  const _SettlementMock();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    // 4,200 fare = 2,800 cash + 1,400 online; Ramesh keeps 640 spent on tolls
    // and parking and 1,260 pay (30%), so hands over 2,800 − 640 − 1,260.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _MockHeader(
          title: l.welcomeUcSettleHeader,
          trailing: _Tag(l.welcomeMockLive, _green),
        ),
        _Line(l.welcomeUcSettleFare, '₹4,200', bold: true),
        _Line(l.welcomeUcSettleCash, '₹2,800'),
        _Line(l.welcomeUcSettleOnline, '₹1,400'),
        const Divider(height: 20),
        _Line(l.welcomeUcSettleExpenses, '− ₹640'),
        _Line(l.welcomeUcSettlePay, '− ₹1,260'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                TaxcyColors.blue600.withValues(alpha: 0.1),
                _violet.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l.welcomeUcSettleNet,
                  style: const TextStyle(
                    color: TaxcyColors.blue950,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Text(
                '₹900',
                style: TextStyle(
                  color: TaxcyColors.blue700,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Line extends StatelessWidget {
  const _Line(this.label, this.amount, {this.bold = false});

  final String label;
  final String amount;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      color: bold ? TaxcyColors.ink : TaxcyColors.muted,
      fontSize: 14,
      fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          const SizedBox(width: 8),
          Text(
            amount,
            style: style.copyWith(
              color: TaxcyColors.ink,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentsMock extends StatelessWidget {
  const _DocumentsMock();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _MockHeader(
          title: l.welcomeUcDocsHeader,
          trailing: const _Tag('3', _rose, icon: Icons.notifications_rounded),
        ),
        _DocRow(
          icon: Icons.badge_rounded,
          title: l.welcomeUcDocsRow2,
          due: l.welcomeUcDocsDue2,
          color: _rose,
        ),
        _DocRow(
          icon: Icons.shield_rounded,
          title: l.welcomeUcDocsRow1,
          due: l.welcomeUcDocsDue1,
          color: _amber,
        ),
        _DocRow(
          icon: Icons.description_rounded,
          title: l.welcomeUcDocsRow3,
          due: l.welcomeUcDocsDue3,
          color: TaxcyColors.blue600,
        ),
        _DocRow(
          icon: Icons.eco_rounded,
          title: l.welcomeUcDocsRow4,
          due: l.welcomeUcDocsDue4,
          color: _green,
        ),
      ],
    );
  }
}

class _DocRow extends StatelessWidget {
  const _DocRow({
    required this.icon,
    required this.title,
    required this.due,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String due;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      border: Border.all(color: TaxcyColors.border),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: TaxcyColors.ink,
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        _Tag(due, color),
      ],
    ),
  );
}

class _OfflineMock extends StatelessWidget {
  const _OfflineMock();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF1F2937),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.signal_wifi_off_rounded,
                size: 18,
                color: Color(0xFFFBBF24),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l.welcomeUcOfflineBanner,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        _Event(
          icon: Icons.directions_car_rounded,
          color: TaxcyColors.blue600,
          title: l.welcomeUcOfflineTrip,
          body: l.welcomeUcTripDriver,
        ),
        _Event(
          icon: Icons.local_gas_station_rounded,
          color: _amber,
          title: l.welcomeUcOfflineFuel,
          body: 'MH 12 AB 4521',
        ),
        _Event(
          icon: Icons.payments_rounded,
          color: _green,
          title: l.welcomeUcOfflineCash,
          body: l.welcomeUcTripRoute,
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: TaxcyColors.background,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.cloud_upload_rounded,
                    size: 18,
                    color: TaxcyColors.blue700,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l.welcomeUcOfflineWaiting,
                      style: const TextStyle(
                        color: TaxcyColors.blue950,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: const LinearProgressIndicator(
                  value: 0.35,
                  minHeight: 6,
                  backgroundColor: TaxcyColors.blue100,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../l10n/app_localizations.dart';
import '../common/format.dart';
import '../common/language_picker.dart';

part 'welcome_showcase.dart';

/// The page a signed-out visitor sees first: what Fleet Sarthi does and who it
/// is for, then sign up ([onGetStarted]) or log in ([onSignIn]). A dark hero
/// with a preview of the owner's day, then light sections, then a dark call
/// to action. Everything it promises is something the app does today.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({
    required this.onGetStarted,
    required this.onSignIn,
    super.key,
  });

  final VoidCallback onGetStarted;
  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: TaxcyColors.background,
    body: SingleChildScrollView(
      key: const Key('welcome-scroll'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Hero(onGetStarted: onGetStarted, onSignIn: onSignIn),
          const _MadeFor(),
          const _Showcase(),
          const _Features(),
          const _Steps(),
          const _Audiences(),
          const _Faq(),
          _FinalCall(onGetStarted: onGetStarted),
          const _Footer(),
        ],
      ),
    ),
  );
}

// Colours used only here: a night-blue hero and the brand gradient (blue →
// violet → cyan) for accents.
const _night = Color(0xFF050A1C);
const _nightBlue = Color(0xFF0B1A4A);
const _violet = Color(0xFF7C3AED);
const _cyan = Color(0xFF06B6D4);
const _accentText = [Color(0xFF60A5FA), Color(0xFFA78BFA), Color(0xFF22D3EE)];
const _brand = LinearGradient(colors: [TaxcyColors.blue600, _violet]);
const _amber = Color(0xFFF59E0B);
const _green = Color(0xFF10B981);
const _rose = Color(0xFFF43F5E);

const _maxContentWidth = 1160.0;
const _wideMin = 900.0;

bool _isWide(BuildContext context) =>
    MediaQuery.sizeOf(context).width >= _wideMin;

/// Tight tracking suits big Latin headings; Devanagari needs its default.
double _tracking(BuildContext context, double latin) =>
    Localizations.localeOf(context).languageCode == 'en' ? latin : 0;

/// Centres [child] at the content width, with page gutters.
class _Content extends StatelessWidget {
  const _Content({required this.child, this.vertical = 72});

  final Widget child;
  final double vertical;

  @override
  Widget build(BuildContext context) {
    final gutter = _isWide(context) ? 40.0 : 20.0;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: gutter, vertical: vertical),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxContentWidth),
          child: child,
        ),
      ),
    );
  }
}

/// Fades and lifts [child] in once, [delay] (0..1) into the entrance.
class _Reveal extends StatelessWidget {
  const _Reveal({required this.child, this.delay = 0});

  final Widget child;
  final double delay;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1100),
      curve: Interval(delay, 1, curve: Curves.easeOutCubic),
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, 24 * (1 - t)),
          child: child,
        ),
      ),
      child: child,
    );
  }
}

/// Lays [children] out in [columns] equal columns (one on phones).
class _Grid extends StatelessWidget {
  const _Grid({required this.children, required this.columns});

  final List<Widget> children;
  final int columns;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      const gap = 20.0;
      final width = constraints.maxWidth;
      final count = width < 600 ? 1 : (width < _wideMin ? 2 : columns);
      final itemWidth = (width - gap * (count - 1)) / count;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [
          for (final child in children)
            SizedBox(width: itemWidth, child: child),
        ],
      );
    },
  );
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.kicker,
    required this.title,
    this.subtitle,
  });

  final String kicker;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final wide = _isWide(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 720),
      child: Column(
        children: [
          ShaderMask(
            shaderCallback: _brand.createShader,
            child: Text(
              kicker.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.6,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: TaxcyColors.blue950,
              fontSize: wide ? 40 : 28,
              height: 1.15,
              fontWeight: FontWeight.w800,
              letterSpacing: _tracking(context, -1),
            ),
          ),
          if (subtitle case final subtitle?) ...[
            const SizedBox(height: 14),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: TaxcyColors.muted,
                fontSize: 17,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// The brand-gradient pill button with an arrow.
class _GradientButton extends StatelessWidget {
  const _GradientButton({
    required this.label,
    required this.onPressed,
    required this.buttonKey,
  });

  final String label;
  final VoidCallback onPressed;
  final Key buttonKey;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      gradient: _brand,
      borderRadius: BorderRadius.circular(999),
      boxShadow: [
        BoxShadow(
          color: TaxcyColors.blue600.withValues(alpha: 0.45),
          blurRadius: 28,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: Material(
      type: MaterialType.transparency,
      child: InkWell(
        key: buttonKey,
        onTap: onPressed,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
            ],
          ),
        ),
      ),
    ),
  );
}

class _Logo extends StatelessWidget {
  const _Logo({this.light = true});

  final bool light;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          gradient: _brand,
          borderRadius: BorderRadius.circular(11),
        ),
        child: const Icon(Icons.local_taxi, color: Colors.white, size: 22),
      ),
      const SizedBox(width: 10),
      Flexible(
        child: Text(
          context.l10n.appTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: light ? Colors.white : TaxcyColors.blue950,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: _tracking(context, -0.4),
          ),
        ),
      ),
    ],
  );
}

// ---------------------------------------------------------------------------
// Hero

class _Hero extends StatelessWidget {
  const _Hero({required this.onGetStarted, required this.onSignIn});

  final VoidCallback onGetStarted;
  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final wide = _isWide(context);
    final copy = _HeroCopy(onGetStarted: onGetStarted, onSignIn: onSignIn);
    const preview = _Reveal(delay: 0.25, child: _HeroCarousel());
    return Stack(
      children: [
        const Positioned.fill(child: _NightSky()),
        SafeArea(
          bottom: false,
          child: _Content(
            vertical: 16,
            child: Column(
              children: [
                Row(
                  children: [
                    const Expanded(child: _Logo()),
                    const LanguageButton(color: Colors.white),
                    TextButton(
                      key: const Key('welcome-sign-in'),
                      onPressed: onSignIn,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                      ),
                      child: Text(l.welcomeSignIn),
                    ),
                  ],
                ),
                SizedBox(height: wide ? 72 : 40),
                if (wide)
                  Row(
                    children: [
                      Expanded(flex: 11, child: copy),
                      const SizedBox(width: 56),
                      const Expanded(flex: 9, child: preview),
                    ],
                  )
                else ...[
                  copy,
                  const SizedBox(height: 48),
                  preview,
                ],
                SizedBox(height: wide ? 96 : 56),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy({required this.onGetStarted, required this.onSignIn});

  final VoidCallback onGetStarted;
  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final wide = _isWide(context);
    final headline = TextStyle(
      color: Colors.white,
      fontSize: wide ? 64 : 40,
      height: 1.08,
      fontWeight: FontWeight.w800,
      letterSpacing: _tracking(context, wide ? -2 : -1.2),
    );
    return _Reveal(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _GlassPill(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: _green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    l.welcomeEyebrow,
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
          const SizedBox(height: 24),
          Text(l.welcomeHeadlineLead, style: headline),
          ShaderMask(
            shaderCallback: const LinearGradient(
              colors: _accentText,
            ).createShader,
            child: Text(l.welcomeHeadlineAccent, style: headline),
          ),
          const SizedBox(height: 22),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Text(
              l.welcomeSubhead,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.74),
                fontSize: wide ? 19 : 16.5,
                height: 1.55,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _GradientButton(
                buttonKey: const Key('welcome-get-started'),
                label: l.welcomeGetStarted,
                onPressed: onGetStarted,
              ),
              OutlinedButton(
                key: const Key('welcome-have-account'),
                onPressed: onSignIn,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 18,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: Text(l.welcomeHaveAccount),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Wrap(
            spacing: 20,
            runSpacing: 10,
            children: [
              _Trust(Icons.wifi_off_rounded, l.welcomeTrustOffline),
              _Trust(Icons.devices_rounded, l.welcomeTrustPlatforms),
              _Trust(Icons.translate_rounded, l.welcomeTrustLanguages),
              _Trust(Icons.credit_card_off_rounded, l.welcomeTrustNoCard),
            ],
          ),
        ],
      ),
    );
  }
}

class _Trust extends StatelessWidget {
  const _Trust(this.icon, this.label);

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 16, color: Colors.white.withValues(alpha: 0.6)),
      const SizedBox(width: 6),
      Text(
        label,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.7),
          fontSize: 13.5,
        ),
      ),
    ],
  );
}

class _GlassPill extends StatelessWidget {
  const _GlassPill({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.07),
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
    ),
    child: child,
  );
}

/// The hero's backdrop: night blue, soft aurora glows and a dot grid that
/// fades out towards the edges.
class _NightSky extends StatelessWidget {
  const _NightSky();

  @override
  Widget build(BuildContext context) => const DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [_night, _nightBlue],
      ),
    ),
    child: Stack(
      children: [
        _Glow(alignment: Alignment(-1.1, -0.9), color: TaxcyColors.blue600),
        _Glow(alignment: Alignment(1.1, -0.2), color: _violet),
        _Glow(alignment: Alignment(0.2, 1.3), color: _cyan, strength: 0.28),
        Positioned.fill(child: CustomPaint(painter: _DotGridPainter())),
      ],
    ),
  );
}

class _Glow extends StatelessWidget {
  const _Glow({
    required this.alignment,
    required this.color,
    this.strength = 0.45,
  });

  final Alignment alignment;
  final Color color;
  final double strength;

  @override
  Widget build(BuildContext context) => Positioned.fill(
    child: DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: alignment,
          radius: 0.9,
          colors: [
            color.withValues(alpha: strength),
            color.withValues(alpha: 0),
          ],
        ),
      ),
    ),
  );
}

class _DotGridPainter extends CustomPainter {
  const _DotGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const gap = 28.0;
    final centre = Offset(size.width * 0.5, size.height * 0.35);
    final reach = size.longestSide * 0.7;
    final paint = Paint();
    for (var y = gap / 2; y < size.height; y += gap) {
      for (var x = gap / 2; x < size.width; x += gap) {
        final fade = 1 - ((Offset(x, y) - centre).distance / reach);
        if (fade <= 0) continue;
        paint.color = Colors.white.withValues(alpha: 0.13 * fade);
        canvas.drawCircle(Offset(x, y), 1.1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DotGridPainter oldDelegate) => false;
}

/// The owner's day at a glance: the numbers, a mileage chart with a dip, and
/// the three kinds of things Fleet Sarthi flags.
class _TodayMock extends StatelessWidget {
  const _TodayMock();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _MockHeader(
          title: l.welcomeMockToday,
          trailing: _Tag(l.welcomeMockLive, _green),
        ),
        Row(
          children: [
            Expanded(child: _Stat('12', l.welcomeMockTrips)),
            const SizedBox(width: 8),
            Expanded(child: _Stat('1,486', l.welcomeMockKm)),
            const SizedBox(width: 8),
            Expanded(child: _Stat('₹18,400', l.welcomeMockCash)),
          ],
        ),
        const SizedBox(height: 14),
        const _MileageChart(),
        const SizedBox(height: 12),
        _Event(
          icon: Icons.local_gas_station_rounded,
          color: _amber,
          title: l.welcomeMockFuelTitle,
          body: l.welcomeMockFuelBody,
        ),
        _Event(
          icon: Icons.route_rounded,
          color: _green,
          title: l.welcomeMockGpsTitle,
          body: l.welcomeMockGpsBody,
        ),
        _Event(
          icon: Icons.account_balance_wallet_rounded,
          color: TaxcyColors.blue600,
          title: l.welcomeMockSettleTitle,
          body: l.welcomeMockSettleBody,
          trailing: '₹3,560',
        ),
      ],
    );
  }
}

class _MileageChart extends StatelessWidget {
  const _MileageChart();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
    decoration: BoxDecoration(
      color: TaxcyColors.background,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.welcomeMockMileage,
          style: const TextStyle(
            color: TaxcyColors.muted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        const SizedBox(
          height: 58,
          width: double.infinity,
          child: CustomPaint(painter: _MileagePainter()),
        ),
      ],
    ),
  );
}

class _Stat extends StatelessWidget {
  const _Stat(this.value, this.label);

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
            style: const TextStyle(
              color: TaxcyColors.blue950,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: TaxcyColors.muted, fontSize: 11.5),
        ),
      ],
    ),
  );
}

class _Event extends StatelessWidget {
  const _Event({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
    this.trailing,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String body;
  final String? trailing;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: TaxcyColors.ink,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                body,
                style: const TextStyle(
                  color: TaxcyColors.muted,
                  fontSize: 12.5,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        if (trailing case final trailing?) ...[
          const SizedBox(width: 8),
          Text(
            trailing,
            style: const TextStyle(
              color: TaxcyColors.blue700,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ],
    ),
  );
}

/// Eight fills' mileage around a dashed baseline, the last one dipping well
/// below it (marked in amber).
class _MileagePainter extends CustomPainter {
  const _MileagePainter();

  static const _values = [11.6, 11.9, 11.4, 11.8, 12.0, 11.5, 11.7, 9.1];
  static const _low = 8.5;
  static const _high = 12.5;

  @override
  void paint(Canvas canvas, Size size) {
    Offset at(int i) => Offset(
      size.width * i / (_values.length - 1),
      size.height * (1 - (_values[i] - _low) / (_high - _low)),
    );

    final baselineY = size.height * (1 - (11.7 - _low) / (_high - _low));
    final dash = Paint()
      ..color = TaxcyColors.blue300
      ..strokeWidth = 1;
    for (var x = 0.0; x < size.width; x += 8) {
      canvas.drawLine(
        Offset(x, baselineY),
        Offset(math.min(x + 4, size.width), baselineY),
        dash,
      );
    }

    final line = Path()..moveTo(at(0).dx, at(0).dy);
    for (var i = 1; i < _values.length; i++) {
      final a = at(i - 1);
      final b = at(i);
      final midX = (a.dx + b.dx) / 2;
      line.cubicTo(midX, a.dy, midX, b.dy, b.dx, b.dy);
    }
    final area = Path.from(line)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas
      ..drawPath(
        area,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              TaxcyColors.blue600.withValues(alpha: 0.22),
              TaxcyColors.blue600.withValues(alpha: 0),
            ],
          ).createShader(Offset.zero & size),
      )
      ..drawPath(
        line,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4
          ..strokeCap = StrokeCap.round
          ..shader = _brand.createShader(Offset.zero & size),
      );

    final dip = at(_values.length - 1);
    canvas
      ..drawCircle(dip, 7, Paint()..color = _amber.withValues(alpha: 0.25))
      ..drawCircle(dip, 4, Paint()..color = _amber);
  }

  @override
  bool shouldRepaint(_MileagePainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// Light sections

class _MadeFor extends StatelessWidget {
  const _MadeFor();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: TaxcyColors.border)),
      ),
      child: _Content(
        vertical: 28,
        child: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: [
            Text(
              l.welcomeBuiltFor,
              style: const TextStyle(
                color: TaxcyColors.muted,
                fontWeight: FontWeight.w600,
              ),
            ),
            _Chip(Icons.person_pin_circle_rounded, l.welcomeForDco),
            _Chip(Icons.directions_car_filled_rounded, l.welcomeForSmallFleets),
            _Chip(Icons.alt_route_rounded, l.welcomeForIntercity),
            _Chip(Icons.flight_takeoff_rounded, l.welcomeForLocal),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(this.icon, this.label);

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
    decoration: BoxDecoration(
      color: TaxcyColors.blue50,
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: TaxcyColors.blue100),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: TaxcyColors.blue700),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            label,
            style: const TextStyle(
              color: TaxcyColors.blue900,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}

/// A white card that lifts a little under the mouse.
class _LiftCard extends StatefulWidget {
  const _LiftCard({required this.child});

  final Widget child;

  @override
  State<_LiftCard> createState() => _LiftCardState();
}

class _LiftCardState extends State<_LiftCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _hover = true),
    onExit: (_) => setState(() => _hover = false),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      transform: Matrix4.translationValues(0, _hover ? -4 : 0, 0),
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _hover ? TaxcyColors.blue200 : TaxcyColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: TaxcyColors.blue900.withValues(alpha: _hover ? 0.10 : 0.04),
            blurRadius: _hover ? 32 : 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: widget.child,
    ),
  );
}

class _IconCard extends StatelessWidget {
  const _IconCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => _LiftCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.18),
                color.withValues(alpha: 0.06),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color, size: 26),
        ),
        const SizedBox(height: 18),
        Text(
          title,
          style: const TextStyle(
            color: TaxcyColors.blue950,
            fontSize: 19,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          body,
          style: const TextStyle(
            color: TaxcyColors.muted,
            fontSize: 15,
            height: 1.55,
          ),
        ),
      ],
    ),
  );
}

class _Features extends StatelessWidget {
  const _Features();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [TaxcyColors.background, TaxcyColors.blue50],
        ),
      ),
      child: _Content(
        child: Column(
          children: [
            _SectionHeader(
              kicker: l.welcomeFeaturesKicker,
              title: l.welcomeFeaturesTitle,
            ),
            const SizedBox(height: 44),
            _Grid(
              columns: 3,
              children: [
                _IconCard(
                  icon: Icons.insights_rounded,
                  color: TaxcyColors.blue600,
                  title: l.welcomeFeatureFuelTitle,
                  body: l.welcomeFeatureFuelBody,
                ),
                _IconCard(
                  icon: Icons.photo_camera_rounded,
                  color: _violet,
                  title: l.welcomeFeatureTripsTitle,
                  body: l.welcomeFeatureTripsBody,
                ),
                _IconCard(
                  icon: Icons.receipt_long_rounded,
                  color: _green,
                  title: l.welcomeFeatureSettleTitle,
                  body: l.welcomeFeatureSettleBody,
                ),
                _IconCard(
                  icon: Icons.verified_user_rounded,
                  color: _amber,
                  title: l.welcomeFeatureDocsTitle,
                  body: l.welcomeFeatureDocsBody,
                ),
                _IconCard(
                  icon: Icons.signal_wifi_off_rounded,
                  color: _cyan,
                  title: l.welcomeFeatureOfflineTitle,
                  body: l.welcomeFeatureOfflineBody,
                ),
                _IconCard(
                  icon: Icons.swap_horiz_rounded,
                  color: _rose,
                  title: l.welcomeFeatureDcoTitle,
                  body: l.welcomeFeatureDcoBody,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Steps extends StatelessWidget {
  const _Steps();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final steps = [
      (l.welcomeStep1Title, l.welcomeStep1Body),
      (l.welcomeStep2Title, l.welcomeStep2Body),
      (l.welcomeStep3Title, l.welcomeStep3Body),
    ];
    return ColoredBox(
      color: Colors.white,
      child: _Content(
        child: Column(
          children: [
            _SectionHeader(
              kicker: l.welcomeStepsKicker,
              title: l.welcomeStepsTitle,
            ),
            const SizedBox(height: 44),
            _Grid(
              columns: 3,
              children: [
                for (final (i, (title, body)) in steps.indexed)
                  _Step(number: i + 1, title: title, body: body),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.number, required this.title, required this.body});

  final int number;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              gradient: _brand,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$number',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    TaxcyColors.blue200,
                    TaxcyColors.blue200.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 18),
      Text(
        title,
        style: const TextStyle(
          color: TaxcyColors.blue950,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        body,
        style: const TextStyle(
          color: TaxcyColors.muted,
          fontSize: 15,
          height: 1.55,
        ),
      ),
    ],
  );
}

class _Audiences extends StatelessWidget {
  const _Audiences();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return _Content(
      child: _Grid(
        columns: 2,
        children: [
          _AudienceCard(
            dark: true,
            icon: Icons.dashboard_rounded,
            title: l.welcomeOwnersTitle,
            points: [
              l.welcomeOwners1,
              l.welcomeOwners2,
              l.welcomeOwners3,
              l.welcomeOwners4,
            ],
          ),
          _AudienceCard(
            dark: false,
            icon: Icons.drive_eta_rounded,
            title: l.welcomeDriversTitle,
            points: [
              l.welcomeDrivers1,
              l.welcomeDrivers2,
              l.welcomeDrivers3,
              l.welcomeDrivers4,
            ],
          ),
        ],
      ),
    );
  }
}

class _AudienceCard extends StatelessWidget {
  const _AudienceCard({
    required this.dark,
    required this.icon,
    required this.title,
    required this.points,
  });

  final bool dark;
  final IconData icon;
  final String title;
  final List<String> points;

  @override
  Widget build(BuildContext context) {
    final ink = dark ? Colors.white : TaxcyColors.blue950;
    final soft = dark
        ? Colors.white.withValues(alpha: 0.8)
        : TaxcyColors.blue900.withValues(alpha: 0.85);
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: dark
              ? const [_nightBlue, TaxcyColors.blue800]
              : const [Colors.white, TaxcyColors.blue100],
        ),
        borderRadius: BorderRadius.circular(28),
        border: dark ? null : Border.all(color: TaxcyColors.blue100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: dark ? _accentText.first : TaxcyColors.blue700),
          const SizedBox(height: 14),
          Text(
            title,
            style: TextStyle(
              color: ink,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: _tracking(context, -0.6),
            ),
          ),
          const SizedBox(height: 18),
          for (final point in points)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 20,
                    color: dark ? _cyan : _green,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      point,
                      style: TextStyle(
                        color: soft,
                        fontSize: 15.5,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Faq extends StatelessWidget {
  const _Faq();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final items = [
      (l.welcomeFaqOfflineQ, l.welcomeFaqOfflineA),
      (l.welcomeFaqDcoQ, l.welcomeFaqDcoA),
      (l.welcomeFaqPrivacyQ, l.welcomeFaqPrivacyA),
      (l.welcomeFaqPhoneQ, l.welcomeFaqPhoneA),
      (l.welcomeFaqLanguageQ, l.welcomeFaqLanguageA),
    ];
    return _Content(
      vertical: 24,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 780),
        child: Column(
          children: [
            _SectionHeader(kicker: 'FAQ', title: l.welcomeFaqTitle),
            const SizedBox(height: 32),
            for (final (question, answer) in items)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: TaxcyColors.border),
                ),
                child: Theme(
                  data: Theme.of(
                    context,
                  ).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    shape: const RoundedRectangleBorder(),
                    tilePadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 4,
                    ),
                    childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
                    expandedAlignment: Alignment.centerLeft,
                    iconColor: TaxcyColors.blue700,
                    title: Text(
                      question,
                      style: const TextStyle(
                        color: TaxcyColors.blue950,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    children: [
                      Text(
                        answer,
                        style: const TextStyle(
                          color: TaxcyColors.muted,
                          fontSize: 15,
                          height: 1.55,
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
}

class _FinalCall extends StatelessWidget {
  const _FinalCall({required this.onGetStarted});

  final VoidCallback onGetStarted;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final wide = _isWide(context);
    return _Content(
      vertical: 56,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          children: [
            const Positioned.fill(child: _NightSky()),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: wide ? 64 : 24,
                vertical: wide ? 72 : 48,
              ),
              child: Center(
                child: Column(
                  children: [
                    Text(
                      l.welcomeFinalTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: wide ? 46 : 30,
                        height: 1.1,
                        fontWeight: FontWeight.w800,
                        letterSpacing: _tracking(context, -1.2),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      l.welcomeFinalBody,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 17,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 30),
                    _GradientButton(
                      buttonKey: const Key('welcome-final-cta'),
                      label: l.welcomeGetStarted,
                      onPressed: onGetStarted,
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
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) => _Content(
    vertical: 32,
    child: Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 24,
      runSpacing: 12,
      children: [
        const _Logo(light: false),
        Text(
          '${context.l10n.welcomeFooter}  ·  © ${DateTime.now().year}',
          style: const TextStyle(color: TaxcyColors.muted, fontSize: 13.5),
        ),
      ],
    ),
  );
}

part of 'welcome_screen.dart';

/// The welcome in the installed app: one screen with the name, the promise,
/// three things it does and the two ways in. The full landing page is for the
/// web, where prospects arrive from a shared link.
class _AppWelcome extends StatelessWidget {
  const _AppWelcome({required this.onGetStarted, required this.onSignIn});

  final VoidCallback onGetStarted;
  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final headline = TextStyle(
      color: Colors.white,
      fontSize: 32,
      height: 1.12,
      fontWeight: FontWeight.w800,
      letterSpacing: _tracking(context, -1),
    );
    return Scaffold(
      key: const Key('welcome-app'),
      backgroundColor: _night,
      body: Stack(
        children: [
          const Positioned.fill(child: _NightSky()),
          SafeArea(
            child: LayoutBuilder(
              // Scrolls only when the screen is too short (small phones, big
              // text); otherwise the buttons sit at the bottom.
              builder: (context, constraints) => SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 32,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Align(
                          alignment: Alignment.centerRight,
                          child: LanguageButton(color: Colors.white),
                        ),
                        const Spacer(),
                        const _Reveal(child: _AppMark()),
                        const SizedBox(height: 28),
                        _Reveal(
                          delay: 0.1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l.welcomeHeadlineLead, style: headline),
                              ShaderMask(
                                shaderCallback: const LinearGradient(
                                  colors: _accentText,
                                ).createShader,
                                child: Text(
                                  l.welcomeHeadlineAccent,
                                  style: headline,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                l.welcomeEyebrow,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 15,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                        _Reveal(
                          delay: 0.2,
                          child: Column(
                            children: [
                              _AppPoint(
                                Icons.local_gas_station_rounded,
                                _amber,
                                l.welcomeFeatureFuelTitle,
                              ),
                              _AppPoint(
                                Icons.photo_camera_rounded,
                                _accentText[1],
                                l.welcomeFeatureTripsTitle,
                              ),
                              _AppPoint(
                                Icons.account_balance_wallet_rounded,
                                _green,
                                l.welcomeFeatureSettleTitle,
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        const SizedBox(height: 28),
                        _GradientButton(
                          buttonKey: const Key('welcome-get-started'),
                          label: l.welcomeGetStarted,
                          onPressed: onGetStarted,
                          expand: true,
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          key: const Key('welcome-sign-in'),
                          onPressed: onSignIn,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                            shape: const StadiumBorder(),
                            minimumSize: const Size.fromHeight(54),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          child: Text(l.welcomeHaveAccount),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'v$appVersion',
                          key: const Key('welcome-version'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The logo tile and name, larger than the landing page's header.
class _AppMark extends StatelessWidget {
  const _AppMark();

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          gradient: _brand,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: _violet.withValues(alpha: 0.45),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Icon(Icons.local_taxi, color: Colors.white, size: 28),
      ),
      const SizedBox(width: 14),
      Flexible(
        child: Text(
          context.l10n.appTitle,
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: _tracking(context, -0.5),
          ),
        ),
      ),
    ],
  );
}

/// One thing the app does, on a frosted line.
class _AppPoint extends StatelessWidget {
  const _AppPoint(this.icon, this.color, this.label);

  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
    ),
    child: Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}

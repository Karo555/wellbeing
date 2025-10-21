import 'package:flutter/material.dart';

void main() {
  runApp(const WellbeingApp());
}

class WellbeingApp extends StatelessWidget {
  const WellbeingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wellbeing',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6C63FF)),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int streak = 0;
  int currentTipIndex = 0;
  bool showRecommendation = true;
  int _selectedIndex = 0;

  final List<String> tips = const [
    'Take 5 slow breaths. Inhale for 4, exhale for 6.',
    'Drink a glass of water and stretch your neck and shoulders.',
    'Write down one thing you’re grateful for today.',
    'Take a 1‑minute walk and notice three things you can hear.',
    'Relax your jaw and drop your shoulders for 10 seconds.',
  ];

  final List<String> tipExplanations = const [
    'Slow, extended exhales activate the parasympathetic nervous system and help the body relax.',
    'Hydration and gentle movement reduce tension and improve focus in minutes.',
    'Gratitude shifts attention toward positives and is linked to improved mood.',
    'Brief walks and sound awareness reset attention and lower stress.',
    'Releasing jaw and shoulder tension signals safety and calms the nervous system.',
  ];

  void _doNow() {
    setState(() {
      streak += 1;
      showRecommendation = false;
    });
    // Optional: Add a subtle feedback such as a SnackBar.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Nice! Streak is now $streak'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _swapTip() {
    setState(() {
      currentTipIndex = (currentTipIndex + 1) % tips.length;
    });
  }

  Widget _buildTabBody(BuildContext context) {
    switch (_selectedIndex) {
      case 0:
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                'Welcome',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'A gentle place to check in.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.9),
                    ),
              ),
              const SizedBox(height: 24),
              if (showRecommendation)
                _DailyRecommendationCard(
                  tip: tips[currentTipIndex],
                  streak: streak,
                  onDoNow: _doNow,
                  onSwap: _swapTip,
                  onWhyThis: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (context) {
                        final theme = Theme.of(context);
                        final scheme = theme.colorScheme;
                        return SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: Container(
                                    width: 36,
                                    height: 4,
                                    margin: const EdgeInsets.only(bottom: 12),
                                    decoration: BoxDecoration(
                                      color: scheme.onSurfaceVariant.withOpacity(0.4),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.info_outline, color: scheme.primary),
                                    const SizedBox(width: 8),
                                    Text('Why this?', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  tipExplanations[currentTipIndex],
                                  style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurface.withOpacity(0.9)),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'These suggestions are simple, low-effort actions shown to help in the moment.',
                                  style: theme.textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              const Spacer(),
              FilledButton(
                onPressed: () {},
                child: const Text('Start a 1‑minute check‑in'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _openBreathe,
                icon: const Icon(Icons.self_improvement),
                label: const Text('Breathe (2 min)'),
              ),
            ],
          ),
        );
      case 1:
        return const Center(child: Text('Insights coming soon'));
      case 2:
        return const Center(child: Text('Me coming soon'));
      default:
        return const SizedBox.shrink();
    }
  }

  void _openBreathe() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const BreatheScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          _AnimatedGradientBackground(
            colors: [
              scheme.primary.withOpacity(0.6),
              scheme.tertiary.withOpacity(0.6),
              scheme.secondary.withOpacity(0.6),
            ],
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 900; // desktop/tablet
                final isMedium = constraints.maxWidth >= 600 && constraints.maxWidth < 900; // large phones/tablets
                final destinations = const [
                  NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
                  NavigationDestination(icon: Icon(Icons.insights_outlined), selectedIcon: Icon(Icons.insights), label: 'Insights'),
                  NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Me'),
                ];

                if (isWide) {
                  return Row(
                    children: [
                      NavigationRail(
                        selectedIndex: _selectedIndex,
                        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
                        labelType: NavigationRailLabelType.all,
                        destinations: const [
                          NavigationRailDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: Text('Home')),
                          NavigationRailDestination(icon: Icon(Icons.insights_outlined), selectedIcon: Icon(Icons.insights), label: Text('Insights')),
                          NavigationRailDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: Text('Me')),
                        ],
                      ),
                      const VerticalDivider(width: 1),
                      Expanded(child: _buildTabBody(context)),
                    ],
                  );
                }

                if (isMedium) {
                  return Column(
                    children: [
                      Expanded(child: _buildTabBody(context)),
                      NavigationBar(
                        selectedIndex: _selectedIndex,
                        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
                        destinations: destinations,
                      ),
                    ],
                  );
                }

                return Column(
                  children: [
                    Expanded(child: _buildTabBody(context)),
                    NavigationBar(
                      selectedIndex: _selectedIndex,
                      onDestinationSelected: (i) => setState(() => _selectedIndex = i),
                      destinations: destinations,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedGradientBackground extends StatefulWidget {
  const _AnimatedGradientBackground({
    required this.colors,
    this.duration = const Duration(seconds: 8),
    super.key,
  });

  final List<Color> colors;
  final Duration duration;

  @override
  State<_AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<_AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: widget.duration)..repeat(reverse: true);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        // Animate the alignment and color stops subtly for a soothing effect.
        final t = _animation.value;
        final beginAlignment = Alignment(-1.0 + t * 0.2, -1.0 + t * 0.2);
        final endAlignment = Alignment(1.0 - t * 0.2, 1.0 - t * 0.2);

        final colors = List<Color>.generate(widget.colors.length, (i) {
          final base = widget.colors[i];
          final hsl = HSLColor.fromColor(base);
          // Slightly shift lightness back and forth.
          final lightness =
              (hsl.lightness * (0.95 + 0.1 * (0.5 - (t - 0.5).abs()))).clamp(0.0, 1.0);
          return hsl.withLightness(lightness).toColor();
        });

        final stops = List<double>.generate(colors.length, (i) => i / (colors.length - 1))
            .map((s) => (s + (t - 0.5) * 0.06).clamp(0.0, 1.0))
            .cast<double>()
            .toList();

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: beginAlignment,
              end: endAlignment,
              colors: colors,
              stops: stops,
            ),
          ),
        );
      },
    );
  }
}

class _DailyRecommendationCard extends StatelessWidget {
  const _DailyRecommendationCard({
    required this.tip,
    required this.streak,
    required this.onDoNow,
    required this.onSwap,
    required this.onWhyThis,
  });

  final String tip;
  final int streak;
  final VoidCallback onDoNow;
  final VoidCallback onSwap;
  final VoidCallback onWhyThis;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withOpacity(0.2),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: scheme.primary.withOpacity(0.15)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: scheme.onPrimaryContainer.withOpacity(0.9)),
              const SizedBox(width: 8),
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: Text(
                        'Daily Recommendation',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: scheme.onPrimaryContainer,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: onWhyThis,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        foregroundColor: scheme.onPrimaryContainer.withOpacity(0.9),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        minimumSize: const Size(0, 0),
                      ),
                      icon: const Icon(Icons.info_outline, size: 18),
                      label: const Text('Why this?'),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: scheme.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.local_fire_department, size: 16),
                    const SizedBox(width: 6),
                    Text('$streak', style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            tip,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: scheme.onPrimaryContainer.withOpacity(0.95),
            ),
            softWrap: true,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              FilledButton.icon(
                onPressed: onDoNow,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Do now'),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: onSwap,
                icon: const Icon(Icons.swap_horiz),
                label: const Text('Swap'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BreatheScreen extends StatefulWidget {
  const BreatheScreen({super.key});

  @override
  State<BreatheScreen> createState() => _BreatheScreenState();
}

class _BreatheScreenState extends State<BreatheScreen> with TickerProviderStateMixin {
  late final AnimationController _phaseController; // drives one 16s box cycle
  late final AnimationController _sessionController; // counts down 120s
  late final Animation<double> _scale; // circle scale

  static const int inhale = 4;
  static const int hold1 = 4;
  static const int exhale = 4;
  static const int hold2 = 4;
  static const int cycleSeconds = inhale + hold1 + exhale + hold2; // 16
  static const int sessionSeconds = 120; // 2 minutes

  String _phaseLabel = 'Get ready';

  @override
  void initState() {
    super.initState();
    _phaseController = AnimationController(vsync: this, duration: const Duration(seconds: cycleSeconds));
    _sessionController = AnimationController(vsync: this, duration: const Duration(seconds: sessionSeconds));

    // Scale anim: grow on inhale, hold, shrink on exhale, hold
    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.7, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)),
        weight: inhale.toDouble(),
      ),
      TweenSequenceItem(
        tween: ConstantTween(1.0),
        weight: hold1.toDouble(),
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.7).chain(CurveTween(curve: Curves.easeInOut)),
        weight: exhale.toDouble(),
      ),
      TweenSequenceItem(
        tween: ConstantTween(0.7),
        weight: hold2.toDouble(),
      ),
    ]).animate(_phaseController);

    _phaseController.addListener(_updatePhaseLabel);
    _phaseController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _phaseController.forward(from: 0); // loop the breathing cycle
      }
    });

    _start();
  }

  void _start() {
    _phaseController.forward(from: 0);
    _sessionController.reverse(from: 1.0); // counts down from full session
  }

  void _toggle() {
    if (_phaseController.isAnimating) {
      _phaseController.stop();
      _sessionController.stop();
    } else {
      _phaseController.forward();
      _sessionController.reverse();
    }
  }

  void _reset() {
    _phaseController.reset();
    _sessionController.reset();
    setState(() {
      _phaseLabel = 'Get ready';
    });
  }

  void _updatePhaseLabel() {
    final t = _phaseController.value * cycleSeconds; // 0..16
    String label;
    if (t < inhale) {
      label = 'Inhale';
    } else if (t < inhale + hold1) {
      label = 'Hold';
    } else if (t < inhale + hold1 + exhale) {
      label = 'Exhale';
    } else {
      label = 'Hold';
    }
    if (label != _phaseLabel) {
      setState(() => _phaseLabel = label);
    }
  }

  String _remainingText() {
    final remaining = (_sessionController.duration!.inSeconds * _sessionController.value).round();
    final m = remaining ~/ 60;
    final s = remaining % 60;
    return '${m.toString().padLeft(1, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _phaseController.dispose();
    _sessionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Breathe'),
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Reuse a simple gradient background for calmness
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  scheme.primary.withOpacity(0.25),
                  scheme.secondary.withOpacity(0.25),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: AnimatedBuilder(
                animation: Listenable.merge([_phaseController, _sessionController]),
                builder: (context, _) {
                  final running = _phaseController.isAnimating && _sessionController.isAnimating;
                  final finished = _sessionController.isDismissed; // reached 0
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        finished ? 'Done' : _phaseLabel,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: scheme.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: 220,
                        height: 220,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 220,
                              height: 220,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: scheme.primary.withOpacity(0.08),
                              ),
                            ),
                            ScaleTransition(
                              scale: _scale,
                              child: Container(
                                width: 160,
                                height: 160,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: scheme.primary.withOpacity(0.35),
                                  boxShadow: [
                                    BoxShadow(
                                      color: scheme.primary.withOpacity(0.25),
                                      blurRadius: 24,
                                      spreadRadius: 6,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        finished ? 'Great job' : _remainingText(),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: scheme.onSurface.withOpacity(0.9),
                            ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FilledButton.icon(
                            onPressed: finished ? _reset : _toggle,
                            icon: Icon(finished ? Icons.refresh : (running ? Icons.pause : Icons.play_arrow)),
                            label: Text(finished ? 'Reset' : (running ? 'Pause' : 'Start')),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton.icon(
                            onPressed: () => Navigator.of(context).maybePop(),
                            icon: const Icon(Icons.close),
                            label: const Text('Close'),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

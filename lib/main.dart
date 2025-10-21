import 'package:flutter/material.dart';
import 'dart:math' as math;

enum MomentType { breath, movement, gratitude, reflection, walk, stretch, other }

class Moment {
  Moment({
    required this.id,
    required this.date,
    required this.type,
    this.note,
    this.source,
  });

  final String id;
  final DateTime date;
  final MomentType type;
  final String? note;
  final String? source; // 'microFlow', 'breathe', 'manual'
}

void main() {
  runApp(const WellbeingApp());
}

class WellbeingApp extends StatelessWidget {
  const WellbeingApp({super.key});

  static final ValueNotifier<bool> _didOnboard = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _didOnboard,
      builder: (context, didOnboard, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Wellbeing',
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6C63FF)),
          ),
          home: didOnboard ? const HomeScreen() : OnboardingScreen(onFinish: () => _didOnboard.value = true),
        );
      },
    );
  }
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onFinish});
  final VoidCallback onFinish;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          _AnimatedGradientBackground(
            colors: [
              scheme.primary.withOpacity(0.5),
              scheme.secondary.withOpacity(0.5),
            ],
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child: _page == 0
                          ? _OnboardPage(
                              key: const ValueKey(0),
                              title: 'A gentle place to check in',
                              body: 'Stay for as long as you like. No countdowns, no pressure.',
                              icon: Icons.favorite_outline,
                            )
                          : _OnboardPage(
                              key: const ValueKey(1),
                              title: 'Tap the circle for another prompt',
                              body: 'When youre ready, tap the circle to gently change the prompt.',
                              icon: Icons.touch_app,
                            ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: _page == 0 ? null : () => setState(() => _page = 0),
                        child: const Text('Back'),
                      ),
                      FilledButton(
                        onPressed: () {
                          if (_page == 0) {
                            setState(() => _page = 1);
                          } else {
                            widget.onFinish();
                          }
                        },
                        child: Text(_page == 0 ? 'Next' : 'Get started'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardPage extends StatelessWidget {
  const _OnboardPage({super.key, required this.title, required this.body, required this.icon});
  final String title;
  final String body;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 72, color: scheme.primary),
        const SizedBox(height: 24),
        Text(title, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Text(
          body,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
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
  bool _firstConnectSession = true;

  final List<Moment> _moments = [];

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

  void _addMoment({required MomentType type, String? note, required String source}) {
    setState(() {
      _moments.insert(
        0,
        Moment(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          date: DateTime.now(),
          type: type,
          note: note,
          source: source,
        ),
      );
    });
  }

  MomentType _inferMomentTypeFromTip(String tip) {
    final t = tip.toLowerCase();
    if (t.contains('breath') || t.contains('breathe')) return MomentType.breath;
    if (t.contains('stretch')) return MomentType.stretch;
    if (t.contains('walk')) return MomentType.walk;
    if (t.contains('grateful') || t.contains('gratitude')) return MomentType.gratitude;
    return MomentType.reflection;
  }

  Future<void> _startMicroFlow() async {
    final duration = const Duration(seconds: 15);
    bool completed = false;

    await showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return _MicroFlowSheet(
          duration: duration,
          onCancel: () {
            Navigator.of(context).pop();
          },
          onComplete: () {
            completed = true;
            Navigator.of(context).pop();
          },
        );
      },
    );

    if (completed) {
      // Increment streak and hide recommendation with undo option
      setState(() {
        streak += 1;
        showRecommendation = false;
        _addMoment(type: _inferMomentTypeFromTip(tips[currentTipIndex]), source: 'microFlow');
      });

      final messenger = ScaffoldMessenger.of(context);
      final undoController = messenger.showSnackBar(
        SnackBar(
          content: Text('Nice! Streak is now $streak'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              setState(() {
                streak = (streak - 1).clamp(0, 1 << 31);
                showRecommendation = true;
              });
            },
          ),
        ),
      );
      await undoController.closed; // no-op, just waits until it disappears
    }
  }

  void _doNow() {
    _startMicroFlow();
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
                onPressed: _openConnectCheckIn,
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
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Your scrapbook', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                  const Spacer(),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final note = await showDialog<String>(
                        context: context,
                        builder: (context) {
                          final controller = TextEditingController();
                          MomentType selected = MomentType.reflection;
                          return StatefulBuilder(
                            builder: (context, setDialogState) {
                              return AlertDialog(
                                title: const Text('Add a moment'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextField(
                                      controller: controller,
                                      decoration: const InputDecoration(hintText: 'Add a few words (optional)'),
                                    ),
                                    const SizedBox(height: 12),
                                    DropdownButton<MomentType>(
                                      value: selected,
                                      onChanged: (v) {
                                        if (v != null) {
                                          setDialogState(() {
                                            selected = v;
                                          });
                                        }
                                      },
                                      items: const [
                                        DropdownMenuItem(value: MomentType.breath, child: Text('Breath')),
                                        DropdownMenuItem(value: MomentType.movement, child: Text('Movement')),
                                        DropdownMenuItem(value: MomentType.gratitude, child: Text('Gratitude')),
                                        DropdownMenuItem(value: MomentType.reflection, child: Text('Reflection')),
                                        DropdownMenuItem(value: MomentType.walk, child: Text('Walk')),
                                        DropdownMenuItem(value: MomentType.stretch, child: Text('Stretch')),
                                        DropdownMenuItem(value: MomentType.other, child: Text('Other')),
                                      ],
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                                  FilledButton(onPressed: () => Navigator.pop(context, '${selected.index}|${controller.text}'), child: const Text('Add')),
                                ],
                              );
                            },
                          );
                        },
                      );
                      if (note != null) {
                        final parts = note.split('|');
                        final typeIndex = int.tryParse(parts.first) ?? MomentType.reflection.index;
                        final type = MomentType.values[typeIndex];
                        final text = parts.length > 1 ? parts.sublist(1).join('|') : null;
                        _addMoment(type: type, note: (text?.isEmpty ?? true) ? null : text, source: 'manual');
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add moment'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _moments.isEmpty
                    ? Center(
                        child: Text(
                          'A calm place to collect small moments you chose care.',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.separated(
                        itemCount: _moments.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final m = _moments[index];
                          return _MomentCard(moment: m);
                        },
                      ),
              ),
            ],
          ),
        );
      case 2:
        return const Center(child: Text('Me coming soon'));
      default:
        return const SizedBox.shrink();
    }
  }

  void _openBreathe() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const BreatheScreen()),
    );
    if (result == 'breatheCompleted') {
      _addMoment(type: MomentType.breath, source: 'breathe');
    }
  }

  void _openConnectCheckIn() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => ConnectCheckInScreen(showFirstSessionHints: _firstConnectSession)),
    );
    if (mounted) {
      setState(() {
        _firstConnectSession = false;
      });
      if (result == 'connectSaved') {
        _addMoment(type: MomentType.reflection, source: 'manual');
      }
    }
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

class _MicroFlowSheet extends StatefulWidget {
  const _MicroFlowSheet({
    required this.duration,
    required this.onCancel,
    required this.onComplete,
  });

  final Duration duration;
  final VoidCallback onCancel;
  final VoidCallback onComplete;

  @override
  State<_MicroFlowSheet> createState() => _MicroFlowSheetState();
}

class _MicroFlowSheetState extends State<_MicroFlowSheet> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onComplete();
        }
      })
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _remaining() {
    final total = widget.duration.inSeconds;
    final left = (total * (1.0 - _controller.value)).ceil();
    final s = left % 60;
    return '00:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: scheme.onSurfaceVariant.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'Take a moment',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return Column(
                  children: [
                    SizedBox(
                      width: 140,
                      height: 140,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: _controller.value,
                            strokeWidth: 8,
                            backgroundColor: scheme.primary.withOpacity(0.15),
                            valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
                          ),
                          Text(_remaining(), style: theme.textTheme.titleLarge),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Follow the tip for about 15 seconds. You can finish early or cancel.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: widget.onCancel,
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: widget.onComplete,
                  child: const Text("I'm done"),
                ),
              ],
            ),
          ],
        ),
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
  bool _reported = false;

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
      _reported = false;
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

                  if (finished && !_reported) {
                    _reported = true;
                    // Notify parent to record a moment
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      final ctx = context;
                      if (Navigator.of(ctx).canPop()) {
                        Navigator.of(ctx).pop('breatheCompleted');
                      }
                    });
                  }

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

class _MomentCard extends StatelessWidget {
  const _MomentCard({required this.moment});

  final Moment moment;

  IconData _iconFor(MomentType type) {
    switch (type) {
      case MomentType.breath:
        return Icons.self_improvement;
      case MomentType.movement:
        return Icons.directions_run;
      case MomentType.gratitude:
        return Icons.favorite_border;
      case MomentType.reflection:
        return Icons.edit_note;
      case MomentType.walk:
        return Icons.directions_walk;
      case MomentType.stretch:
        return Icons.accessibility_new;
      case MomentType.other:
        return Icons.blur_on;
    }
  }

  String _titleFor(MomentType type) {
    switch (type) {
      case MomentType.breath:
        return 'You took a breathing break';
      case MomentType.movement:
        return 'You moved your body';
      case MomentType.gratitude:
        return 'You wrote a gratitude note';
      case MomentType.reflection:
        return 'You took a mindful moment';
      case MomentType.walk:
        return 'You took a short walk';
      case MomentType.stretch:
        return 'You stretched a bit';
      case MomentType.other:
        return 'You chose care';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: scheme.primary.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 6)),
        ],
        border: Border.all(color: scheme.outlineVariant.withOpacity(0.5)),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_iconFor(moment.type), color: scheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_titleFor(moment.type), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                if ((moment.note ?? '').isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(moment.note!, style: theme.textTheme.bodyMedium),
                ],
                const SizedBox(height: 6),
                Text(
                  _friendlyTime(moment.date),
                  style: theme.textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _friendlyTime(DateTime dt) {
    final now = DateTime.now();
    final difference = now.difference(dt);
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes} min ago';
    if (difference.inHours < 24) return '${difference.inHours} hrs ago';
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }
}

class ConnectCheckInScreen extends StatefulWidget {
  const ConnectCheckInScreen({super.key, this.showFirstSessionHints = false});
  final bool showFirstSessionHints;

  @override
  State<ConnectCheckInScreen> createState() => _ConnectCheckInScreenState();
}

class _ConnectCheckInScreenState extends State<ConnectCheckInScreen> with TickerProviderStateMixin {
  late final AnimationController _promptController; // crossfade prompt
  late final AnimationController _pulseController; // added pulse animation controller
  late final Animation<double> _pulse;
  late final AnimationController _rippleController; // tap ripple
  late final Animation<double> _ripple; // 0..1 for ripple radius
  late final AnimationController _haloController; // ambient halo drift
  late final Animation<double> _halo; // 0..1 for color drift
  late final AnimationController _arrivalController;

  int _promptIndex = 0;
  int _softProgress = 0;

  // Added fields per instructions:
  bool _showOneTimeHint = true; // fades once per session
  bool _reduceMotionPref = false; // user preference via options
  bool _onePromptOnly = false; // if true, keep repeating the same prompt
  bool _autoAdvance = false; // optional, off by default
  String? _moreDetail; // revealed on double-tap

  static const List<String> prompts = [
    'Feel your feet on the ground.',
    'Soften your jaw.',
    'Notice your breath.',
    'Let your shoulders drop.',
  ];

  @override
  void initState() {
    super.initState();

    _promptController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _promptController.forward(from: 0);
    _showOneTimeHint = widget.showFirstSessionHints;

    // Initialize pulse controller and animation
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 10))
      ..repeat(reverse: true);
    _pulse = Tween(begin: 0.95, end: 1.05).chain(CurveTween(curve: Curves.easeInOut)).animate(_pulseController);

    _rippleController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _ripple = CurvedAnimation(parent: _rippleController, curve: Curves.easeOutCubic);

    // Ambient halo drift (very slow)
    _haloController = AnimationController(vsync: this, duration: const Duration(seconds: 40))..repeat(reverse: true);
    _halo = CurvedAnimation(parent: _haloController, curve: Curves.easeInOut);

    _arrivalController = AnimationController(vsync: this, duration: const Duration(seconds: 7));
    _arrivalController.forward();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _arrivalController.reverse();
      }
    });

    _arrivalController.addStatusListener((status) {
      if (status == AnimationStatus.dismissed && mounted) {
        setState(() => _showOneTimeHint = false);
      }
    });
  }

  @override
  void dispose() {
    _promptController.dispose();
    _pulseController.dispose();
    _rippleController.dispose();
    _haloController.dispose();
    _arrivalController.dispose();
    super.dispose();
  }

  void _nextPrompt() {
    // Crossfade to next prompt and increment soft progress up to 5
    _rippleController.forward(from: 0); // start ripple
    _promptController.reverse(from: 1.0).whenComplete(() {
      if (!mounted) return;
      setState(() {
        if (!_onePromptOnly) {
          _promptIndex = (_promptIndex + 1) % prompts.length;
        }
        _softProgress = (_softProgress + 1).clamp(0, 5);
        _moreDetail = null; // reset any expanded detail
      });
      _promptController.forward(from: 0);
    });
  }

  void _openOptions() async {
    final result = await showModalBottomSheet<List<bool>>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        bool reduceMotion = _reduceMotionPref;
        bool onePromptOnly = _onePromptOnly;
        bool autoAdvance = _autoAdvance;
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
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
                          color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.tune, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 8),
                        Text('Options', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Reduce motion'),
                      subtitle: const Text('Minimize animations during the session'),
                      value: reduceMotion,
                      onChanged: (v) => setSheetState(() => reduceMotion = v),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('One prompt only'),
                      subtitle: const Text('Stay with a single prompt'),
                      value: onePromptOnly,
                      onChanged: (v) => setSheetState(() => onePromptOnly = v),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Auto-advance every 20s'),
                      subtitle: const Text('If enabled, prompts change gently on their own'),
                      value: autoAdvance,
                      onChanged: (v) => setSheetState(() => autoAdvance = v),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton(
                        onPressed: () => Navigator.pop(context, [reduceMotion, onePromptOnly, autoAdvance]),
                        child: const Text('Done'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (result != null && mounted) {
      setState(() {
        _reduceMotionPref = result[0];
        _onePromptOnly = result[1];
        _autoAdvance = result[2];
      });
    }
  }

  void _showExitSheet() async {
    final scheme = Theme.of(context).colorScheme;
    final result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        bool save = false;
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
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
                          color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.check_circle_outline, color: scheme.primary),
                        const SizedBox(width: 8),
                        Text('Thanks for taking a moment', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Save this moment'),
                      subtitle: const Text('Add it to your scrapbook'),
                      value: save,
                      onChanged: (v) => setSheetState(() => save = v ?? false),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Not now')),
                        const SizedBox(width: 8),
                        FilledButton(onPressed: () => Navigator.pop(context, save), child: const Text('Close')),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (!mounted) return;
    if (result == true) {
      // Notify parent via Navigator pop with a flag so Home can record a moment if desired in future
      Navigator.of(context).pop('connectSaved');
    } else {
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final media = MediaQuery.of(context);
    final reduceMotion = media.disableAnimations || _reduceMotionPref;

    if (_autoAdvance) {
      // schedule a gentle auto-advance every ~20s while this widget is visible
      Future.delayed(const Duration(seconds: 20), () {
        if (mounted && _autoAdvance) {
          _nextPrompt();
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: _showExitSheet,
            tooltip: 'Close',
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  scheme.primary.withOpacity(0.2),
                  scheme.secondary.withOpacity(0.2),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 180,
                    height: 180,
                    child: GestureDetector(
                      onTap: _nextPrompt,
                      onLongPress: _openOptions,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Soft progress segmented ring (up to 5 segments)
                          CustomPaint(
                            size: const Size(180, 180),
                            painter: _SoftProgressRing(
                              color: scheme.primary.withOpacity(0.18),
                              highlightColor: scheme.primary.withOpacity(0.40),
                              segments: 5,
                              filled: _softProgress,
                            ),
                          ),
                          // Ambient halo with very gentle brightness drift
                          AnimatedBuilder(
                            animation: _halo,
                            builder: (context, _) {
                              final brightness = 0.20 + 0.08 * _halo.value; // 0.20..0.28
                              return Container(
                                width: 160,
                                height: 160,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: scheme.primary.withOpacity(reduceMotion ? 0.24 : brightness),
                                  boxShadow: [
                                    BoxShadow(
                                      color: scheme.primary.withOpacity(0.12 + 0.06 * _halo.value),
                                      blurRadius: 24,
                                      spreadRadius: 6,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          // Tap ripple feedback
                          AnimatedBuilder(
                            animation: _ripple,
                            builder: (context, _) {
                              final v = _ripple.value;
                              return IgnorePointer(
                                child: Container(
                                  width: 140 + 60 * v,
                                  height: 140 + 60 * v,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: scheme.primary.withOpacity((1 - v) * 0.12),
                                  ),
                                ),
                              );
                            },
                          ),
                          // Calm inner circle with subtle pulse
                          ScaleTransition(
                            scale: reduceMotion ? const AlwaysStoppedAnimation(1.0) : _pulse,
                            child: Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.transparent,
                              ),
                            ),
                          ),
                          // Arrival hint overlay that fades away
                          FadeTransition(
                            opacity: _arrivalController,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(
                                'Take your time',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: scheme.onSurface.withOpacity(0.9),
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onDoubleTap: () {
                      setState(() {
                        _moreDetail = _moreDetail == null ? 'If you like, notice the weight of your heels.' : null;
                      });
                    },
                    child: FadeTransition(
                      opacity: _promptController.drive(CurveTween(curve: Curves.easeInOut)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          children: [
                            Text(
                              prompts[_promptIndex],
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: scheme.onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            if (_moreDetail != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                _moreDetail!,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Just notice. No need to change anything.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 12),
                  if (_showOneTimeHint) FadeTransition(
                    opacity: _arrivalController,
                    child: Text(
                      'Tap the circle when you’d like another prompt',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SoftProgressRing extends CustomPainter {
  _SoftProgressRing({
    required this.color,
    required this.highlightColor,
    required this.segments,
    required this.filled,
  });

  final Color color;
  final Color highlightColor;
  final int segments;
  final int filled;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final radius = size.width / 2 - 8; // padding
    final center = Offset(size.width / 2, size.height / 2);

    final arcAngle = 2 * math.pi / segments;
    const gapAngle = math.pi / 36; // 5 degrees gap

    for (var i = 0; i < segments; i++) {
      final startAngle = (i * arcAngle) - math.pi / 2 + gapAngle / 2;
      paint.color = i < filled ? highlightColor : color;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        arcAngle - gapAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SoftProgressRing oldDelegate) {
    return oldDelegate.filled != filled ||
        oldDelegate.color != color ||
        oldDelegate.highlightColor != highlightColor;
  }
}


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

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    'Welcome',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: scheme.onPrimaryContainer,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'A gentle place to check in.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: scheme.onPrimaryContainer.withOpacity(0.9),
                        ),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: () {},
                    child: const Text('Start a 1‑minute check‑in'),
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

class _AnimatedGradientBackground extends StatefulWidget {
  const _AnimatedGradientBackground({
    required this.colors,
    this.duration = const Duration(seconds: 8),
    super.key,
  });

  final List<Color> colors;
  final Duration duration;

  @override
  State<_AnimatedGradientBackground> createState() => _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<_AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)..repeat(reverse: true);
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
          final lightness = (hsl.lightness * (0.95 + 0.1 * (0.5 - (t - 0.5).abs()))).clamp(0.0, 1.0);
          return hsl.withLightness(lightness).toColor();
        });

        final stops = List<double>.generate(colors.length, (i) => i / (colors.length - 1)).map((s) =>
            (s + (t - 0.5) * 0.06).clamp(0.0, 1.0)).cast<double>().toList();

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

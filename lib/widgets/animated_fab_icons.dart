import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';

// -- SVG Path Data --
final Path _settingsPath = parseSvgPathData(
  'M12.22 2h-.44a2 2 0 0 0-2 2v.18a2 2 0 0 1-1 1.73l-.43.25a2 2 0 0 1-2 0l-.15-.08a2 2 0 0 0-2.73.73l-.22.38a2 2 0 0 0 .73 2.73l.15.1a2 2 0 0 1 1 1.72v.51a2 2 0 0 1-1 1.74l-.15.09a2 2 0 0 0-.73 2.73l.22.38a2 2 0 0 0 2.73.73l.15-.08a2 2 0 0 1 2 0l.43.25a2 2 0 0 1 1 1.73V20a2 2 0 0 0 2 2h.44a2 2 0 0 0 2-2v-.18a2 2 0 0 1 1-1.73l.43-.25a2 2 0 0 1 2 0l.15.08a2 2 0 0 0 2.73-.73l.22-.39a2 2 0 0 0-.73-2.73l-.15-.08a2 2 0 0 1-1-1.74v-.5a2 2 0 0 1 1-1.74l.15-.09a2 2 0 0 0 .73-2.73l-.22-.38a2 2 0 0 0-2.73-.73l-.15.08a2 2 0 0 1-2 0l-.43-.25a2 2 0 0 1-1-1.73V4a2 2 0 0 0-2-2z',
);
final Path _settingsInnerCircle = Path()
  ..addOval(Rect.fromCircle(center: const Offset(12, 12), radius: 3));

final Path _soundBodyPath = parseSvgPathData('M9 15V8a2 2 0 1 0-4 0v7a2 2 0 1 0 4 0Z');
final Path _soundWave1Path = parseSvgPathData('M14 10a4 4 0 0 1 0 6');
final Path _soundWave2Path = parseSvgPathData('M18 7a8 8 0 0 1 0 12');
final Path _soundOffLine = parseSvgPathData('M22 2 L2 22');

final Path _themeSunRays = parseSvgPathData('M12 1v2M12 21v2M4.22 4.22l1.42 1.42M18.36 18.36l1.42 1.42M1 12h2M21 12h2M4.22 19.78l1.42-1.42M18.36 5.64l1.42-1.42');
final Path _themeSunCircle = Path()
  ..addOval(Rect.fromCircle(center: const Offset(12, 12), radius: 5));
final Path _themeMoonPath = parseSvgPathData('M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z');

// -- Gradients --
final Paint _settingsGradient = Paint()
  ..shader = const LinearGradient(
    colors: [Color(0xFF8b5cf6), Color(0xFFec4899)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ).createShader(const Rect.fromLTWH(0, 0, 24, 24))
  ..style = PaintingStyle.stroke
  ..strokeWidth = 2.2
  ..strokeCap = StrokeCap.round
  ..strokeJoin = StrokeJoin.round;

final Paint _soundGradient = Paint()
  ..shader = const LinearGradient(
    colors: [Color(0xFF3b82f6), Color(0xFF8b5cf6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ).createShader(const Rect.fromLTWH(0, 0, 24, 24))
  ..style = PaintingStyle.stroke
  ..strokeWidth = 2.2
  ..strokeCap = StrokeCap.round
  ..strokeJoin = StrokeJoin.round;

final Paint _soundOffPaint = Paint()
  ..color = const Color(0xFFa1a1aa)
  ..style = PaintingStyle.stroke
  ..strokeWidth = 2.2
  ..strokeCap = StrokeCap.round
  ..strokeJoin = StrokeJoin.round;

class AnimatedSettingsIcon extends StatelessWidget {
  const AnimatedSettingsIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(24, 24),
      painter: _SettingsPainter(),
    );
  }
}

class _SettingsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(_settingsPath, _settingsGradient);
    canvas.drawPath(_settingsInnerCircle, _settingsGradient);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AnimatedSoundIcon extends StatefulWidget {
  const AnimatedSoundIcon({super.key, required this.isSoundEnabled});
  final bool isSoundEnabled;

  @override
  State<AnimatedSoundIcon> createState() => _AnimatedSoundIconState();
}

class _AnimatedSoundIconState extends State<AnimatedSoundIcon> with SingleTickerProviderStateMixin {
  late final AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000), // 2s touchWavePulse
    );
    if (widget.isSoundEnabled) {
      _waveController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedSoundIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSoundEnabled && !oldWidget.isSoundEnabled) {
      _waveController.repeat();
    } else if (!widget.isSoundEnabled && oldWidget.isSoundEnabled) {
      _waveController.stop();
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(24, 24),
          painter: _SoundPainter(
            isSoundEnabled: widget.isSoundEnabled,
            waveProgress: _waveController.value,
          ),
        );
      },
    );
  }
}

class _SoundPainter extends CustomPainter {
  _SoundPainter({required this.isSoundEnabled, required this.waveProgress});
  final bool isSoundEnabled;
  final double waveProgress;

  @override
  void paint(Canvas canvas, Size size) {
    if (!isSoundEnabled) {
      canvas.drawPath(_soundBodyPath, _soundOffPaint);
      final wavePaint = Paint()
        ..color = _soundOffPaint.color.withOpacity(0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(_soundWave1Path, wavePaint);
      final linePaint = Paint()
        ..color = _soundOffPaint.color.withOpacity(0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(_soundOffLine, linePaint);
      return;
    }

    // Sound ON
    canvas.drawPath(_soundBodyPath, _soundGradient);

    // touchWavePulse: scale 0.95 -> 1.05, opacity 0.3 -> 1.0 -> 0.3
    double calcWaveOpacity(double t) {
      if (t < 0.5) return 0.3 + (1.0 - 0.3) * (t / 0.5);
      return 1.0 - (1.0 - 0.3) * ((t - 0.5) / 0.5);
    }

    double calcWaveScale(double t) {
      if (t < 0.5) return 0.95 + (1.05 - 0.95) * (t / 0.5);
      return 1.05 - (1.05 - 0.95) * ((t - 0.5) / 0.5);
    }

    // Wave 1
    final wave1Opacity = calcWaveOpacity(waveProgress) * 0.6; // Base 0.6
    final wave1Scale = calcWaveScale(waveProgress);
    
    // Wave 2 (delayed by 0.5s = 0.25 in progress)
    final wave2Progress = (waveProgress - 0.25) % 1.0;
    final wave2ActualProgress = wave2Progress < 0 ? wave2Progress + 1.0 : wave2Progress;
    final wave2Opacity = calcWaveOpacity(wave2ActualProgress) * 0.3; // Base 0.3
    final wave2Scale = calcWaveScale(wave2ActualProgress);

    void drawWave(Path path, double opacity, double scale) {
      canvas.save();
      // transform-origin: center
      canvas.translate(12, 12);
      canvas.scale(scale);
      canvas.translate(-12, -12);
      
      final paint = Paint()
        ..shader = _soundGradient.shader
        ..color = Colors.white.withOpacity(opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      
      canvas.drawPath(path, paint);
      canvas.restore();
    }

    drawWave(_soundWave1Path, wave1Opacity, wave1Scale);
    drawWave(_soundWave2Path, wave2Opacity, wave2Scale);
  }

  @override
  bool shouldRepaint(covariant _SoundPainter oldDelegate) {
    return oldDelegate.isSoundEnabled != isSoundEnabled ||
           oldDelegate.waveProgress != waveProgress;
  }
}

class AnimatedThemeIcon extends StatelessWidget {
  const AnimatedThemeIcon({super.key, required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.ease,
          width: 24,
          height: 24,
          // Dark mode: Sun goes hidden, rotated 90, scaled 0.5
          transform: isDark
              ? (Matrix4.identity()..translate(12.0, 12.0)..rotateZ(1.5708)..scale(0.5)..translate(-12.0, -12.0))
              : Matrix4.identity(),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 400),
            curve: Curves.ease,
            opacity: isDark ? 0.0 : 1.0,
            child: CustomPaint(
              size: const Size(24, 24),
              painter: _ThemeSunPainter(),
            ),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.ease,
          width: 24,
          height: 24,
          // Light mode: Moon goes hidden, rotated -90, scaled 0.5
          transform: isDark
              ? Matrix4.identity()
              : (Matrix4.identity()..translate(12.0, 12.0)..rotateZ(-1.5708)..scale(0.5)..translate(-12.0, -12.0)),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 400),
            curve: Curves.ease,
            opacity: isDark ? 1.0 : 0.0,
            child: CustomPaint(
              size: const Size(24, 24),
              painter: _ThemeMoonPainter(),
            ),
          ),
        ),
      ],
    );
  }
}

class _ThemeSunPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(_themeSunCircle, _soundGradient);
    canvas.drawPath(_themeSunRays, _soundGradient);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ThemeMoonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(_themeMoonPath, _soundGradient);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

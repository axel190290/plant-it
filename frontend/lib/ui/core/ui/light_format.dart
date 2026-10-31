import 'package:flutter/material.dart';
import 'package:plant_it/domain/models/light.dart';
import 'package:plant_it/l10n/generated/app_localizations.dart';

String compassName(L l, CompassPoint point) => switch (point) {
      CompassPoint.n => l.compassN,
      CompassPoint.ne => l.compassNE,
      CompassPoint.e => l.compassE,
      CompassPoint.se => l.compassSE,
      CompassPoint.s => l.compassS,
      CompassPoint.sw => l.compassSW,
      CompassPoint.w => l.compassW,
      CompassPoint.nw => l.compassNW,
    };

/// A number with one decimal at most.
String oneDecimal(double n) =>
    n == n.roundToDouble() ? n.round().toString() : n.toStringAsFixed(1);

/// The light of the last hours as a line, from 0 to the highest reading.
class LightChart extends StatelessWidget {
  final List<LightSample> samples;

  const LightChart({super.key, required this.samples});

  @override
  Widget build(BuildContext context) {
    ColorScheme colors = Theme.of(context).colorScheme;
    return SizedBox(
      height: 80,
      width: double.infinity,
      child: CustomPaint(
        painter: _LightPainter(samples, colors.primary, colors.outlineVariant),
      ),
    );
  }
}

class _LightPainter extends CustomPainter {
  final List<LightSample> samples;
  final Color line;
  final Color axis;

  _LightPainter(this.samples, this.line, this.axis);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height),
        Paint()..color = axis);
    if (samples.length < 2) return;
    DateTime start = samples.first.time;
    double span =
        samples.last.time.difference(start).inSeconds.toDouble().clamp(1, 1e9);
    double top = samples.map((s) => s.lux).reduce((a, b) => a > b ? a : b);
    if (top <= 0) top = 1;
    Path path = Path();
    for (int i = 0; i < samples.length; i++) {
      double x =
          samples[i].time.difference(start).inSeconds / span * size.width;
      double y = size.height - samples[i].lux / top * (size.height - 4);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    canvas.drawPath(
        path,
        Paint()
          ..color = line
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);
  }

  @override
  bool shouldRepaint(_LightPainter old) => old.samples != samples;
}

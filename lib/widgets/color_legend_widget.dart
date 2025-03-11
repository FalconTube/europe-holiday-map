import 'package:flutter/material.dart';
import 'package:color_map/color_map.dart';
import 'package:vector_math/vector_math_64.dart' show Vector4;
import 'package:syncfusion_flutter_maps/maps.dart';

class ColorLegend extends StatelessWidget {
  const ColorLegend({
    super.key,
    required this.cmap,
    required this.min,
    required this.max,
    this.vertical = true,
  });

  final Colormap cmap;
  final int min;
  final int max;
  final bool vertical;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: vertical
          ? DecoratedBox(
              decoration: BoxDecoration(
                color: const Color.fromRGBO(30, 28, 37, 1),
                border: Border.all(
                  color: Colors.grey,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  spacing: 10,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Text(max.toString()), Text(min.toString())],
                    ),
                    LinearColorBox(cmap: cmap),
                  ],
                ),
              ),
            )
          : DecoratedBox(
              decoration: BoxDecoration(
                color: const Color.fromRGBO(30, 28, 37, 1),
                border: Border.all(
                  color: Colors.grey,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  spacing: 10,
                  children: [
                    SizedBox(
                      width: 300,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [Text(min.toString()), Text(max.toString())],
                      ),
                    ),
                    LinearColorBox(
                      cmap: cmap,
                      maxExtent: 300,
                      vertical: false,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class LinearColorBox extends StatelessWidget {
  const LinearColorBox(
      {super.key,
      required this.cmap,
      this.vertical = true,
      this.maxExtent = double.infinity});

  final Colormap cmap;
  final bool vertical;
  final double maxExtent;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: vertical ? maxExtent : 10,
      width: vertical ? 10 : maxExtent,
      child: DecoratedBox(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: vertical ? Alignment.bottomCenter : Alignment.centerLeft,
                end: vertical ? Alignment.topCenter : Alignment.centerRight,
                colors: [cmap(200 / 255).toColor(), cmap(1).toColor()])),
      ),
    );
  }
}

List<MapColorMapper> genColorMap(int length, Colormap cmap) {
  final List<MapColorMapper> out = [];
  if (length == 0) {
    return [
      MapColorMapper(value: 0.toString(), color: cmap(1).toColor()),
    ];
  }
  for (int i = 0; i <= length; i++) {
    final alpha = convert255To1(i, length);
    final colorval = alpha / 256;
    final thisMap =
        MapColorMapper(value: i.toString(), color: cmap(colorval).toColor());
    out.add(thisMap);
  }

  return out;
}

double convert255To1(int value, int maxValue, {int offset = 200}) {
  final out = offset + (255 - offset) / maxValue * value;
  return out;
}

extension ColorTransform on Vector4 {
  /// Convert Vector4 to Color
  Color toColor() {
    return Color.fromARGB(
      (w * 255).toInt(),
      (x * 255).toInt(),
      (y * 255).toInt(),
      (z * 255).toInt(),
    );
  }
}

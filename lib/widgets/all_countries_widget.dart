import 'dart:js_interop';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:holiday_map/logging/logger.dart';
import 'package:holiday_map/main.dart';
import 'package:holiday_map/providers/all_countries_provider.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:color_map/color_map.dart';
import 'package:vector_math/vector_math_64.dart' show Vector4;

class AllCountriesWidget extends ConsumerWidget {
  AllCountriesWidget({super.key});

  final _mapController = MapShapeLayerController();

  final MapShapeSource borderSource = MapShapeSource.asset(
      'assets/geo/eu-borders.geojson',
      shapeDataField: 'CNTR_ID');
  final MapZoomPanBehavior zoomPanBehavior = MapZoomPanBehavior(
    zoomLevel: 2.5,
    focalLatLng: const MapLatLng(50.935173, 6.953101),
    minZoomLevel: 2.5,
    maxZoomLevel: 10,
    enableDoubleTapZooming: true,
    enableMouseWheelZooming: true,
  );
  final cmap = Colormaps.Purples;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(nutsDataProvider);

    final nutsSource = data.data.isEmpty
        // If no data, just return empty map
        ? MapShapeSource.asset('assets/geo/eu-nuts.geojson',
            shapeDataField: 'NUTS_ID')

        // Else return map with filled fields
        : MapShapeSource.asset('assets/geo/eu-nuts.geojson',
            dataCount: data.data.length,
            primaryValueMapper: (int index) => data.data[index].division,
            shapeColorValueMapper: (int index) {
              final numdays = data.data[index].days - 1;
              return numdays.toString();
            },
            shapeColorMappers: genColorMap(data.numSelectedDays, cmap),
            shapeDataField: 'NUTS_ID');

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child:
                Stack(alignment: AlignmentDirectional.bottomCenter, children: [
              SfMaps(
                layers: <MapLayer>[
                  MapShapeLayer(
                    source: borderSource,
                    controller: _mapController,
                    strokeWidth: 3.0,
                    strokeColor: Colors.indigoAccent,
                    tooltipSettings: MapTooltipSettings(
                      color: true
                          ? const Color.fromRGBO(45, 45, 45, 1)
                          : const Color.fromRGBO(242, 242, 242, 1),
                    ),
                    sublayers: <MapSublayer>[
                      MapShapeSublayer(
                          key: UniqueKey(),
                          source: nutsSource,
                          controller: _mapController,
                          strokeWidth: 1.5,
                          color: Colors.grey.withValues(alpha: 0.0),
                          shapeTooltipBuilder:
                              (BuildContext context, int index) {
                            final days = data.data[index].days;
                            final division = data.data[index].division;
                            final holiday = data.data[index].holiday;
                            final text = Text(
                                'Division: $division\nDays: $days\nHoliday: $holiday');
                            return Container(
                                child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: text,
                            ));
                          },
                          strokeColor: Colors.grey.withValues(alpha: 0.2))
                    ],
                    zoomPanBehavior: zoomPanBehavior,
                  ),
                ],
              ),
              Positioned(
                bottom: 0,
                child: ColorLegend(
                  cmap: cmap,
                  min: 1,
                  max: data.numSelectedDays + 1,
                  vertical: false,
                ),
              )
            ]),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height / 3,
            child: SfDateRangePicker(
                headerHeight: 50,
                showNavigationArrow: true,
                monthViewSettings: DateRangePickerMonthViewSettings(
                    enableSwipeSelection: false),
                toggleDaySelection: true,
                selectionMode: DateRangePickerSelectionMode.range,
                initialSelectedDate: DateTime.now(),
                minDate: DateTime(2025),
                maxDate: DateTime(2028),
                extendableRangeSelectionDirection:
                    ExtendableRangeSelectionDirection.forward,
                onSelectionChanged:
                    (DateRangePickerSelectionChangedArgs args) async {
                  final PickerDateRange selectedRange = args.value;
                  final startDate = selectedRange.startDate;
                  final endDate = selectedRange.endDate;
                  if (startDate == null || endDate == null) return;
                  final days = DateTimeRange(start: startDate, end: endDate)
                      .duration
                      .inDays;
                  final out = findHolidaysForDate(startDate, endDate);
                  // Reset
                  await ref.read(nutsDataProvider.notifier).resetData();

                  // Update
                  await ref
                      .read(nutsDataProvider.notifier)
                      .updateMultipleIDs(out, days);
                }),
          ),
        ],
      ),
    );
  }
}

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
          ? Row(
              spacing: 10,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text(max.toString()), Text(min.toString())],
                ),
                LinearColorBox(cmap: cmap),
              ],
            )
          : Column(
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
                colors: [cmap(0).toColor(), cmap(1).toColor()])),
      ),
    );
  }
}

List<MapColorMapper> genColorMap(int length, Colormap cmap) {
  final List<MapColorMapper> out = [];
  for (int i = 0; i <= length; i++) {
    final alpha = intToAlpha(i, length);
    // final colorval = clampDouble(alpha / 255, 0.8, 1);
    final colorval = alpha / 256;
    final thisMap =
        MapColorMapper(value: i.toString(), color: cmap(colorval).toColor());
    out.add(thisMap);
  }

  return out;
}

double intToAlpha(int value, int maxValue) {
  final out = 155 + 100 / maxValue * value;
  // final out = clampDouble(value, 200, 255);
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

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
  final MapShapeSource borderSource = MapShapeSource.asset(
      'assets/geo/eu-borders.geojson',
      shapeDataField: 'CNTR_ID');
  final MapZoomPanBehavior zoomPanBehavior = MapZoomPanBehavior(
    zoomLevel: 2,
    focalLatLng: const MapLatLng(50.935173, 6.953101),
    minZoomLevel: 2,
    maxZoomLevel: 10,
    enableDoubleTapZooming: true,
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
      appBar: AppBar(
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: Row(children: [
              Expanded(
                child: SfMaps(
                  layers: <MapLayer>[
                    MapShapeLayer(
                      source: nutsSource,
                      strokeWidth: 0.3,
                      strokeColor: Colors.grey,
                      sublayers: <MapSublayer>[
                        MapShapeSublayer(
                            source: borderSource,
                            strokeWidth: 1.5,
                            color: Colors.grey.withValues(alpha: 0.0),
                            strokeColor: Colors.indigoAccent)
                      ],
                      zoomPanBehavior: zoomPanBehavior,
                    ),
                  ],
                ),
              ),
              // Expanded(),
              // if (MediaQuery.of(context).size.width > 800)
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

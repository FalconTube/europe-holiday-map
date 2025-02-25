import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:holiday_map/logging/logger.dart';
import 'package:holiday_map/main.dart';
import 'package:holiday_map/providers/all_countries_provider.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(nutsDataProvider);

    // final data = [
    //   MapCountryData(division: "DE1", holiday: "Foo"),
    //   MapCountryData(division: "DE2", holiday: "Foo"),
    //   MapCountryData(division: "DE3", holiday: "Foo"),
    // ];
    final nutsSource = data.isEmpty
        // If no data, just return empty map
        ? MapShapeSource.asset('assets/geo/eu-nuts.geojson',
            shapeDataField: 'NUTS_ID')

        // Else return map with filled fields
        : MapShapeSource.asset('assets/geo/eu-nuts.geojson',
            dataCount: data.length,
            primaryValueMapper: (int index) => data[index].division,
            shapeColorValueMapper: (int index) =>
                "true", //all values in list have holiday
            shapeColorMappers: <MapColorMapper>[
              MapColorMapper(
                value: "true",
                color: const Color(0xFF4DAAFF),
                text: 'No Holiday',
              ),
            ],
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
                      color: Colors.grey.withValues(alpha: 0.2),
                      strokeColor: Colors.grey,
                      sublayers: <MapSublayer>[
                        MapShapeSublayer(
                            source: borderSource,
                            strokeWidth: 1.5,
                            color: Colors.grey.withValues(alpha: 0.5),
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
                selectionMode: DateRangePickerSelectionMode.range,
                initialSelectedDate: DateTime.now(),
                minDate: DateTime(2025), // Set appropriate first date
                maxDate: DateTime(2028), // Set appropriate last date
                onSelectionChanged:
                    (DateRangePickerSelectionChangedArgs args) async {
                  final PickerDateRange range = args.value;
                  final startDate = range.startDate;
                  final endDate = range.endDate;
                  if (startDate == null || endDate == null) return;
                  final out = findHolidaysForDate(startDate, endDate);
                  // Reset
                  await ref.read(nutsDataProvider.notifier).resetData();

                  // Update
                  await ref
                      .read(nutsDataProvider.notifier)
                      .updateMultipleIDs(out);
                }),
          ),
        ],
      ),
    );
  }
}

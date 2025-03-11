import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:holiday_map/main.dart';
import 'package:holiday_map/providers/all_countries_provider.dart';
import 'package:holiday_map/widgets/color_legend_widget.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:color_map/color_map.dart';

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
    maxZoomLevel: 45,
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
              final numdays = data.data[index].totalDays - 1;
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
                    color: Color.fromRGBO(30, 28, 37, 1),
                    source: borderSource,
                    controller: _mapController,
                    strokeWidth: 2.0,
                    strokeColor: Colors.grey.withValues(alpha: 0.8),
                    tooltipSettings: MapTooltipSettings(
                        color: const Color.fromRGBO(30, 28, 37, 1)),
                    sublayers: <MapSublayer>[
                      MapShapeSublayer(
                        key: UniqueKey(),
                        source: nutsSource,
                        controller: _mapController,
                        strokeWidth: 1.5,
                        // showDataLabels: true,
                        color: Colors.grey.withValues(alpha: 0.0),
                        strokeColor: Colors.grey.withValues(alpha: 0.2),
                        shapeTooltipBuilder: (BuildContext context, int index) {
                          final totalDays = data.data[index].totalDays;
                          final division = data.data[index].division;
                          final holiday = data.data[index].holidays;
                          final text = Text(
                            'Division: $division\nOverlap Days: $totalDays\nHoliday: $holiday',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w400),
                          );
                          return Container(
                              child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: text,
                          ));
                        },
                      )
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
                    enableSwipeSelection: kIsWeb ? true : false),
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

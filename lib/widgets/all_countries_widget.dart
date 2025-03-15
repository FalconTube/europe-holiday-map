import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:holiday_map/logging/logger.dart';
import 'package:holiday_map/main.dart';
import 'package:holiday_map/providers/all_countries_provider.dart';
import 'package:holiday_map/widgets/color_legend_widget.dart';
import 'package:holiday_map/widgets/custom_date_picker_widget.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:color_map/color_map.dart';

class AllCountriesWidget extends ConsumerWidget {
  AllCountriesWidget({super.key});

  final _mapController = MapShapeLayerController();

  final MapShapeSource borderSource =
      MapShapeSource.asset('assets/geo/eu-borders.geojson',
          dataCount: borderdat.length,
          shapeColorValueMapper: (int index) {
            return borderdat[index].isDisabled.toString().toUpperCase();
          },
          shapeColorMappers: [
            MapColorMapper(value: "TRUE", color: Colors.grey),
            MapColorMapper(value: "FALSE", color: Color(0xffD2EBCA)),
          ],
          dataLabelMapper: (int index) {
            return borderdat[index].countryNameEn;
          },

          /// This must be the same as CNTR_ID
          primaryValueMapper: (int index) => borderdat[index].countryID,
          shapeDataField: 'CNTR_ID');
  final MapZoomPanBehavior zoomPanBehavior = MapZoomPanBehavior(
    zoomLevel: 2.5,
    focalLatLng: const MapLatLng(50.935173, 6.953101),
    minZoomLevel: 2.5,
    maxZoomLevel: 45,
    enableDoubleTapZooming: true,
    enableMouseWheelZooming: true,
  );
  final cmap = Colormaps.seismic;

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
            primaryValueMapper: (int index) => data.data[index].nuts,
            shapeColorValueMapper: (int index) {
              final numdays = data.data[index].totalDays;
              return numdays.toString();
            },
            shapeColorMappers: genColorMap(data.numSelectedDays + 1, cmap),
            shapeDataField: 'NUTS_ID');

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ColoredBox(
              color: Color(0xFF65C9FE),
              child: SfMapsTheme(
                data: SfMapsThemeData(
                  shapeHoverColor: Colors.transparent,
                  shapeHoverStrokeColor: Colors.grey[900],
                  shapeHoverStrokeWidth: 1.5,
                ),
                child: Stack(
                    alignment: AlignmentDirectional.bottomCenter,
                    children: [
                      SfMaps(
                        layers: <MapLayer>[
                          MapShapeLayer(
                            showDataLabels: true,
                            dataLabelSettings: MapDataLabelSettings(
                                textStyle: TextStyle(fontSize: 14),
                                overflowMode: MapLabelOverflow.hide),
                            source: borderSource,
                            controller: _mapController,
                            strokeWidth: 2.2,
                            strokeColor: Colors.black,
                            sublayers: <MapSublayer>[
                              MapShapeSublayer(
                                key: UniqueKey(),
                                source: nutsSource,
                                controller: _mapController,
                                strokeWidth: 0.5,
                                color: Colors.transparent,
                                strokeColor:
                                    Colors.black.withValues(alpha: 0.3),
                                onSelectionChanged: (int index) {
                                  ScaffoldMessenger.of(context)
                                      .removeCurrentSnackBar();

                                  final totalDays = data.data[index].totalDays;
                                  final division = data.data[index].division;
                                  final holidays = data.data[index].holidays;
                                  // Build holiday display text
                                  String holFormatted = "";
                                  for (final h in holidays) {
                                    final name = h.nameEN ?? h.name;
                                    final start =
                                        h.start.toString().split(' ')[0];
                                    final end = h.end.toString().split(' ')[0];
                                    final thisHol =
                                        "\n\n$name\n$start \u2014 $end";
                                    holFormatted += thisHol;
                                  }
                                  final text = Text(
                                    '$division\nOverlap: $totalDays days$holFormatted',
                                    textAlign: TextAlign.center,
                                    softWrap: true,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: ConstrainedBox(
                                              constraints:
                                                  BoxConstraints(maxWidth: 300),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: text,
                                              ))));
                                },
                              )
                            ],
                            zoomPanBehavior: zoomPanBehavior,
                          ),
                        ],
                      ),
                      data.data.isEmpty
                          ? Container()
                          : Positioned(
                              top: 50,
                              right: 8,
                              child: ColorLegend(
                                cmap: cmap,
                                min: 1,
                                max: data.numSelectedDays + 1,
                              ),
                            )
                    ]),
              ),
            ),
          ),
          MyDatePicker(),
        ],
      ),
    );
  }
}

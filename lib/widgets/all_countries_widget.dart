import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:holiday_map/main.dart';
import 'package:holiday_map/providers/all_countries_provider.dart';
import 'package:holiday_map/providers/rebuild_picker_provider.dart';
import 'package:holiday_map/widgets/color_legend_widget.dart';
import 'package:holiday_map/widgets/custom_date_picker_widget.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:color_map/color_map.dart';

// import 'package:intl/date_symbol_data_file.dart';

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
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
                              textStyle: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w400),
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
                              strokeColor: Colors.black.withValues(alpha: 0.3),
                              onSelectionChanged: (int index) {
                                ScaffoldMessenger.of(context)
                                    .removeCurrentSnackBar();

                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        actionOverflowThreshold: 0.7,
                                        backgroundColor:
                                            Theme.of(context)
                                                .colorScheme
                                                .primaryContainer,
                                        duration: Duration(seconds: 300),
                                        margin: EdgeInsets.all(10),
                                        padding: EdgeInsets.all(30),
                                        behavior: SnackBarBehavior.floating,
                                        showCloseIcon: true,
                                        closeIconColor:
                                            Theme.of(context)
                                                .colorScheme
                                                .onPrimaryContainer,
                                        content:
                                            SnackText(data: data.data[index])));
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
                          ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                            backgroundColor:
                                Theme.of(context).colorScheme.primaryContainer,
                            minimumSize: Size(88, 46),
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                            ),
                          ),
                          icon: Icon(Icons.refresh),
                          label: Text("Reset"),
                          onPressed: () {
                            ref.read(keyProvider.notifier).updateKey();
                            ref.read(nutsDataProvider.notifier).resetData();
                          }),
                    )
                  ],
                ),
              ),
            ),
          ),
          MyDatePicker(),
        ],
      ),
    );
  }
}

class SnackText extends StatelessWidget {
  const SnackText({super.key, required this.data});
  final MapCountryData data;

  @override
  Widget build(BuildContext context) {
    final totalDays = data.totalDays;
    final division = data.division;
    final holidays = data.holidays;
    // Build holiday display text
    List<TextSpan> holFormatted = [];
    var format = DateFormat.yMd();
    for (final h in holidays) {
      final name = h.nameEN ?? h.name;
      final start = format.format(h.start);
      final end = format.format(h.end);
      final nameText = TextSpan(
          text: "\n$name\n",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ));
      final dateText = TextSpan(
          text: "$start \u2014 $end",
          style: TextStyle(
            fontWeight: FontWeight.w400,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ));
      holFormatted.add(nameText);
      holFormatted.add(dateText);
    }
    return RichText(
      textScaler: TextScaler.linear(1.3),
      textAlign: TextAlign.center,
      softWrap: true,
      text: TextSpan(
          text: "$division\n",
          style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onPrimaryContainer),
          children: <TextSpan>[
            TextSpan(
              text: "Overlap: ",
              style: TextStyle(
                fontWeight: FontWeight.w400,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            TextSpan(
                text: "$totalDays\n",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                )),
            ...holFormatted,
          ]),
    );
  }
}

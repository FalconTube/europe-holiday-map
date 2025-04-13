import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:holiday_map/classes/icon_holiday_mapping.dart';
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
  // final cmap = Colormaps.seismic;
  final cmap = Colormaps.YlOrRd;
  bool isBannerShowing = false;

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
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: ColoredBox(
              color: Color.fromRGBO(114, 212, 232, 1),
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
                                  fontSize: 14, fontWeight: FontWeight.w700),
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
                                final selectionData = data.data[index];
                                // Mark overlapping dates in DatePicker
                                ref
                                    .read(selectedCountryDataProvider.notifier)
                                    .setData(selectionData);

                                if (isBannerShowing == true) {
                                  return;
                                }
                                final banner = MaterialBanner(
                                  content: BannerContent(),
                                  padding: EdgeInsets.all(10.0),
                                  elevation: 4,
                                  actions: [
                                    IconButton(
                                        icon: Icon(Icons.close),
                                        onPressed: () {
                                          ScaffoldMessenger.of(context)
                                              .removeCurrentMaterialBanner();
                                          isBannerShowing = false;
                                        })
                                  ],
                                );
                                ScaffoldMessenger.of(context)
                                    .showMaterialBanner(banner);
                                isBannerShowing = true;
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
                            foregroundColor:
                                Theme.of(context).colorScheme.onSurface,
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
                            const bool isRunningWithWasm =
                                bool.fromEnvironment('dart.tool.dart2wasm');
                            if (isRunningWithWasm) {
                              print('Flutter app is running in WASM mode.');
                            } else {
                              print(
                                  'Flutter app is running in JavaScript mode.');
                            }
                            ref.read(keyProvider.notifier).updateKey();
                            ref.read(nutsDataProvider.notifier).resetData();
                            ref
                                .read(selectedCountryDataProvider.notifier)
                                .resetData();
                          }),
                    )
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
            child: MyDatePicker(),
          ),
        ],
      ),
    );
  }
}

List<Widget> buildHolidayEntries(MapCountryData data, BuildContext context) {
  final holidays = data.holidays;
  // Build holiday display text
  List<RichText> holFormatted = [];
  var format = DateFormat.yMd();
  final iconMapper = IconHolidayMapping();
  for (final h in holidays) {
    // Name of holiday
    final name = h.nameEN ?? h.name;
    final matchingIcon = iconMapper.getMatchingIcon(name);
    final nameText = TextSpan(
        text: "$matchingIcon$name\n",
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.onSurface,
        ));
    // Get date range and check, if only a single day
    final start = format.format(h.start);
    final end = format.format(h.end);
    bool isSingleDay = start == end;
    final dateText = TextSpan(
        text: isSingleDay ? start : "$start \u2014 $end",
        style: TextStyle(
          fontWeight: FontWeight.w400,
          color: Theme.of(context).colorScheme.onSurface,
        ));
    // Combine everything
    RichText output = RichText(
        textScaler: TextScaler.linear(1.2),
        textAlign: TextAlign.center,
        text: TextSpan(text: "", children: [nameText, dateText]));
    holFormatted.add(output);
  }

  List<Widget> out = [];
  for (final entry in holFormatted) {
    final widget = Container(
        padding: EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          border: Border.all(),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: entry);
    out.add(widget);
  }
  return out;
}

class BannerContent extends ConsumerWidget {
  const BannerContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(selectedCountryDataProvider);
    if (data == null) return Container();

    final totalDays = data.totalDays;
    final division = data.division;
    final holFormatted = buildHolidayEntries(data, context);
    return Column(
      children: [
        RichText(
          textScaler: TextScaler.linear(1.2),
          textAlign: TextAlign.center,
          softWrap: true,
          text: TextSpan(
              text: "$division\n",
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface),
              children: <TextSpan>[
                TextSpan(
                  text: "Overlap: ",
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                TextSpan(
                    text: "$totalDays\n",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    )),
                // ...holFormatted,
              ]),
        ),
        Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 20,
            runSpacing: 8,
            children: [...holFormatted]),
      ],
    );
  }
}

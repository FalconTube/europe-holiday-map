import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:holiday_map/classes/icon_holiday_mapping.dart';
import 'package:holiday_map/main.dart';
import 'package:holiday_map/providers/all_countries_provider.dart';
import 'package:holiday_map/providers/brightness_provider.dart';
import 'package:holiday_map/providers/selected_map_index_provider.dart';
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

    final brightness = ref.watch(brightnessProvider);
    final isLightTheme = brightness == Brightness.light;

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: ColoredBox(
              color: isLightTheme
                  ? Color.fromRGBO(114, 212, 232, 1)
                  : Color.fromRGBO(13, 85, 103, 1),
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
                          strokeWidth: 2.2,
                          strokeColor: Colors.black,
                          sublayers: <MapSublayer>[
                            MapShapeSublayer(
                              source: nutsSource,
                              strokeWidth: 0.5,
                              color: Colors.transparent,
                              strokeColor: Colors.black.withValues(alpha: 0.3),
                              onSelectionChanged: (int index) {
                                final selectionData = data.data[index];
                                // Keep track of selection index
                                ref
                                    .read(selectedMapIndexProvider.notifier)
                                    .update(selectionData.nuts);

                                // Mark overlapping dates in DatePicker
                                ref
                                    .read(selectedCountryDataProvider.notifier)
                                    .setData(selectionData);
                                ref.read(keyProvider.notifier).reset();

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
                            ref.read(keyProvider.notifier).reset();
                            ref.read(controllerProvider.notifier).reset();
                            ref.read(nutsDataProvider.notifier).resetData();
                            ref.read(selectedMapIndexProvider.notifier).reset();
                            ref
                                .read(selectedCountryDataProvider.notifier)
                                .resetData();
                          }),
                    ),
                    Positioned(
                      top: 10,
                      left: 8,
                      child: IconButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor:
                                Theme.of(context).colorScheme.onSurface,
                            backgroundColor:
                                Theme.of(context).colorScheme.primaryContainer,
                            padding: EdgeInsets.symmetric(horizontal: 10),
                          ),
                          icon: isLightTheme
                              ? Icon(Icons.dark_mode)
                              : Icon(Icons.wb_sunny),
                          onPressed: () {
                            const bool isRunningWithWasm =
                                bool.fromEnvironment('dart.tool.dart2wasm');
                            if (isRunningWithWasm) {
                              print('Flutter app is running in WASM mode.');
                            } else {
                              print(
                                  'Flutter app is running in JavaScript mode.');
                            }
                            ref
                                .read(brightnessProvider.notifier)
                                .switchBrightness();
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

class HolidayAndIcon {
  final RichText holiday;
  final Icon icon;

  HolidayAndIcon({required this.holiday, required this.icon});
}

List<Widget> buildHolidayEntries(MapCountryData data, BuildContext context) {
  final holidays = data.holidays;
  // Build holiday display text
  List<HolidayAndIcon> holFormatted = [];
  var format = DateFormat.yMd();
  final iconMapper = IconHolidayMapping();
  for (final h in holidays) {
    // Name of holiday
    final name = h.nameEN ?? h.name;
    final matchingIcon = iconMapper.getMatchingIcon(name);
    // Get date range and check, if only a single day
    final start = format.format(h.start);
    final end = format.format(h.end);
    bool isSingleDay = start == end;
    final dateText = TextSpan(
        text: isSingleDay ? "  $name\n$start" : "  $name\n$start - $end",
        style: TextStyle(
          fontWeight: FontWeight.w400,
          color: Theme.of(context).colorScheme.onSurface,
        ));
    // Combine everything
    RichText output = RichText(
        textAlign: TextAlign.center,
        text: TextSpan(text: "", children: [dateText]));
    holFormatted.add(HolidayAndIcon(holiday: output, icon: matchingIcon));
  }

  List<Widget> out = [];
  for (final entry in holFormatted) {
    final widget = Container(
        padding: EdgeInsets.all(4.0),
        decoration: BoxDecoration(
            border: Border.all(),
            borderRadius: BorderRadius.circular(8.0),
            color: Theme.of(context).colorScheme.secondaryContainer),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 4,
          children: [entry.icon, entry.holiday],
        ));
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

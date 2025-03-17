import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:holiday_map/logging/logger.dart';
import 'package:holiday_map/main.dart';
import 'package:holiday_map/providers/all_countries_provider.dart';
import 'package:holiday_map/providers/rebuild_picker_provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class MyDatePicker extends ConsumerStatefulWidget {
  const MyDatePicker({super.key});

  @override
  MyDatePickerState createState() => MyDatePickerState();
}

class MyDatePickerState extends ConsumerState<MyDatePicker> {
  final isWebMobile = kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android);
  // Key _key = UniqueKey();

  // void reset() {
  //   setState(() {
  //     _key = UniqueKey();
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final key = ref.watch(keyProvider);
    return SizedBox(
      height: MediaQuery.of(context).size.height / 3,
      child: SfDateRangePicker(
          key: key,
          headerHeight: 50,
          showNavigationArrow: true,
          // showActionButtons: true,
          monthViewSettings: DateRangePickerMonthViewSettings(
              enableSwipeSelection: isWebMobile ? false : true),
          toggleDaySelection: true,
          selectionMode: DateRangePickerSelectionMode.extendableRange,
          initialSelectedDate: DateTime.now(),
          minDate: DateTime(2025),
          maxDate: DateTime(2028),
          extendableRangeSelectionDirection:
              ExtendableRangeSelectionDirection.both,
          // onCancel: () {
          //   // Reset data
          //   ref.read(nutsDataProvider.notifier).resetData();
          //   // Reset picker widget
          //   reset();
          // },
          onSelectionChanged: (DateRangePickerSelectionChangedArgs args) async {
            final PickerDateRange selectedRange = args.value;
            final startDate = selectedRange.startDate;
            final endDate = selectedRange.endDate;
            if (startDate == null || endDate == null) return;
            final days =
                DateTimeRange(start: startDate, end: endDate).duration.inDays;
            final out = findHolidaysForDate(startDate, endDate);

            // Update
            await ref
                .read(nutsDataProvider.notifier)
                .updateMultipleIDs(out, days);
          }),
    );
  }
}

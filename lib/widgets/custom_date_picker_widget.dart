import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:holiday_map/main.dart';
import 'package:holiday_map/providers/all_countries_provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class MyDatePicker extends ConsumerWidget {
  MyDatePicker({
    super.key,
  });

  final isWebMobile = kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: MediaQuery.of(context).size.height / 3,
      child: SfDateRangePicker(
          headerHeight: 50,
          showNavigationArrow: true,
          monthViewSettings: DateRangePickerMonthViewSettings(
              enableSwipeSelection: isWebMobile ? false : true),
          toggleDaySelection: true,
          selectionMode: DateRangePickerSelectionMode.extendableRange,
          initialSelectedDate: DateTime.now(),
          minDate: DateTime(2025),
          maxDate: DateTime(2028),
          extendableRangeSelectionDirection:
              ExtendableRangeSelectionDirection.both,
          onSelectionChanged: (DateRangePickerSelectionChangedArgs args) async {
            final PickerDateRange selectedRange = args.value;
            final startDate = selectedRange.startDate;
            final endDate = selectedRange.endDate;
            if (startDate == null || endDate == null) return;
            final days =
                DateTimeRange(start: startDate, end: endDate).duration.inDays;
            final out = findHolidaysForDate(startDate, endDate);
            // Reset
            await ref.read(nutsDataProvider.notifier).resetData();

            // Update
            await ref
                .read(nutsDataProvider.notifier)
                .updateMultipleIDs(out, days);
          }),
    );
  }
}

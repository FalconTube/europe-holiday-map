import 'package:json_annotation/json_annotation.dart';

part 'entry.g.dart';

@JsonSerializable()
class AllStateHolidays {
  @JsonKey(name: "state_holidays")
  final List<StateHolidays> stateHolidays;
  final String country;
  // Add other relevant data like title, description, etc.
  AllStateHolidays({
    required this.stateHolidays,
    required this.country,
  });

  factory AllStateHolidays.fromJson(Map<String, dynamic> json) {
    return _$AllStateHolidaysFromJson(json);
  }

  Map<String, dynamic> toJson() => _$AllStateHolidaysToJson(this);
}

@JsonSerializable()
class StateHolidays {
  final String iso;
  final List<Holiday> holidays;
  // Add other relevant data like title, description, etc.
  StateHolidays({
    required this.iso,
    required this.holidays,
  });

  factory StateHolidays.fromJson(Map<String, dynamic> json) {
    return _$StateHolidaysFromJson(json);
  }

  Map<String, dynamic> toJson() => _$StateHolidaysToJson(this);
}

@JsonSerializable()
class Holiday {
  final DateTime start;
  final DateTime end;
  @JsonKey(name: "name")
  final String name;
  @JsonKey(name: "name_en")
  final String? nameEN;
  @JsonKey(name: "hol_type")
  final String type;
  // Add other relevant data like title, description, etc.
  Holiday(
      {required this.start,
      required this.end,
      required this.name,
      required this.nameEN,
      required this.type});

  factory Holiday.fromJson(Map<String, dynamic> json) {
    return _$HolidayFromJson(json);
  }

  Map<String, dynamic> toJson() => _$HolidayToJson(this);
}

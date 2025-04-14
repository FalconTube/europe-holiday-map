import 'package:json_annotation/json_annotation.dart';

part 'entry.g.dart';

@JsonSerializable()
class BorderCountry {
  @JsonKey(name: "CNTR_ID")
  final String countryID;
  @JsonKey(name: "CNTR_NAME")
  final String countryName;
  @JsonKey(name: "NAME_ENGL")
  final String countryNameEn;
  @JsonKey(name: "DISABLED")
  final bool isDisabled;
  // Add other relevant data like title, description, etc.
  BorderCountry({
    required this.countryID,
    required this.countryName,
    required this.countryNameEn,
    required this.isDisabled,
  });

  factory BorderCountry.fromJson(Map<String, dynamic> json) {
    return _$BorderCountryFromJson(json);
  }

  Map<String, dynamic> toJson() => _$BorderCountryToJson(this);
}

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
  final String name;
  final String? iso;
  final String? code;
  final List<Holiday> holidays;
  // Add other relevant data like title, description, etc.
  StateHolidays({
    required this.name,
    required this.iso,
    required this.code,
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

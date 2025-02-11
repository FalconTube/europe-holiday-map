import 'package:json_annotation/json_annotation.dart';

part 'entry.g.dart';

@JsonSerializable()
class SubdivisionHolidays {
  final String iso;
  final List<Holiday> holidays;
  // Add other relevant data like title, description, etc.
  SubdivisionHolidays({
    required this.iso,
    required this.holidays,
  });

  factory SubdivisionHolidays.fromJson(Map<String, dynamic> json) {
    return _$SubdivisionHolidaysFromJson(json);
  }

  Map<String, dynamic> toJson() => _$SubdivisionHolidaysToJson(this);
}

@JsonSerializable()
class Holiday {
  final DateTime start;
  final DateTime end;
  @JsonKey(name: "name_de")
  final String nameDE;
  @JsonKey(name: "name_en")
  final String nameEN;
  @JsonKey(name: "hol_type")
  final String type;
  // Add other relevant data like title, description, etc.
  Holiday(
      {required this.start,
      required this.end,
      required this.nameDE,
      required this.nameEN,
      required this.type});

  factory Holiday.fromJson(Map<String, dynamic> json) {
    return _$HolidayFromJson(json);
  }

  Map<String, dynamic> toJson() => _$HolidayToJson(this);
}

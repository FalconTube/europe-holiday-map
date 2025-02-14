// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AllStateHolidays _$AllStateHolidaysFromJson(Map<String, dynamic> json) =>
    AllStateHolidays(
      stateHolidays: (json['state_holidays'] as List<dynamic>)
          .map((e) => StateHolidays.fromJson(e as Map<String, dynamic>))
          .toList(),
      country: json['country'] as String,
    );

Map<String, dynamic> _$AllStateHolidaysToJson(AllStateHolidays instance) =>
    <String, dynamic>{
      'state_holidays': instance.stateHolidays,
      'country': instance.country,
    };

StateHolidays _$StateHolidaysFromJson(Map<String, dynamic> json) =>
    StateHolidays(
      iso: json['iso'] as String,
      holidays: (json['holidays'] as List<dynamic>)
          .map((e) => Holiday.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$StateHolidaysToJson(StateHolidays instance) =>
    <String, dynamic>{
      'iso': instance.iso,
      'holidays': instance.holidays,
    };

Holiday _$HolidayFromJson(Map<String, dynamic> json) => Holiday(
      start: DateTime.parse(json['start'] as String),
      end: DateTime.parse(json['end'] as String),
      nameDE: json['name_de'] as String,
      nameEN: json['name_en'] as String,
      type: json['hol_type'] as String,
    );

Map<String, dynamic> _$HolidayToJson(Holiday instance) => <String, dynamic>{
      'start': instance.start.toIso8601String(),
      'end': instance.end.toIso8601String(),
      'name_de': instance.nameDE,
      'name_en': instance.nameEN,
      'hol_type': instance.type,
    };

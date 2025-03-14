// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BorderCountry _$BorderCountryFromJson(Map<String, dynamic> json) =>
    BorderCountry(
      countryID: json['CNTR_ID'] as String,
      countryName: json['CNTR_NAME'] as String,
      countryNameEn: json['NAME_ENGL'] as String,
      isDisabled: json['DISABLED'] as bool,
    );

Map<String, dynamic> _$BorderCountryToJson(BorderCountry instance) =>
    <String, dynamic>{
      'CNTR_ID': instance.countryID,
      'CNTR_NAME': instance.countryName,
      'NAME_ENGL': instance.countryNameEn,
      'DISABLED': instance.isDisabled,
    };

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
      iso: json['iso'] as String?,
      code: json['code'] as String?,
      holidays: (json['holidays'] as List<dynamic>)
          .map((e) => Holiday.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$StateHolidaysToJson(StateHolidays instance) =>
    <String, dynamic>{
      'iso': instance.iso,
      'code': instance.code,
      'holidays': instance.holidays,
    };

Holiday _$HolidayFromJson(Map<String, dynamic> json) => Holiday(
      start: DateTime.parse(json['start'] as String),
      end: DateTime.parse(json['end'] as String),
      name: json['name'] as String,
      nameEN: json['name_en'] as String?,
      type: json['hol_type'] as String,
    );

Map<String, dynamic> _$HolidayToJson(Holiday instance) => <String, dynamic>{
      'start': instance.start.toIso8601String(),
      'end': instance.end.toIso8601String(),
      'name': instance.name,
      'name_en': instance.nameEN,
      'hol_type': instance.type,
    };

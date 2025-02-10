import json
from enum import StrEnum
from dataclasses import dataclass, asdict
from typing import Dict, Optional
import requests


def parse_names_from_data(names_list: list[Dict]) -> tuple[str, str]:
    name_en = None
    name_de = None
    for entry in names_list:
        lang = entry["language"]
        if lang == "DE":
            name_de = entry["text"]
        if lang == "EN":
            name_en = entry["text"]
    assert name_en is not None, f"Could not find English name in data: {names_list}"
    assert name_de is not None, f"Could not find German name in data: {names_list}"
    return name_en, name_de


class HolidayType(StrEnum):
    PUBLIC = "Public"
    SCHOOL = "School"


@dataclass
class Country:
    iso: str
    name_en: str
    name_de: str

    @classmethod
    def from_dict(cls, data: Dict):
        iso = data.get("isoCode")
        names_list: list[dict[str, str]] = data["name"]
        name_en, name_de = parse_names_from_data(names_list)
        assert iso is not None, f"Could not find key 'isoCode' in data: {data}"

        return cls(iso=iso, name_en=name_en, name_de=name_de)


@dataclass
class Subdivision(Country):
    short_name: str

    @classmethod
    def from_dict(cls, data: Dict):
        base_data = Country.from_dict(data)
        short_name = data.get("shortName")
        assert short_name is not None, f"Could not find key 'shortName' in data: {data}"
        return cls(
            iso=base_data.iso,
            name_en=base_data.name_en,
            name_de=base_data.name_de,
            short_name=short_name,
        )


@dataclass
class Holiday:
    start_date: str
    end_date: str
    name_en: str
    name_de: str
    hol_type: HolidayType

    @classmethod
    def from_dict(cls, data: Dict):
        # Dates
        start_date = data.get("startDate")
        end_date = data.get("endDate")
        assert start_date is not None, f"Could not find key 'startDate' in data: {data}"
        assert end_date is not None, f"Could not find key 'endDate' in data: {data}"
        # Names
        names_list: list[dict[str, str]] = data["name"]
        name_en, name_de = parse_names_from_data(names_list)
        # Type
        hol_type_str = data.get("type")
        assert hol_type_str is not None, f"Could not find key 'type' in data: {data}"
        try:
            holiday_type = HolidayType(hol_type_str)
        except ValueError:
            raise ValueError(
                f"Invalid holidayType: {hol_type_str}. Must be 'public' or 'shool'"
            )
        return cls(
            start_date=start_date,
            end_date=end_date,
            name_en=name_en,
            name_de=name_de,
            hol_type=holiday_type,
        )


@dataclass
class SubdivionHolidays:
    iso: str
    holidays: list[Holiday]


@dataclass
class AllSubdivionHolidays:
    subdivionHolidays: list[SubdivionHolidays]


def get_countries() -> list[Country]:
    res = requests.get("https://openholidaysapi.org/Countries")
    data: list[Dict] = res.json()
    country_list: list[Country] = []
    for country_obj in data:
        country = Country.from_dict(country_obj)
        country_list.append(country)
    return country_list


def get_subdivions(country_iso: str) -> list[Subdivision]:
    params = {"countryIsoCode": country_iso}
    res = requests.get("https://openholidaysapi.org/Subdivisions", params=params)
    data: list[Dict] = res.json()
    sub_list: list[Subdivision] = []
    for sub_obj in data:
        sub = Subdivision.from_dict(sub_obj)
        sub_list.append(sub)
    return sub_list


def get_holidays(
    hol_type: HolidayType, country_iso: str, subdivision_code: Optional[str] = None
) -> list[Holiday]:
    params = {
        "countryIsoCode": country_iso,
        "validFrom": "2025-01-01",
        "validTo": "2027-01-01",
    }
    # Only to params if given
    if subdivision_code is not None:
        params["subdivisionCode"] = subdivision_code

    if hol_type == HolidayType.PUBLIC:
        res = requests.get("https://openholidaysapi.org/PublicHolidays", params=params)
    else:
        res = requests.get("https://openholidaysapi.org/SchoolHolidays", params=params)
    data: list[Dict] = res.json()
    hol_list: list[Holiday] = []
    for hol_obj in data:
        hol = Holiday.from_dict(hol_obj)
        hol_list.append(hol)
    return hol_list


if __name__ == "__main__":
    all_hols_list: list[SubdivionHolidays] = []
    subs = get_subdivions("DE")
    for sub in subs:
        sub_hols_list: list[Holiday] = []
        school_hols = get_holidays(HolidayType.SCHOOL, "DE", sub.iso)
        pub_hols = get_holidays(HolidayType.PUBLIC, "DE", sub.iso)
        sub_hols_list.extend(school_hols)
        sub_hols_list.extend(pub_hols)
        sub_holidays = SubdivionHolidays(iso=sub.iso, holidays=sub_hols_list)
        all_hols_list.append(sub_holidays)
    # to dataclass
    all_hols = AllSubdivionHolidays(subdivionHolidays=all_hols_list)

    outfile = "parsed_from_openholidaysapi.json"
    with open(outfile, "w", encoding="utf-8") as w:
        w.write(json.dumps(asdict(all_hols), indent=2))

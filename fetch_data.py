import sys
import json
from enum import StrEnum
from dataclasses import dataclass, asdict
from typing import Dict, Optional
import requests
from pprint import pprint, pformat
from pathlib import Path
from icecream import ic


def parse_names_from_data(names_list: list[Dict]) -> tuple[str, Optional[str]]:
    # Original language should always be first one
    # TODO: Lookup language by country input
    name = names_list[0]["text"]
    # Now find optional english language
    name_en = None
    for entry in names_list:
        lang = entry["language"]
        if lang == "EN":
            name_en = entry["text"]
    assert name is not None, (
        f"Could not find default language name in data: {names_list}"
    )
    return name, name_en


class HolidayType(StrEnum):
    PUBLIC = "Public"
    SCHOOL = "School"
    OTHER = "Other"


@dataclass
class Country:
    iso: str
    code: Optional[str]
    name: str
    name_en: Optional[str]

    @classmethod
    def from_dict(cls, data: Dict):
        iso = data.get("isoCode")
        assert iso is not None, f"Could not parse iso from country data: {
            data}"
        code = data.get("code")
        names_list: list[dict[str, str]] = data["name"]
        name, name_en = parse_names_from_data(names_list)

        return cls(iso=iso, code=code, name_en=name_en, name=name)


@dataclass
class Subdivision:
    iso: Optional[str]
    code: Optional[str]
    name: str
    name_en: Optional[str]
    short_name: str

    @classmethod
    def from_dict(cls, data: Dict):
        iso = data.get("isoCode")
        code = data.get("code")
        names_list: list[dict[str, str]] = data["name"]
        name, name_en = parse_names_from_data(names_list)
        short_name = data.get("shortName")
        assert short_name is not None, f"Could not find key 'shortName' in data: {
            data}"
        return cls(
            iso=iso,
            code=code,
            name_en=name_en,
            name=name,
            short_name=short_name,
        )


@dataclass
class Holiday:
    start: str
    end: str
    name: str
    name_en: Optional[str]
    hol_type: Optional[HolidayType]

    @classmethod
    def from_dict(cls, data: Dict):
        # Dates
        start = data.get("startDate")
        end = data.get("endDate")
        assert start is not None, f"Could not find key 'startDate' in data: {
            data}"
        assert end is not None, f"Could not find key 'endDate' in data: {data}"
        # Names
        names_list: list[dict[str, str]] = data["name"]
        name, name_en = parse_names_from_data(names_list)
        # Type
        hol_type_str = data.get("type")
        assert hol_type_str is not None, f"Could not find key 'type' in data: {
            data}"
        if hol_type_str not in ["Public", "School"]:
            hol_type_str = "Other"
        try:
            holiday_type = HolidayType(hol_type_str)
        except ValueError:
            raise ValueError(
                f"Invalid holidayType: {
                    hol_type_str}. Must be 'public' or 'school'"
            )
        return cls(
            start=start,
            end=end,
            name_en=name_en,
            name=name,
            hol_type=holiday_type,
        )


@dataclass
class SubdivionHolidays:
    iso: Optional[str]
    code: Optional[str]
    holidays: list[Holiday]


@dataclass
class AllSubdivionHolidays:
    country: str
    state_holidays: list[SubdivionHolidays]


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
    res = requests.get(
        "https://openholidaysapi.org/Subdivisions", params=params)
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
        res = requests.get(
            "https://openholidaysapi.org/PublicHolidays", params=params)
    else:
        res = requests.get(
            "https://openholidaysapi.org/SchoolHolidays", params=params)
    data: list[Dict] = res.json()
    hol_list: list[Holiday] = []
    for hol_obj in data:
        hol = Holiday.from_dict(hol_obj)
        hol_list.append(hol)
    return hol_list


def extract_eu_from_world(world_json_file: str):
    file_str = Path(world_json_file).read_text()
    ic(file_str)


if __name__ == "__main__":
    extract_eu_from_world("assets/geo/world.geojson")
    sys.exit()
    countries = get_countries()
    # countries = [Country(iso="AT", code="AT", name="Espania", name_en="Spain")]
    country_list = []
    for country in countries:
        all_hols_list: list[SubdivionHolidays] = []
        subs = get_subdivions(country.iso)
        for sub in subs:
            sub_hols_list: list[Holiday] = []
            # get via sub code first
            school_hols = get_holidays(
                HolidayType.SCHOOL, country.iso, sub.code)
            if school_hols == []:
                # if sub code does not return, then use iso
                school_hols = get_holidays(
                    HolidayType.SCHOOL, country.iso, sub.iso)
            # if still empty, print it
            if school_hols == []:
                print(f"School holidays empty for sub: {sub}")
            pub_hols = get_holidays(HolidayType.PUBLIC, country.iso, sub.code)
            if pub_hols == []:
                pub_hols = get_holidays(
                    HolidayType.PUBLIC, country.iso, sub.iso)
            if pub_hols == []:
                print(f"Pub holidays empty for sub: {sub}")
            sub_hols_list.extend(school_hols)
            sub_hols_list.extend(pub_hols)
            # assert sub.iso is not None, f"Could not get iso for sub: {sub}"
            sub_holidays = SubdivionHolidays(
                iso=sub.iso, code=sub.code, holidays=sub_hols_list
            )
            all_hols_list.append(sub_holidays)
        # to dataclass
        all_hols = AllSubdivionHolidays(
            state_holidays=all_hols_list, country=country.iso.lower()
        )
        country_list.append(asdict(all_hols))

    outfile = "parsed_from_openholidaysapi.json"
    with open(outfile, "w", encoding="utf-8") as w:
        w.write(json.dumps(country_list, indent=2))

from inspect import iscoroutine
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
    name: str
    code: Optional[str] = ""
    name_en: Optional[str] = ""

    @classmethod
    def from_dict(cls, data: Dict):
        iso = data.get("isoCode")
        assert iso is not None, f"Could not parse iso from country data: {data}"
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
        assert short_name is not None, f"Could not find key 'shortName' in data: {data}"
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
        assert start is not None, f"Could not find key 'startDate' in data: {data}"
        assert end is not None, f"Could not find key 'endDate' in data: {data}"
        # Names
        names_list: list[dict[str, str]] = data["name"]
        name, name_en = parse_names_from_data(names_list)
        # Type
        hol_type_str = data.get("type")
        assert hol_type_str is not None, f"Could not find key 'type' in data: {data}"
        if hol_type_str not in ["Public", "School"]:
            hol_type_str = "Other"
        try:
            holiday_type = HolidayType(hol_type_str)
        except ValueError:
            raise ValueError(
                f"Invalid holidayType: {hol_type_str}. Must be 'public' or 'school'"
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
    name: str
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
    missing_countries = {
        "SE": [
            Subdivision(
                iso="SE1",
                code="SE1",
                name="Östra Sverige",
                name_en="East Sweden",
                short_name="ES",
            ),
            Subdivision(
                iso="SE2",
                code="SE2",
                name="Södra Sverige",
                name_en="South Sweden",
                short_name="SS",
            ),
            Subdivision(
                iso="SE3",
                code="SE3",
                name="Norra Sverige",
                name_en="North Sweden",
                short_name="NS",
            ),
        ],
        "HU": [
            Subdivision(
                iso="HU1",
                code="HU1",
                name="Közép-Magyarország",
                name_en="Central Hungary",
                short_name="CH",
            ),
            Subdivision(
                iso="HU2",
                code="HU2",
                name="Dunántúl",
                name_en="Transdanubia",
                short_name="WH",
            ),
            Subdivision(
                iso="HU3",
                code="HU3",
                name="Alföld és Észak)",
                name_en="Great Plain and North",
                short_name="EH",
            ),
        ],
        "EE": [
            Subdivision(
                iso="EE0",
                code="EE0",
                name="Eestni",
                name_en="Estonia",
                short_name="EE",
            ),
        ],
        "LV": [
            Subdivision(
                iso="LV0",
                code="LV0",
                name="Latvija",
                name_en="Latvia",
                short_name="LV",
            ),
        ],
        "LT": [
            Subdivision(
                iso="LT0",
                code="LT0",
                name="Lietuva",
                name_en="Lithuania",
                short_name="LT",
            ),
        ],
        "IE": [
            Subdivision(
                iso="IE0",
                code="IE0",
                name="Ireland",
                name_en="Ireland",
                short_name="IE",
            ),
        ],
        "LU": [
            Subdivision(
                iso="LU0",
                code="LU0",
                name="Luxembourg",
                name_en="Luxembourg",
                short_name="LU",
            ),
        ],
        "LI": [
            Subdivision(
                iso="LI0",
                code="LI0",
                name="Liechtenstein",
                name_en="Liechtenstein",
                short_name="LI",
            ),
        ],
        "HR": [
            Subdivision(
                iso="HR0",
                code="HR0",
                name="Hrvatska",
                name_en="Croatia",
                short_name="HR",
            ),
        ],
        "AL": [
            Subdivision(
                iso="AL0",
                code="AL0",
                name="Shqipëria",
                name_en="Albania",
                short_name="AL",
            ),
        ],
        "AD": [
            Subdivision(
                iso="AD0",
                code="AD0",
                name="Andorra",
                name_en="Andorra",
                short_name="AD",
            ),
        ],
        "RS": [
            Subdivision(
                iso="RS1",
                code="RS1",
                name="Србија - север",
                name_en="Serbia - sever",
                short_name="RS1",
            ),
            Subdivision(
                iso="RS2",
                code="RS2",
                name="Србија - југ",
                name_en="Serbia - jug",
                short_name="RS2",
            ),
        ],
        "BG": [
            Subdivision(
                iso="BG3",
                code="BG3",
                name="Северна и Югоизточна България",
                name_en="Severna i Yugoiztochna Bulgaria",
                short_name="BG3",
            ),
            Subdivision(
                iso="BG4",
                code="BG4",
                name="Югозападна и Южна централна България",
                name_en="Yugozapadna i Yuzhna tsentralna Bulgaria",
                short_name="BG4",
            ),
        ],
        "MD": [
            Subdivision(
                iso="MD0",
                code="MD0",
                name="Moldova",
                name_en="Moldova",
                short_name="MD0",
            ),
        ],
        "MT": [
            Subdivision(
                iso="MT0",
                code="MT0",
                name="Malta-Malta",
                name_en="Malta",
                short_name="MT0",
            ),
        ],
        "MC": [
            Subdivision(
                iso="MC0",
                code="MC0",
                name="Malta-Malta",
                name_en="Malta",
                short_name="MT0",
            ),
        ],
        "BY": [
            Subdivision(
                iso="BY0",
                code="BY0",
                name="Беларусь",
                name_en="Belarus",
                short_name="BY0",
            ),
        ],
    }
    if country_iso in missing_countries.keys():
        return missing_countries[country_iso]

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


def extract_eu_from_world(
    world_json_file: str, nuts_json_file: str, with_provinces: bool = False
):
    # Some countries are not in the dataset, but we want them displayed
    file_str = Path(world_json_file).read_text()
    world_json = json.loads(file_str)["features"]

    file_str = Path(nuts_json_file).read_text()
    nuts_json = json.loads(file_str)["features"]

    countries = get_countries()
    if with_provinces:
        known_features = country_features(nuts_json, countries)
        missing_countries = country_to_nuts(
            world_json,
            countries=[
                Country(iso="MD", name="Moldovia"),
                Country(iso="BY", name="Belarus"),
            ],
        )
        known_features.extend(missing_countries)
    else:
        additional_countries = [
            Country(iso="UK", name="Great Britain"),
            Country(iso="DK", name="Denmark"),
            Country(iso="NO", name="Norway"),
            Country(iso="FI", name="Finland"),
            Country(iso="UA", name="Ukraine"),
            Country(iso="EL", name="Greece"),
            Country(iso="MK", name="North Macedonia"),
            Country(iso="TR", name="Türkiye"),
        ]
        ignore_countries = [
            Country(iso="MX", name="Mexico"),
        ]

        known_features = world_features(
            world_json,
            countries,
            extra_countries=additional_countries,
            ignore_countries=ignore_countries,
        )
    geojson_known = {"type": "FeatureCollection", "features": known_features}
    return geojson_known


def country_to_nuts(world_json: dict, countries: list[Country]) -> list:
    """Takes a world border and converts it to a single nuts code border"""
    country_features = world_features(world_json, countries)
    for n, feature in enumerate(country_features):
        props = feature["properties"]
        # iso code related
        country_id = props["CNTR_ID"]
        country_as_nuts = f"{country_id}0"
        country_features[n]["properties"]["NUTS_ID"] = country_as_nuts
        country_features[n]["properties"]["CNTR_CODE"] = country_id
        country_features[n]["properties"]["LEVL_CODE"] = 1

        # name related
        country_name = props["NAME_ENGL"]
        country_features[n]["properties"]["NAME_LATN"] = country_name
        country_features[n]["properties"]["NUTS_NAME"] = country_name
    ic(country_features)
    return country_features


def country_features(in_json: Dict, countries: list[Country]) -> list:
    country_iso_codes = [i.iso for i in countries]
    levels_map = {
        "AT": 2,
        "IT": 2,
        "CH": 3,
        "FR": 2,
        "PL": 2,
        "RO": 3,
        "SK": 3,
        "CZ": 3,
        "PT": 3,
        "ES": 2,
        "SI": 2,
    }
    known_features = []
    for world_entry in in_json:
        default_level = 1
        props = world_entry["properties"]
        country_code = props["CNTR_CODE"]
        if country_code not in country_iso_codes:
            continue
        # Only main level
        if country_code.upper() in levels_map.keys():
            default_level = levels_map[country_code]

        level = props["LEVL_CODE"]
        if level != default_level:
            continue
        known_features.append(world_entry)
    return known_features


def world_features(
    in_json: Dict,
    countries: list[Country],
    extra_countries: list[Country] = [],
    ignore_countries: list[Country] = [],
) -> list:
    known_features = []

    country_iso_codes = [i.iso for i in countries]
    extra_iso_codes = [i.iso for i in extra_countries]
    ignore_codes = [i.iso for i in ignore_countries]
    ic(country_iso_codes)
    ic(extra_iso_codes)
    for world_entry in in_json:
        props = world_entry["properties"]
        country_code = props["CNTR_ID"]
        # Skip if not required
        if (
            country_code not in country_iso_codes
            and country_code not in extra_iso_codes
        ):
            continue
        # Skip if ignore
        if country_code in ignore_codes:
            continue
        ic(f"is in {country_code}")

        # Mark extra country as disabled
        if country_code in extra_iso_codes:
            props["DISABLED"] = True
        else:
            props["DISABLED"] = False

        # Now add to list
        known_features.append(world_entry)
    return known_features


def convert_geojson():
    eu_geojson = extract_eu_from_world(
        world_json_file="./CNTR_RG_20M_2024_4326.geojson",
        nuts_json_file="./NUTS_RG_20M_2024_4326.geojson",
        with_provinces=True,
    )
    with open("assets/geo/eu-nuts.geojson", "w", encoding="utf-8") as w:
        w.write(json.dumps(eu_geojson, indent=2, ensure_ascii=False))
    eu_geojson = extract_eu_from_world(
        world_json_file="./CNTR_RG_20M_2024_4326.geojson",
        nuts_json_file="./NUTS_RG_20M_2024_4326.geojson",
    )
    with open("assets/geo/eu-borders.geojson", "w", encoding="utf-8") as w:
        w.write(json.dumps(eu_geojson, indent=2, ensure_ascii=False))


def short():
    file_str = Path("assets/data.json").read_text()
    inj = json.loads(file_str)
    out = []
    for i in inj:
        hol = i.get("state_holidays")
        if hol == []:
            continue
        country = i["country"].upper()
        country_entries = []
        for h in hol:
            iso = h.get("iso")
            code = h.get("code")
            ic(f"Iso: {iso}, Code: {code}")
            outdict = {"iso": iso, "code": code}
            country_entries.append(outdict)
        out.append({"country": country, "codes": country_entries})
    final = {"all-codes": out}
    with open("assets/geo/data-for-map.json", "w", encoding="utf-8") as w:
        w.write(json.dumps(final, indent=2))


if __name__ == "__main__":
    convert_geojson()
    # # short()
    sys.exit()
    countries = get_countries()
    # sys.exit()
    # countries = [Country(iso="AD", code="AL", name="Albania", name_en="Spain")]
    country_list = []
    for country in countries:
        all_hols_list: list[SubdivionHolidays] = []
        subs = get_subdivions(country.iso)
        for sub in subs:
            sub_hols_list: list[Holiday] = []
            # get via sub code first
            school_hols = get_holidays(HolidayType.SCHOOL, country.iso, sub.code)
            if school_hols == []:
                # if sub code does not return, then use iso
                school_hols = get_holidays(HolidayType.SCHOOL, country.iso, sub.iso)
            # if still empty, print it
            if school_hols == []:
                print(f"School holidays empty for sub: {sub}")
            pub_hols = get_holidays(HolidayType.PUBLIC, country.iso, sub.code)
            if pub_hols == []:
                pub_hols = get_holidays(HolidayType.PUBLIC, country.iso, sub.iso)
            if pub_hols == []:
                print(f"Pub holidays empty for sub: {sub}")
            sub_hols_list.extend(school_hols)
            sub_hols_list.extend(pub_hols)
            # assert sub.iso is not None, f"Could not get iso for sub: {sub}"
            sub_holidays = SubdivionHolidays(
                name=sub.name, iso=sub.iso, code=sub.code, holidays=sub_hols_list
            )
            all_hols_list.append(sub_holidays)
        # to dataclass
        all_hols = AllSubdivionHolidays(
            state_holidays=all_hols_list, country=country.iso.lower()
        )
        country_list.append(asdict(all_hols))

    outfile = "assets/data.json"
    with open(outfile, "w", encoding="utf-8") as w:
        w.write(json.dumps(country_list, indent=2, ensure_ascii=False))

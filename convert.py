import csv
import json
from pathlib import Path
from dataclasses import dataclass, asdict


@dataclass
class Entry:
    start: str
    end: str
    label: str
    comment: str


@dataclass
class AllEntries:
    id: str
    entries: list[Entry]


if __name__ == "__main__":
    # Declare file inputs and outputs
    filename = "fcal_nrw.csv"
    file = Path(filename)
    outfile = f"{file.stem}.json"
    assert not Path(outfile).is_file(), "json already exists"

    with open(filename, "r") as f:
        # Read
        reader = csv.reader(f, delimiter=";")
        raw_entries = []
        for n, row in enumerate(reader):
            if n == 0:
                continue
            assert len(row) == 4, "CSV must contain 4 columns"
            # Make entries readable
            entry = Entry(
                start=row[0],
                end=row[1],
                label=row[2],
                comment=row[3],
            )
            raw_entries.append(entry)
        # Gather all entries
        all_entries = AllEntries(id=file.stem, entries=raw_entries)
        # Write to file

        with open(outfile, "w", encoding="utf-8") as w:
            w.write(json.dumps(asdict(all_entries)))

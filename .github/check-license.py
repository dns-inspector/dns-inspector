"""
DNS Inspector
Copyright (C) 2025 Ian Spence

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""
from pathlib import Path
from datetime import datetime
import subprocess
import sys

license_header_template = ""
with open(".github/license-header.txt", "r") as file:
    license_header_template = file.read().rstrip()

def get_license_header(year):
    return license_header_template.replace("##YEAR##", year)

def get_file_year(filepath):
    year = datetime.now().strftime("%Y")
    try:
        result = subprocess.run(["git", "--no-pager", "log", "-1", "--pretty=%ci", "--", filepath], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        date = result.stdout.decode('utf-8')
        year = date.split("-")[0]
    except Exception as e:
        pass
    return year

def check_file_header(filepath, offset, prefixes):
    contents = ""
    with open(filepath, "r") as file:
        contents = file.read()

    lines = contents.split("\n")

    year = get_file_year(filepath)

    header = get_license_header(year)
    header_lines = header.split('\n')

    if len(lines) + offset < len(header_lines):
        return False

    i = 0
    while i < len(header_lines)-1:
        any_match = False
        for prefix in prefixes:
            if lines[i + offset] == prefix + header_lines[i]:
                any_match = True
                break
        if not any_match:
            return False
        i = i + 1

    return True

all_passed = True

for source_dir in [ "dns-inspector" ]:
    swift_files = list(Path(source_dir).rglob("*.[Ss][Ww][Ii][Ff][Tt]"))

    for filepath in swift_files:
        if not check_file_header(filepath, 0, ["//", "// "]):
            print(str(filepath) + ": Invalid license header", file=sys.stderr)
            all_passed = False

if not all_passed:
    exit(1)

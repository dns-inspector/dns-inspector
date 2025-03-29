"""
DNS Inspector
Copyright (C) Ian Spence and other DNS Inspector Contributors

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

license_header_template = """DNS Inspector
Copyright (C) Ian Spence and other DNS Inspector Contributors

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>."""

def check_file_header(filepath, offset, prefixes):
    contents = ""
    with open(filepath, "r") as file:
        contents = file.read()

    lines = contents.split("\n")

    header = license_header_template
    header_lines = header.split('\n')

    if len(lines) + offset < len(header_lines):
        print(str(filepath) + ": Missing license header")
        return False

    i = 0
    while i < len(header_lines)-1:
        any_match = False
        for prefix in prefixes:
            if lines[i + offset] == prefix + header_lines[i]:
                any_match = True
                break
        if not any_match:
            print(str(filepath) + ":" + str(i) + ": Got '" + lines[i + offset] + "' Expected '" + prefix + header_lines[i] + "'")
            return False
        i = i + 1

    return True

all_passed = True

for source_dir in [ "dns-inspector", ".github" ]:
    swift_files = list(Path(source_dir).rglob("*.[Ss][Ww][Ii][Ff][Tt]"))
    go_files = list(Path(source_dir).rglob("*.[Gg][Oo]"))
    py_files = list(Path(source_dir).rglob("*.[Pp][Yy]"))

    for filepath in swift_files:
        if not check_file_header(filepath, 0, ["// ", "//"]):
            print(str(filepath) + ": Invalid license header", file=sys.stderr)
            all_passed = False

    for filepath in go_files:
        if not check_file_header(filepath, 1, [""]):
            print(str(filepath) + ": Invalid license header", file=sys.stderr)
            all_passed = False

    for filepath in py_files:
        if not check_file_header(filepath, 1, [""]):
            print(str(filepath) + ": Invalid license header", file=sys.stderr)
            all_passed = False

if not all_passed:
    exit(1)

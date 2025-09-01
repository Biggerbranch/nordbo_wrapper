#!/usr/bin/env python3
import sys
import json
import pathlib
import datetime
import re

if len(sys.argv) != 2:
    sys.stderr.write("Usage: logs_to_json.py logfile\n")
    sys.exit(1)

logfile = pathlib.Path(sys.argv[1])
timestamp_re = re.compile(r"\[(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z)\]")

with logfile.open("r", errors="ignore") as f:
    for lineno, line in enumerate(f, start=1):
        line = line.strip()
        if not line:
            continue

        match = timestamp_re.search(line)
        if match:
            ts = match.group(1)
        else:
            ts = datetime.datetime.utcnow().isoformat() + "Z"

        entry = {
            "timestamp": ts,
            "logfile": str(logfile.name),
            "message": line,
            "line_number": lineno
        }
        print(json.dumps(entry))

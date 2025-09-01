#!/usr/bin/env python3
import sys
import json
from pathlib import Path
import subprocess

if len(sys.argv) != 5:
    sys.stderr.write("Usage: parse_core.py core_file timestamp binary gdb_log\n")
    sys.exit(1)

core_file = Path(sys.argv[1])
timestamp = sys.argv[2]
binary = sys.argv[3]
gdb_log = Path(sys.argv[4])

# Kør GDB i batch-mode for at få symboliseret backtrace
try:
    gdb_output = subprocess.run(
        ["gdb", "--batch", "-ex", "thread apply all bt full", binary, str(core_file)],
        capture_output=True,
        text=True,
        check=True
    ).stdout
except subprocess.CalledProcessError as e:
    gdb_output = f"Failed to run GDB: {e}"

# Gem GDB output til logfil (valgfrit)
try:
    gdb_log.parent.mkdir(parents=True, exist_ok=True)
    gdb_log.write_text(gdb_output)
except Exception as e:
    print(f"[WARN] Could not write GDB log: {e}", file=sys.stderr)

# Konstruer JSON objekt
obj = {
    "timestamp": timestamp,
    "core_file": core_file.name,
    "binary": binary,
    "backtrace": gdb_output
}

# Print JSON som én linje (NDJSON-kompatibel)
print(json.dumps(obj, ensure_ascii=False))

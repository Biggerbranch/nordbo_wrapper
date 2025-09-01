#!/usr/bin/env python3
import sys, json, requests, os

if len(sys.argv) != 2:
    sys.stderr.write("Usage: indexer.py ndjson_file\n")
    sys.exit(1)

ndjson_file = sys.argv[1]

ES_HOST = os.environ.get("ES_HOST", "https://localhost:9200")
ES_USER = os.environ.get("ES_USER", "elastic")
ES_PASS = os.environ.get("ES_PASS", "changeme")
ES_INDEX = os.environ.get("ES_INDEX", "crash_logs")

bulk_payload = ""
with open(ndjson_file, "r", errors="ignore") as f:
    for line in f:
        line = line.strip()
        if not line:
            continue
        bulk_payload += json.dumps({"index": {"_index": ES_INDEX}}) + "\n"
        bulk_payload += line + "\n"

resp = requests.post(
    f"{ES_HOST}/_bulk",
    data=bulk_payload,
    headers={"Content-Type": "application/x-ndjson"},
    auth=(ES_USER, ES_PASS),
    verify=False
)

result = resp.json()
if result.get("errors"):
    sys.stderr.write("Some documents failed to index:\n")
    for item in result["items"]:
        if "error" in item["index"]:
            sys.stderr.write(f"{item['index']['error']}\n")
    sys.exit(1)

print(f"Indexed NDJSON file {ndjson_file} to {ES_INDEX}")

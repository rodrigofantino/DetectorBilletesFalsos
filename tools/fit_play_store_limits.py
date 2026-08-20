import csv
import sys

path = sys.argv[1]

def fit(text: str, limit: int) -> str:
    text = text.replace('â€¦', '…')
    if len(text) <= limit:
        return text
    candidate = text[: limit - 1]
    space = candidate.rfind(' ')
    if space >= max(1, limit - 18):
        candidate = candidate[:space]
    return candidate.rstrip()[: limit - 1] + '…'

with open(path, encoding='utf-8-sig', newline='') as handle:
    rows = list(csv.DictReader(handle))

for row in rows:
    row['title'] = fit(row['title'], 30)
    row['short_description'] = fit(row['short_description'], 80)

with open(path, 'w', encoding='utf-8-sig', newline='') as handle:
    writer = csv.DictWriter(handle, fieldnames=['language', 'title', 'short_description', 'full_description'])
    writer.writeheader()
    writer.writerows(rows)

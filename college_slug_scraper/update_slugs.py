import csv

g = open('college_slugs.csv', 'r')
college_slugs = csv.DictReader(
    g, fieldnames=['draft_year', 'draft_pick', 'name', 'college_slug'])

f = open('../rookie_scraper/CSV/rookie_names_year.csv')
rookies = csv.DictReader(
    f, fieldnames=['draft_year', 'draft_pick', 'name', 'slug'])

h = open('college_slugs_new.csv', 'w')
slugs_with_slugs = csv.DictWriter(h, fieldnames=['draft_year', 'draft_pick', 'name', 'slug', 'college_slug'])

while True:
  try:
    college_slug = next(college_slugs)
    rookie_slug = next(rookies)
  except:
    break

  row = {}
  for r in college_slugs.fieldnames:
    row[r] = college_slug[r]
  row['slug'] = rookie_slug['slug']

  slugs_with_slugs.writerow(row)

f.close()
g.close()
h.close()
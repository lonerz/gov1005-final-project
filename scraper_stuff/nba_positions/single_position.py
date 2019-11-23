import csv

fn = ['name', 'slug', 'draft_year', 'draft_pick',
      'season', 'team_id', 'lg_id', 'pos']

g = open('nba_positions.csv')
positions = csv.DictReader(g)

f = open('nba_single_position.csv', 'w')
single_position = csv.DictWriter(f, fieldnames=fn)
single_position.writeheader()

seen = {}

for row in positions:
    slug = row['slug']

    if slug not in seen:
        seen[slug] = 1
        single_position.writerow(row)

f.close()
g.close()

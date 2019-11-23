import csv

f = open('nba_total_stats_wo_tot.csv')
stats = csv.DictReader(f)

fn = ['name', 'slug', 'draft_year', 'draft_pick',
      'season', 'team_id', 'lg_id', 'pos']

g = open('nba_positions.csv', 'w')
positions = csv.DictWriter(
    g, fieldnames=fn)
positions.writeheader()

for row in stats:
    new_row = {}
    for name in fn:
        new_row[name] = row[name]
    positions.writerow(new_row)

f.close()
g.close()

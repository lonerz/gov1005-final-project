import csv

f = open('CSV/player_per_game_stats.csv', 'r')
stats = csv.DictReader(f)

g = open('player_per_game_stats_tot.csv', 'w')
tots = csv.DictWriter(g, fieldnames=stats.fieldnames)
tots.writeheader()

last = {}

for row in stats:
    if row.get('slug') == last.get('slug') and row.get('season') == last.get('season'):
        continue

    if row.get('team_id') == 'TOT':
        last['slug'] = row.get('slug')
        last['season'] = row.get('season')

    tots.writerow(row)

f.close()
g.close()

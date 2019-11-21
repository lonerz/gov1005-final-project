import requests
from bs4 import BeautifulSoup
import lxml.html
import csv

PLAYER_URL = "https://www.basketball-reference.com/players/{}/{}.html"

f = open('../rookie_scraper/rookie_names_year.csv')
rookies = csv.DictReader(
    f, fieldnames=['draft_year', 'draft_pick', 'name', 'slug'])

# headers of the tables in basketball reference
headers = ['season', 'age', 'team_id', 'lg_id', 'pos', 'g', 'gs', 'mp_per_g', 'fg_per_g', 'fga_per_g', 'fg_pct', 'fg3_per_g', 'fg3a_per_g', 'fg3_pct',
           'fg2_per_g', 'fg2a_per_g', 'fg2_pct', 'efg_pct', 'ft_per_g', 'fta_per_g', 'ft_pct', 'orb_per_g', 'drb_per_g', 'trb_per_g', 'ast_per_g', 'stl_per_g', 'blk_per_g', 'tov_per_g', 'pf_per_g', 'pts_per_g']

# headers and CSV we are going to write
write_fieldnames = ['name', 'slug', 'draft_year', 'draft_pick'] + headers
g = open('player_per_game_stats.csv', 'w')
stats = csv.DictWriter(g, fieldnames=write_fieldnames)
stats.writeheader()


def verify_nba_row(row):
    lg = row.find(attrs={'data-stat': 'lg_id'})

    if not lg:
        return False

    season = row.find(attrs={'data-stat': 'season'})

    if not season:
        return False

    # we only want NBA stats and nothing of the current season
    return lg.get_text() == 'NBA' and season.get_text() != '2019-20'


cont = True

# iterate over all rookies now and grab all the stats
for rookie in rookies:
    player_slug = rookie['slug']

    if player_slug == 'hamilve01':
        cont = False

    if cont:
        continue

    print(player_slug)

    # grab the page
    page = requests.get(PLAYER_URL.format(player_slug[0], player_slug))
    assert(page.status_code == 200)

    # pass the page contents into beautiful soup
    soup = BeautifulSoup(page.content, 'lxml')
    soup.prettify()

    # look at per game stats
    per_game_stats = soup.find('div', id='all_per_game')

    if not per_game_stats:
        continue

    # go through each season now
    for row in per_game_stats.find('tbody').find_all('tr'):
        # skip if it's a row we don't care about
        if not verify_nba_row(row):
            continue

        # set the values to whatever is in the rookie CSV
        values = {}
        for header in rookie:
            values[header] = rookie[header]

        # then add on the really nice per_game stats :)
        for header in headers:
            attr = row.find(attrs={'data-stat': header})
            value = None

            if attr:
                value = attr.get_text()

            values[header] = value

        stats.writerow(values)

f.close()
g.close()

import requests
from bs4 import BeautifulSoup, Comment
import lxml.html
import csv

PLAYER_URL = "https://www.basketball-reference.com/players/{}/{}.html"

f = open('../rookie_scraper/CSV/rookie_names_year.csv')
rookies = csv.DictReader(
    f, fieldnames=['draft_year', 'draft_pick', 'name', 'slug'])

# headers of the tables in basketball reference
headers = ['season', 'age', 'team_id', 'lg_id', 'pos', 'g', 'gs', 'mp', 'fg', 'fga', 'fg_pct', 'fg3', 'fg3a', 'fg3_pct',
           'fg2', 'fg2a', 'fg2_pct', 'efg_pct', 'ft', 'fta', 'ft_pct', 'orb', 'drb', 'trb', 'ast', 'stl', 'blk', 'tov', 'pf', 'pts']

# headers and CSV we are going to write
write_fieldnames = ['name', 'slug', 'draft_year', 'draft_pick'] + headers
g = open('player_total_stats1.csv', 'w')
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
    # soup.prettify()

    # look at totals stats
    totals_stats = soup.find('div', id='all_totals')

    if not totals_stats:
        continue

    comment = totals_stats.find(text=lambda text: isinstance(text, Comment))
    soup = BeautifulSoup(comment, 'lxml')

    # new_headers = []
    # for header in subsoup.find('thead').find_all('th'):
    #     print(header.attrs.get('data-stat'))
    #     new_headers.append(header.attrs.get('data-stat'))
    # print(new_headers)

    # go through each season now
    for row in soup.find('tbody').find_all('tr'):
        # skip if it's a row we don't care about
        if not verify_nba_row(row):
            continue

        # set the values to whatever is in the rookie CSV
        values = {}
        for header in rookie:
            values[header] = rookie[header]

        # then add on the really nice totals stats :)
        for header in headers:
            attr = row.find(attrs={'data-stat': header})
            value = None

            if attr:
                value = attr.get_text()

            values[header] = value

        stats.writerow(values)

f.close()
g.close()

import requests
from bs4 import BeautifulSoup
import lxml.html
import csv

PLAYER_URL = "https://www.sports-reference.com/cbb/players/{}.html"

f = open('../college_slug_scraper/college_slugs.csv')
rookies = csv.DictReader(
    f, fieldnames=['draft_year', 'draft_pick', 'name', 'slug', 'college_slug'])

# headers of the tables in basketball reference
headers = ['season', 'school_name', 'conf_abbr', 'g', 'gs', 'mp_per_g', 'fg_per_g', 'fga_per_g', 'fg_pct', 'fg2_per_g', 'fg2a_per_g', 'fg2_pct', 'fg3_per_g', 'fg3a_per_g',
           'fg3_pct', 'ft_per_g', 'fta_per_g', 'ft_pct', 'orb_per_g', 'drb_per_g', 'trb_per_g', 'ast_per_g', 'stl_per_g', 'blk_per_g', 'tov_per_g', 'pf_per_g', 'pts_per_g', 'sos-dum', 'sos']

# headers and CSV we are going to write
write_fieldnames = ['name', 'slug', 'college_slug',
                    'draft_year', 'draft_pick'] + headers
g = open('college_per_game_stats.csv', 'w')
stats = csv.DictWriter(g, fieldnames=write_fieldnames)
stats.writeheader()

i = 0

# iterate over all rookies now and grab all the stats
for rookie in rookies:
    college_slug = rookie.get('college_slug')

    if not college_slug:
        continue

    # print(college_slug)

    i += 1

    if i % 100 == 0:
        print("we made it to {}!".format(i))

    # grab the page
    page = requests.get(PLAYER_URL.format(college_slug))
    assert(page.status_code == 200)

    # pass the page contents into beautiful soup
    soup = BeautifulSoup(page.content, 'lxml')
    soup.prettify()

    # look at per game stats
    per_game_stats = soup.find('div', id='all_players_per_game')

    # get new headers
    # new_headers = []
    # for header in per_game_stats.find('thead').find_all('th'):
    #     new_headers.append(header.attrs['data-stat'])
    # print(new_headers)

    if not per_game_stats:
        continue

    # go through each season now
    for row in per_game_stats.find('tbody').find_all('tr'):
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

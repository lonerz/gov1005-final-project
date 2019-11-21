import requests
from bs4 import BeautifulSoup, Comment
import lxml.html
import csv
from unidecode import unidecode

PLAYER_URL = "https://www.sports-reference.com/cbb/players/{}.html"
OTHER_URL = "https://www.basketball-reference.com/players/{}/{}.html"

f = open('../rookie_scraper/CSV/rookie_names_year.csv')
rookies = csv.DictReader(
    f, fieldnames=['draft_year', 'draft_pick', 'name', 'slug'])

g = open('college_slugs.csv', 'w')
college_slugs = csv.DictWriter(
    g, fieldnames=['draft_year', 'draft_pick', 'name', 'college_slug'])

seen = dict()

i = 0

# iterate over all rookies now and grab all the stats
for rookie in rookies:
    # create a new row
    row = {}
    for r in rookies.fieldnames:
        row[r] = rookie[r]

    player_name = rookie['name']
    player_slug = rookie['slug']

    i += 1
    if i % 100 == 0:
        print('we made it: {}'.format(i))

    # deal with addendums...
    addendums = [' Jr.', ' III']
    for addendum in addendums:
        if addendum in player_name:
            player_name = player_name.replace(addendum, addendum[1:])

    cleaned_name = ''

    for c in player_name:
        if c.isalpha() or c == ' ' or c == '-':
            cleaned_name += c

    if cleaned_name not in seen:
        seen[cleaned_name] = 0

    seen[cleaned_name] += 1

    url_format = cleaned_name.lower().replace(
        ' ', '-') + '-' + str(seen[cleaned_name])

    # grab the page
    page = requests.get(PLAYER_URL.format(url_format))

    if page.status_code != 200:
        ascii_str = unidecode(player_name)

        if ascii_str != player_name:
            url_format = ascii_str.lower().replace(
                ' ', '-') + '-' + str(seen[cleaned_name])
            page = requests.get(PLAYER_URL.format(url_format))

    if page.status_code != 200 and player_name not in ['Mitchell Robinson', 'Stephen Jackson', 'Chris Anstey']:
        new_page = requests.get(OTHER_URL.format(player_slug[0], player_slug))
        soup = BeautifulSoup(new_page.content, 'lxml')

        meta = soup.find('div', id='meta')
        if 'college' in meta.get_text().lower():
            print("FAILED: {}".format(player_name))
            print("URL: {}".format(PLAYER_URL.format(url_format)))
    
    if page.status_code == 200:
        row['college_slug'] = url_format

    college_slugs.writerow(row)

f.close()
g.close()

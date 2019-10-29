import requests
from bs4 import BeautifulSoup
import lxml.html
import csv

DRAFT_URL = "https://www.basketball-reference.com/draft/NBA_{}.html"

rookie_info_file = open('rookie_names_year.csv', mode='w')
rookie_info_writer = csv.writer(
    rookie_info_file, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)

# chose 1980 because don't want to deal with ABA statistics (ABA ceased in 1976)
for year in range(1980, 2020):
    print(year)

    # grab page contents
    page = requests.get(DRAFT_URL.format(year))
    assert(page.status_code == 200)

    # pass into beautiful soup
    soup = BeautifulSoup(page.content, 'lxml')
    soup.prettify()

    # get the stats table
    table = soup.find('table', id='stats')
    assert(table)

    table_body = table.find('tbody')
    rows = table_body.find_all('tr')

    for row in rows:
        # grab the column with the player name
        name_column = row.find(attrs={'data-stat': 'player'})

        # if it is not a player row
        if not name_column:
            continue

        # if the player does not have stats (meaning they got drafted, but never played)
        link_slug = name_column.attrs.get('data-append-csv')
        if not link_slug:
            continue

        # grab the player name
        name = name_column.get_text()
        assert(name)

        # grab the player overall pick
        pick_column = row.find(attrs={'data-stat': 'pick_overall'})
        pick = pick_column.get_text()
        assert(pick)

        # print(year, pick, name, link_slug)
        rookie_info_writer.writerow([year, pick, name, link_slug])

rookie_info_file.close()

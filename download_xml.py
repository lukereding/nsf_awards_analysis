import os
import requests
import bs4
import re
import zipfile
import io

# create new folder
if not os.path.exists('./data'):
    os.makedirs('./data')

os.chdir('./data')

url = "https://www.nsf.gov/awardsearch/download.jsp"

# download the page
res = requests.get(url)

res.raise_for_status()

# find the zip file links on the page
soup = bs4.BeautifulSoup(res.text, 'html.parser')

# extract the link part, adding base url
links = soup.find_all("a", href = re.compile("download.*"))
links_correct = []
for link in links:
    links_correct.append('https://www.nsf.gov/awardsearch/' + link['href'])

# exclude the first link
for i, link in enumerate(links_correct[1:]):
    print("processing link {} of {}".format(i, len(links_correct[1:])))
    # from https://stackoverflow.com/questions/9419162/python-download-returned-zip-file-from-url
    res = requests.get(link)
    z = zipfile.ZipFile(io.BytesIO(res.content))
    z.extractall()


#
# import requests, zipfile, io
# r = requests.get(zip_file_url)
# z = zipfile.ZipFile(io.BytesIO(r.content))
# z.extractall()

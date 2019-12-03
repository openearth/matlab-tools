import json
import urllib2
import lxml.html
import re


def get_latest_url():
    domain = "http://cfconventions.org/"
    url = "".join([domain, "standard-names.html"])
    request = urllib2.urlopen(url)
    txt = request.read()
    match = re.search('(?<=href=")(?P<href>Data/cf-standard-names/(?P<version>\d+)/src/cf-standard-name-table.xml)(?=")', txt)
    if match:
        groupdict = match.groupdict()
        return "".join([domain, groupdict["href"]])
    else:
        return None


def entry2dict(entry, verbose=True):
    standard_name = entry.attrib["id"]
    units = entry.find('.//canonical_units').text
    description = entry.find('.//description').text
    if verbose:
        print(standard_name)
    return {"standard_name": standard_name,
            "units": units,
            "description": description}


def download(url, outfile="cf-standard-name-table.json"):
    request = urllib2.urlopen(url)

    tree = lxml.html.fromstring(request.read())

    lst = []

    entries = tree.findall('.//entry')
    for entry in entries:
        lst.append(entry2dict(entry))
    for alias in tree.findall('.//alias'):
        entry_id = alias.find('.//entry_id').text
        entry = tree.find('.//entry[@id="%s"]' % entry_id)
        lst.append(entry2dict(entry))

    with open(outfile, 'w') as fobj:
        json.dump(lst, fobj)


if __name__ == '__main__':
    url = get_latest_url()
    download(url)
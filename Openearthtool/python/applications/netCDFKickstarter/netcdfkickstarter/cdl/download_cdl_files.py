import os
import urllib2


def download(url, filename=None):
    data = urllib2.urlopen(url)
    print(data.headers['content-type'])
    txt_utf8 = data.read().decode("utf-8")
    txt_ascii = txt_utf8.encode("ascii", "ignore")
    with open(filename, 'w') as fobj:
        fobj.write(txt_ascii)


if __name__ == '__main__':
    cdl_files = [f for f in os.listdir(os.path.dirname(__file__)) if f.endswith('.cdl')]
    print(cdl_files)
    for cdl in cdl_files:
        download("https://www.nodc.noaa.gov/data/formats/netcdf/v2.0/%s" % cdl, filename=cdl)
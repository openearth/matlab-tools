# -*- coding: utf-8 -*-
"""
Created on Wed Sep 25 17:25:01 2013

$Id: reposexplorer.py 11803 2015-03-13 13:52:56Z heijer $
$Date: 2015-03-13 06:52:56 -0700 (Fri, 13 Mar 2015) $
$Author: heijer $
$Revision: 11803 $
$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/OpenEarthTools/openearthtools/misc/reposexplorer.py $

@author: heijer
"""

import subprocess
import re
import os
import argparse
import urllib

def svnlist(url=None, verbose=True):
    url = urllib.quote(url, ':/') # escape special characters
    print url
    if verbose:
        vrbstr = '-v'
    else:
        vrbstr = ''
    cmd = 'svn list %s "%s"'%(vrbstr, url)
    return subprocess.check_output(cmd, shell=True)

def svnlog(url=None, limit=None):
    url = urllib.quote(url, ':/') # escape special characters
    if limit:
        lmtstr = '-l %i'%limit
    else:
        lmtstr = ''
    cmd = 'svn log %s "%s"'%(lmtstr, url)
    return subprocess.check_output(cmd, shell=True)

def astxt(level, url, tail, user_re, lg, rev, nfiles, exts, ndirs, isfile):
    indent = '   '*level
    if level==0:
        print indent + 'root: ' + url
    else:
        print indent + 'path: ' + tail
    print indent + 'contributors: ' + ' '.join(list(set(user_re.findall(lg))))
    print indent + 'revisions: %i:%i'%(min(rev), max(rev))
    if nfiles>0:
        print indent + 'files: %i'%nfiles
        print indent + 'extensions: ' + ' '.join(list(set(exts)))
    if ndirs>0:
        print indent + 'folders: %i'%isfile.count(False)
    print

def ascsv(level, url, tail, user_re, lg, rev, nfiles, exts, ndirs, isfile):
    if level==0:
        path = url
    else:
        path = tail
    print ",".join([path, ' '.join(list(set(user_re.findall(lg)))), '%i:%i'%(min(rev), max(rev)),
                    '%i'%nfiles, ' '.join(list(set(exts))), '%i'%isfile.count(False)])

def walk(url=None, limit=0, baseurl=None, outformat=None):
    lst = svnlist(url, verbose=True).split('\n')[1:-1]
    if baseurl:
        tail = re.sub(baseurl, '', url)
        level = len(re.findall('/', tail))
    else:
        tail = url
        level = 0
    lg = svnlog(url)
    user_re = re.compile('(?<=\d\s\|\s)[a-z_@]*?(?=\s\|)')
    rev_re = re.compile('(?<=r)\d+(?=\s\|)')
    rev = map(int, rev_re.findall(lg))
    dirlisting = [d.split()[-1] for d in lst]
    isfile = map(lambda dl: re.search('/$', dl)==None, dirlisting)
    nfiles = isfile.count(True)
    ndirs = isfile.count(False)
    if nfiles > 0:
        exts,szs = zip(*[[os.path.splitext(d)[-1],d.split()[2]] for b,d in zip(isfile,lst) if b])
    elif nfiles+ndirs == 0:
        return
    else:
        exts = ''

    if outformat == 'txt':
        astxt(level, url, tail, user_re, lg, rev, nfiles, exts, ndirs, isfile)
    elif outformat == 'csv':
        ascsv(level, url, tail, user_re, lg, rev, nfiles, exts, ndirs, isfile)
    else:
        Exception('output format "%s" not supported'%outformat)

    if limit==None or level<limit:
        for d in dirlisting:
            if re.search('(?<!\.)/$', d):
                walk(url+d, limit=limit, baseurl=baseurl,outformat=outformat)

if __name__ == "__main__":
    url = 'https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/OpenEarthTools/'
    output = 'txt'
    parser = argparse.ArgumentParser(description='Get overview of subversion repository structure and its contents.')
    parser.add_argument('--url', '-u', help='root url or path to explore', default=url, type=str)
    parser.add_argument('--limit', '-l', default=2, type=int, help='depth limitation')
    parser.add_argument('--outputformat', '-o', default=output, type=str, help='output format {txt csv}')
    args = parser.parse_args()
    
    walk(url=args.url, limit=args.limit, baseurl=args.url, outformat=args.outputformat)
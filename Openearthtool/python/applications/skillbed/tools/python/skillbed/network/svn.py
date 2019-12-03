###############################################################################
# modules                                                                     #
###############################################################################

import os, time

from datetime       import datetime

###############################################################################
# functions                                                                   #
###############################################################################

def initialize():
    'Check whether svn command line is installed'

    #try:
    #    os_call_svn('help','')
    #    return True
    #except:
    #    return False

def repository(path):
    'Retrieve repository corresponding to working copy'

    url = ''

    try:
        m = os_call_svn('info',path)
        urlLine = next((s for s in m if s.startswith('URL:')),None)
        if (not(a == None)):
            url = urlLine.replace('URL: ','').strip()
    except:
        pass
    
    return url

def revision(path):
    'Retrieve current subversion revision of path or url'

    rev = 0

    try:
        m = os_call_svn('info',path)
        revisionLine = next((s for s in m if s.startswith('Revision:')),None)
        if (not(a == None)):
            rev = int(float(revisionLine.replace('Revision: ','')))
    except:
        pass
    
    return rev

def changelog(url, revision=False, interval=7):
    return False

def checkout(url, path):
    'Checks out Subversion repository to current path or updates if already available'

    try:
        if is_wc(path):
            
            purl = repository(path)

            ml = min(len(purl), url)

            if purl[0:ml] == url[0:ml]:
                os_call_svn('up',path,True)
            else:
                return False
        else:
            os_call_svn('co','%s %s' %(url,path),True)

        return True
    except:
        return False

def is_wc(path):
    'Check if directory is a valid Subversion working copy'

    if len(path)>0 and os.path.exists(os.path.join(path, '.svn')):
        return True
    else:
        return False

def is_uptodate(url, path):
    'Check if directory is up-to-date'

    if is_wc(path):
        if revision(url) == revision(path):
            return True
    else:
        revfile = os.path.join(path, 'revision.txt')
        if os.path.exists(revfile):

            f = open(revfile, 'r')
            rev = int(f.read())
            f.close()

            if revision(url) == rev:
                return True

    return False

def os_call_svn(command, argument, appendUser = False):
    import subprocess
    if (appendUser):
        proc = subprocess.Popen(["svn", command, argument], stdout=subprocess.PIPE, shell=True)
        #proc = subprocess.Popen(["svn", command, argument, '--username %s --password %s'%(os.environ['SVN_USERNAME'],os.environ['SVN_PASSWORD'])], stdout=subprocess.PIPE, shell=True)
    else:
        proc = subprocess.Popen(["svn", command, argument], stdout=subprocess.PIPE, shell=True)
    (out, err) = proc.communicate()
    return out.splitlines()
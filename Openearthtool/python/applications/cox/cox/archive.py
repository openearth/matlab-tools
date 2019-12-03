import os
import time
import logging
import shutil
from datetime import date

camtype = 'c1'

# image path options
root    = 'Z:/stream/'
stream  = 'Y:/'

# create root directory
if not os.path.exists(root):
    os.makedirs(root)
    
archive = os.path.join(root, '_archive')
    
if not os.path.exists(archive):
    os.makedirs(archive)

# get yesterdays date
posix_midnight = int(time.mktime(date.today().timetuple()))

# initialize log
logfile        = '%d.%s.copy.log' % (posix_midnight, camtype)
logging.basicConfig(filename=os.path.join(root, logfile), 
    format='%(asctime)s %(message)s [%(levelname)s]', level=logging.DEBUG)

for f in os.listdir(root):
    fname = os.path.join(root, f)
    if os.stat(fname).st_mtime < posix_midnight:
        shutil.copy(fname, stream)
        logging.info('Copied %s to %s', fname, stream)
        shutil.move(fname, archive)
        logging.info('Moved %s to %s', fname, archive)
#
# Module to convert time tuples to UNIX epoch timestamps in such way that
# negative timestamps are supported, even on Windows systems
#
# Author: Bas Hoonhout <bas.hoonhout@deltares.nl>
#

from datetime import datetime

UNIX_EPOCH = datetime(1970, 1, 1)

def timetuple2epoch(tt):
    'Convert time tuple to Unix epoch supporting negative epochs on Windows systems'
    t    = datetime(*tt[:6])
    diff = t - UNIX_EPOCH
    return diff.days * 24 * 3600 + diff.seconds
    
def epoch2timetuple(ts):
    'Convert Unix epoch to time tuple supporting negative epochs on Windows systems'
    if ts < 0:
        abstime = datetime.fromtimestamp(abs(ts))
    	diff    = UNIX_EPOCH - abstime
        return (UNIX_EPOCH + diff).timetuple()
    else:
        return datetime.fromtimestamp(ts).timetuple()
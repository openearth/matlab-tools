###############################################################################
# modules                                                                     #
###############################################################################

import os, time, glob, shutil, re

import config

###############################################################################
# functions                                                                   #
###############################################################################

def wait_for_process(process, seconds):
    'Wait a maximum of time for the process to end'

    j = 0
    while process.poll() == None and j < seconds:
        j = j + 1
        time.sleep(1)

    # kill the process, if it is still running
    if process.poll() == None:
        process.kill()

def purge_results(runid):
    'Purge local results and log files'

    paths = (os.path.join(config.get_root(), 'runs', '*'), \
             os.path.join(config.get_root(), '*.log'), \
             os.path.join(config.get_root(), 'tools', 'python', 'skillbed', '*.log'))

    for path in paths:
        p = glob.glob(path)
        for n in p:
            if n.find(runid) < 0:
                if os.path.isdir(n):
                    shutil.rmtree(n)
                else:
                    os.remove(n)

    return True
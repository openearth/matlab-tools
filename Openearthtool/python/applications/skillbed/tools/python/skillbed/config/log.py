###############################################################################
# modules                                                                     #
###############################################################################

import os, sys

from datetime       import datetime

import config

###############################################################################
# functions                                                                   #
###############################################################################

def create_log_file(fname=''):
    'Create log file'

    if len(fname) == 0:
        fname   = datetime.strftime(datetime.now(), '%Y%m%d%H%M%S')

    logfile     = os.path.join(config.get_root(), \
                    os.path.basename(sys.argv[0]).replace('.py','')+'_'+fname+'.log')

    open(logfile, 'w').close()

    return {'file':logfile, 'content':''}

def message(log, m, write=True):
    'Prints communication message to standard output'

    if m:
        print m

        log['content']  = log['content']+m+'\n'

        if write:
            f = open(log['file'], 'a')
            f.write(m+'\n')
            f.close()

    return log

def welcome(log, title):
    'Prints welcome message with application title'

    log = message(log, '*'*60)
    log = message(log, '**'+(' '*56)+'**')
    log = message(log, '**'+(('Welcome to the '+title).center(56))+'**')
    log = message(log, '**'+(' '*56)+'**')
    log = message(log, '**'+(datetime.strftime(datetime.now(), '%c').center(56))+'**')
    log = message(log, '**'+(' '*56)+'**')
    log = message(log, '*'*60)

    return log

def summary(log, runid, opt, servers):
    'Prints skillbed run summary'

    total_cpu           = sum([s['cpu']         for s in servers])
    avail_platforms     = set([s['platform']    for s in servers])
    avail_servers       = set([s['hostname']    for s in servers])

    ind = '\n'+(' '*28)

    log = message(log, ' ')
    log = message(log, 'Run #                     : '+runid)
    log = message(log, 'Number of nodes available : '+str(total_cpu))
    log = message(log, 'Available platforms       : '+ind.join(avail_platforms))
    log = message(log, 'Available servers         : '+ind.join(avail_servers))
    log = message(log, 'Testing binaries          : '+ind.join(opt['binaries']))
    log = message(log, 'Running run types         : '+ind.join(opt['types']))
    log = message(log, 'Running tests             : '+ind.join(opt['tests']))
    log = message(log, 'Generating reports        : '+ind.join(opt['reports']))
    log = message(log, 'Sending reports to        : '+ind.join(opt['recipients']))
    log = message(log, 'Notification to           : '+opt['notify'])
    log = message(log, 'Skipping analysis         : '+str(opt['skip_analysis']))
    log = message(log, ' ')

    return log
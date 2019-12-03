###############################################################################
# modules                                                                     #
###############################################################################

import os, time, shutil, re
from datetime       import datetime

from config         import config, log
from tests          import get_tid

###############################################################################
# functions                                                                   #
###############################################################################

def build_queue(binaries, tests, types, servers):
    'Get runs for current run sequence'

    systems     = config.get_systems()

    queue       = {'Windows':[], 'Linux':[]}

    # determine available platforms and nodes
    avail_platforms     =     [s['platform'] for s in servers]
    avail_binaries      =     [b for b in s['binaries'] for s in servers]
    max_nodes           = max([s['cpu']      for s in servers])

    testdirs    = config.get_tests()

    # loop through test directories
    for test, testdir in testdirs.iteritems():
        test_match = [t for t in tests if re.search('^{0}(\.|$)'.format(test),t)]

        if len(test_match)>0 or 'all' in tests:

            cfgfile = os.path.join(testdir, '.config')
            cfg = config.read_cfg_file(cfgfile)

            # check if test is enabled and has runs defined
            if cfg.has_option('general', 'enable') and cfg.getboolean('general', 'enable'):
                if cfg.has_option('general', 'runs'):
                    runs = [r.strip() for r in cfg.get('general', 'runs').split(',')]

                    # loop through runs
                    for run in runs:

                        # check if runs are enabled and read their configs if so
                        if cfg.has_option('run_'+run, 'enable') and cfg.getboolean('run_'+run, 'enable'):

                            run_match = [r for r in test_match if re.search('\.{0}$'.format(run),r) or re.search('\.all$',r) or not '.' in r]

                            if len(run_match)>0 or 'all' in tests:

                                platforms, b, t, path, params, nodes, runtime, call = config.read_run(cfg, run)

                                for binary in [b for b in binaries if b in avail_binaries]:
                                    for typ in types:

                                        # check if runs should be used for current configuration
                                        if (binary in b or 'all' in b) and (typ in t or 'all' in t):

                                            # add run to run list
                                            for system in [s for s in systems.keys() if s in avail_platforms]:
                                                if systems[system] in platforms or 'all' in platforms:

                                                    queue[system].append((binary, typ, test, run, path, params, min(nodes,max_nodes), runtime, call))

    return queue

def queue(runid, clog, servers, storage_path, binaries, tests, types):
    'Queue specific tests'

    # create output location
    output_path         = os.path.join(config.get_root(), 'runs', runid, 'output')

    if not os.path.exists(output_path):
        os.makedirs(output_path)

    # create run and process lists
    processes           = []
    queue               = build_queue(binaries, tests, types, servers)

    queue_length        = sum([len(queue[p]) for p in queue.keys()])
    clog                = log.message(clog, '  Queued %d test runs' % queue_length)

    # create status log
    status              = {}

    # start runs in run list
    while sum([len(queue[l]) for l in queue.keys()]) > 0 or len(processes) > 0:

        # loop through servers
        for s in range(len(servers)):

            # skip server if not ready yet
            if not servers[s]['obj'].ready() or servers[s]['status'] < 3:
                continue

            # check if cpu's are available
            if servers[s]['obj'].free() > 0:

                # loop through run list
                i = 0
                while i < len(queue[servers[s]['platform']]):
                    binary, typ, test, run, path, params, nodes, runtime, call = queue[servers[s]['platform']][i]

                    # check if binary and cpu's are available
                    if binary in servers[s]['binaries'] and servers[s]['obj'].free() >= nodes:

                        process     = servers[s]['obj'].run(runid, binary, typ, test, run, path, params, nodes, runtime, call)

                        # check if process is started
                        if process>0:

                            # remove from wait queue
                            queue[servers[s]['platform']].pop(i)

                            # update logs
                            queue_nr    = queue_length-sum([len(queue[p]) for p in queue.keys()])
                            clog        = log.message(clog, '  [%03d/%03d] Test run "%s" started' % (queue_nr, queue_length, '.'.join((binary, typ, test, run))))

                            status['.'.join([binary, typ, test, run])] = 'STARTED'

                            # add to processes queue
                            processes.append({                                                      \
                                'server'        : s,                                                \
                                'process'       : process,                                          \
                                'returncode'    : None,                                             \
                                'starttime'     : time.time(),                                      \
                                'queue_nr'      : queue_nr,                                         \
                                'error'         : False,                                            \
                                'info'          : (binary, typ, test, run, path, params, nodes, runtime, call) })

                            # try another server first
                            break

                    # try next test in line
                    i = i + 1

        # loop through process list
        i = 0
        while i < len(processes):

            # update return code
            processes[i]['returncode'] = servers[processes[i]['server']]['obj'].poll(processes[i]['process'])

            # free cpu's if return code is returned
            if not processes[i]['returncode'] == None:

                tid         = get_tid(processes, i+1)

                # unqueue process
                process     = processes.pop(i)

                # print error message if return code is non-zero
                if process['returncode'] > 0:
                    if not process['error']:
                        clog = log.message(clog, '            Test run "%s" failed' % tid)

                        status[tid] = 'FAILED'
                    else:
                        clog = log.message(clog, '            Test run "%s" exceeded maximum runtime' % tid)

                        status[tid] = 'MAXRUNTIME'
                else:
                    clog = log.message(clog, '            Test run "%s" finished' % tid)

                    status[tid] = 'FINISHED'
            else:

                # determine if maximum runtime has passed, if so, kill process
                if (time.time() - processes[i]['starttime'])/60 > processes[i]['info'][7] and \
                    not processes[i]['error']:

                    servers[processes[i]['server']]['obj'].kill(processes[i]['process'])

                    processes[i]['error']   = True

                i = i + 1

        # wait 10 seconds for next poll
        time.sleep(10)

    # create status file
    datestr     = datetime.strftime(datetime.now(), '%Y%m%d%H%M%S')
    stat_path   = os.path.join(output_path, 'tests_%s.status' % datestr)
    f           = open(stat_path, 'w')

    for id in status.keys():
        f.write('{0},{1}\n'.format(id.replace('.',','), status[id]))

    f.close()

    shutil.copyfile(stat_path, os.path.join(output_path, 'latest.status'));

    # backup results
    for s in range(len(servers)):
        if servers[s]['port'] < 9000:
            servers[s]['obj'].backup(runid, storage_path)
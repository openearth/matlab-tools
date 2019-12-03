###############################################################################
# modules                                                                     #
###############################################################################

import os, platform, shutil, re, subprocess

from config         import config, hooks
from network        import storage

###############################################################################
# functions                                                                   #
###############################################################################

def run(runs, runid, cfg, binary, typ, test, run, path, params, nodes, runtime, call):
    'Run a specific test'

    runnr = 0

    testdirs            = config.get_tests()

    params              = params.split()

    # deterimine paths
    bin_path    = os.path.join(config.get_root(), 'runs', runid, 'bin', binary)
    exe_path    = os.path.join(bin_path, cfg['binary'])
    input_path  = os.path.join(testdirs[test], path)
    test_path   = os.path.join(config.get_root(), 'runs', runid, 'output', binary, typ, test)
    run_path    = os.path.join(test_path, run)

    if os.path.exists(exe_path):

        # create output location
        if os.path.exists(run_path):
            shutil.rmtree(run_path)

        storage.safe_copytree(testdirs[test], test_path, recurse=False)
        storage.safe_copytree(testdirs[test], run_path, recurse=False)
        storage.safe_copytree(input_path, run_path)

        if len(params) == 1:

            if len(cfg['params']) > 0:
                parfile     = cfg['params']
            else:
                parfile     = params[0]

            par_path        = os.path.join(run_path, parfile)

            if not params[0] == parfile:
                storage.safe_copytree(os.path.join(run_path, params[0]), par_path)

            # modify params in default run type
            if typ == 'default':
                hooks.call('remove_defaults', par_path)

            params = [parfile]

        pipe = open(os.devnull, 'w')

        # run model
        if len(call) == 0:
            call = cfg['call']

        markers = {                             \
            'runid'         : runid,            \
            'binary'        : binary,           \
            'type'          : typ,              \
            'test'          : test,             \
            'run'           : run,              \
            'nodes'         : nodes,            \
            'runtime'       : runtime,          \
            'root_path'     : config.get_root(),\
            'exe_path'      : exe_path,         \
            'bin_path'      : bin_path,         \
            'input_path'    : input_path,       \
            'test_path'     : test_path,        \
            'run_path'      : run_path              }

        for i in range(len(params)):
            params[i] = params[i].format(**markers)
            markers['params.%d' % (i+1)] = params[i]
            
        markers['params'] = ' '.join(params)

        call = call.format(**markers)

        if nodes > 1:
            if os.environ.has_key('MPIEXEC_PATH') and os.path.exists(os.environ['MPIEXEC_PATH']):
                mpiexec_args = [os.environ['MPIEXEC_PATH'], '-np', str(nodes), '-phrase', 'behappy', '-impersonate', call]
                process = subprocess.Popen(mpiexec_args, shell=False, cwd=run_path, stdout=pipe, stderr=pipe)
        else:
            process = subprocess.Popen(call, shell=False, cwd=run_path, stdout=pipe, stderr=pipe)

        pipe.close()

        runs.append({'process':process, 'info':(binary, typ, test, run, path, params, nodes, runtime, call)})

        runnr = len(runs)

    return (runs, runnr)

def run_test_cluster():
    'Run a specific test on cluster'

    pass

def poll(runs, runnr):
    'Poll test process'

    return runs[runnr-1]['process'].poll()

def kill(runs, runnr=0):
    'Kill test or all tests'

    if runnr == 0:
        idx = range(len(runs))
    else:
        idx = [runnr-1]

    for i in idx:

        run = runs[i]['process']

        if platform.system() == 'Windows':
            subprocess.Popen('TASKKILL /PID %d /F /T' % run.pid, \
                shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        else:
            run.kill()

def get_info(runs, runnr):
    'Get test info'

    binary, typ, test, run, path, params, nodes, runtime, call = runs[runnr-1]['info']

    info = {                    \
        'binary'    : binary,   \
        'typ'       : typ,      \
        'test'      : test,     \
        'run'       : run,      \
        'path'      : path,     \
        'params'    : params,   \
        'nodes'     : nodes,    \
        'runtime'   : runtime,  \
        'call'      : call          }

    return info

def get_tid(runs, runnr):
    'Get test identifier'

    info        = get_info(runs, runnr)

    tid         = [info[f] for f in ['binary', 'typ', 'test', 'run']]

    return '.'.join(tid)

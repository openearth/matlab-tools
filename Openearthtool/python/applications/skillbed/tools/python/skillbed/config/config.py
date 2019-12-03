###############################################################################
# modules                                                                     #
###############################################################################

import os, ConfigParser, multiprocessing, re

###############################################################################
# functions                                                                   #
###############################################################################

def get_root():
    'Returns root of skillbed directory structure'

    return os.path.abspath(os.path.join(os.path.dirname(os.path.realpath(__file__)), '..', '..', '..', '..'))

def get_cpu():
    'Returns number of CPU available'

    n       = multiprocessing.cpu_count()

    if os.environ.has_key('NR_THREADS'):
        n   = n * int(os.environ['NR_THREADS'])

    return n

def get_systems():
    'Returns list with operation system identifiers'

    systems = { \
        'Windows'   : 'win32',  \
        'Linux'     : 'unix'        }

    return systems

def get_tests(loc=[]):
    'Return list with full test names and corresponding configuration file location'

    tests = {}

    path = os.path.join(get_root(), 'input', *loc)

    for d in os.listdir(path):
        if not d[0] == '.' and os.path.isdir(os.path.join(path, d)):
            cfgfile = os.path.join(path, d, '.config')
            if os.path.exists(cfgfile):
                tests['_'.join(loc+[d])] = os.path.join(path, d);
            else:
                tests.update(get_tests(loc+[d]))

    return tests

def match_tests(dir, test, run='', loc=[]):
    'Match (sub)directories to a certain test and optional run'

    testrun = '%s.%s' % (test, run)

    matches = []

    if type(loc) is str:
        loc = re.split('\\|/', loc)

    path = os.path.join(get_root(), dir, *loc)

    if os.path.exists(path):
        for d in os.listdir(path):
            if not d[0] == '.' and os.path.isdir(os.path.join(path, d)):

                testdir = '_'.join(loc+[d])
                rundir  = '_'.join(loc)+'.'+d

                if test.startswith(testdir+'_') or test == testdir or \
                    testrun.startswith(rundir+'_') or testrun == rundir:

                    matches.append('/'.join(loc+[d]))

                sub = match_tests(dir, test, run, loc+[d])

                if len(sub)>0:
                    matches.extend(sub)

    return matches

def load_inst_file():
    'Load installation file'

    fname = os.path.join(get_root(), 'tools', 'skillbed.inst')

    if os.path.exists(fname):
        f       = open(fname, 'r')
        lines   = f.read().splitlines()
        f.close()

        for line in lines:
            if len(line) > 0:
                key, value              = line.split('=')
                os.environ[key.strip()] = value.strip()

    return True

def load_cfg_file(fname):
    'Read configuration file'

    defaults = { \
        'general'       : {}, \
        'storage'       : {}, \
        'network'       : {}, \
        'servers'       : {}, \
        'repositories'  : {}, \
        'binaries'      : {}, \
        'reports'       : {}, \
        'templates'     : {}, \
        'mail'          : {}, \
        'recipients'    : {}    }
    
    defaults = update_cfg(defaults, os.path.join( \
        os.path.dirname(os.path.realpath(__file__)), 'skillbed.def'))
    defaults = update_cfg(defaults, fname)
    
    return defaults
    
def update_cfg(defaults, fname):
    'Update configuration values'
    
    if not os.path.isabs(fname):
        fname   = os.path.abspath(os.path.join(get_root(), fname))
            
    if os.path.exists(fname):
        
        if os.path.exists(fname):
            cfg     = read_cfg_file(fname)

            for s in cfg.sections():
                opts = dict((o, cfg.get(s, o)) for o in cfg.options(s))
                
                if defaults.has_key(s):
                    defaults[s].update(opts)
                else:
                    defaults[s] = opts

    return defaults

def load_info_file(fname):
    'Read info file'

    defaults = { \
        'bin'           : {}, \
        'report'        : {},   }

    if os.path.exists(fname):
        cfg     = read_cfg_file(fname)

        defaults.update( \
            dict((s, dict((o, cfg.get(s, o)) for o in cfg.options(s))) \
            for s in cfg.sections()))

    return defaults

def read_cfg_file(fname):
    'Read configuration file'

    cfg         = ConfigParser.RawConfigParser()

    cfg.read(fname)

    return cfg

def write_cfg_file(fname, data):
    'Write configuration file'

    cfg         = ConfigParser.RawConfigParser()

    for s in data.keys():
        cfg.add_section(s)
        for k,v in data[s].iteritems():
            cfg.set(s,k,v)

    with open(fname, 'wb') as f:
        cfg.write(f)

def read_run(cfg, run):
    'Read run settings from config object'

    run = 'run_'+run

    if cfg.has_option(run, 'platforms'):
        platforms   = [p.strip() for p in cfg.get(run, 'platforms').split(',')]
    else:
        platforms   = 'all'

    if cfg.has_option(run, 'binaries'):
        binaries    = [b.strip() for b in cfg.get(run, 'binaries').split(',')]
    else:
        binaries    = 'all'

    if cfg.has_option(run, 'types'):
        types       = [t.strip() for t in cfg.get(run, 'types').split(',')]
    else:
        types       = 'all'

    if cfg.has_option(run, 'path'):
        path        = cfg.get(run, 'path')
    else:
        path        = ''

    if cfg.has_option(run, 'params'):
        params      = cfg.get(run, 'params')
    else:
        params      = ''

    if cfg.has_option(run, 'nodes'):
        nodes       = cfg.getint(run, 'nodes')
    else:
        nodes       = 1

    if cfg.has_option(run, 'runtime'):
        runtime     = cfg.getint(run, 'runtime')
    else:
        runtime     = 60

    if cfg.has_option(run, 'call'):
        call        = cfg.get(run, 'call')
    else:
        call        = ''

    return (platforms, binaries, types, path, params, nodes, runtime, call)
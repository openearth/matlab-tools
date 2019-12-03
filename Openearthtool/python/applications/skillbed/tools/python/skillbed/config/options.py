###############################################################################
# modules                                                                     #
###############################################################################

import os, sys, getopt, re, math

import config

###############################################################################
# functions                                                                   #
###############################################################################

defined_opts = []

def load_opt_client():
    'Load client options from command line'

    define_option('binaries',     'b', ['all'],             'string', True, 'Comma separated list of binary names to be used')
    define_option('types',        'y', ['all'],             'string', True, 'Comma separated list of type of runs to be used (custom and/or default)')
    define_option('tests',        't', ['none'],            'string', True, 'Comma separated list of tests to be used')
    define_option('testlists',    'l', ['none'],            'string', True, 'Comma separated list of files containing tests to be used')
    define_option('reports',      'r', ['all'],             'string', True, 'Comma separated list of reports to be generated')
    define_option('recipients',   'e', ['all'],             'string', True, 'Comma separated list of registered e-mailaddresses. Each recipient will recieve an e-mail with the reports that are generated and are specified by the recipient as report of interest')
    define_option('config',       'c', 'tools/skillbed.cfg','string', False,'Configuration file to be used')
    define_option('servers',      'v', [],                  'string', True, 'Servers to be used')
    define_option('source',       'o', '',                  'string', False,'Path to source code to be used')
    define_option('analyze',      'a', '',                  'string', False,'Skip running compilation and running model, instead use existing model results from a specific run with provided run id')
    define_option('skip-analysis','',  False,               'boolean',False,'Skip running Matlab for the test analysis')
    define_option('skip-report',  '',  False,               'boolean',False,'Skip generation of reports')
    define_option('skip-svn',     '',  False,               'boolean',False,'Skip updating SVN working copies')
    define_option('skip-network', '',  False,               'boolean',False,'Skip copying results from and to network')
    define_option('force-network','',  False,               'boolean',False,'Force copying results from and to network')
    define_option('skip-clean',   '',  False,               'boolean',False,'Skip cleaning local results')
    define_option('force-clean',  '',  False,               'boolean',False,'Force cleaning local results')
    define_option('skip-publish', '',  False,               'boolean',False,'Skip publishing of binaries and reports')
    define_option('force-publish','',  False,               'boolean',False,'Force publishing of binaries and reports')
    define_option('test-report',  '',  [],                  'string', True, 'Try to render one or more reports')
    define_option('max-nodes',    'm', 1000,                'int',    False,'Maximize the preparation of nodes. Can be used to quickly run a single run')
    define_option('notify',       'n', '',                  'string', False,'Send notification to this e-mailaddress when skillbed run is finished')
    define_option('interpret',    '',  False,               'boolean',False,'Add interpretation of test results to reports')
    define_option('purge',        '',  False,               'boolean',False,'Purge any run results and log files from client and servers. WARNING: This will actually delete a whole lot of data!')
    define_option('gui',          'g', False,               'boolean',False,'Start client with web GUI')
    define_option('service',      's', False,               'boolean',False,'Start client as web service')
    define_option('local',        '',  False,               'boolean',False,'Start server locally and use it instead')
    define_option('shutdown',     '',  False,               'boolean',False,'Shutdown all servers afterwards WARNING: This will shutdown all skillbed servers!')
    define_option('update',       '',  False,               'boolean',False,'Start client web GUI in debug mode')
    define_option('debug',        '',  False,               'boolean',False,'Update skillbed servers before starting the skillbed run. WARNING: This will restart all skillbed servers!')
    define_option('help',         'h', False,               'boolean',False,'Print this help message')

    opt = parse_options()

    return opt

def load_opt_server():
    'Load server options from command line'

    define_option('port',         'p', 8000,                'int',    False, 'Port number to listen to')
    define_option('delay',        'd', 0,                   'int',    False, 'Delay in seconds before startup')
    define_option('config',       'c', 'tools/skillbed.cfg','string', False, 'Configuration file to be used')
    define_option('help',         'h', False,               'boolean',False, 'Print this help message')

    opt = parse_options()

    return opt

def print_additional_info():
    'Print additional help information'

    infofile = os.path.join(config.get_root(), 'tools', 'footer.txt')

    if os.path.exists(infofile):

        fd = open(infofile, 'r')
        print '\n'
        print fd.read()
        fd.close()

def normalize_options(opt, cfg, runid):
    'Normalize options and remove combinations that do not exist'

    if len(opt['test_report']) > 0:

        opt['binaries']            = []
        opt['types']               = []
        opt['tests']               = []
        opt['reports']             = opt['test_report']
        opt['recipients']          = []
        opt['skip_analysis']       = True
        opt['skip_network']        = True
        opt['skip_publish']        = True
        opt['test_report']         = True

    elif len(opt['analyze']) > 0:

        p = os.path.join(cfg['storage']['path'], 'RUNS')

        # find last run id
        if opt['analyze'] == 'last':
            if os.path.exists(p):
                d = os.listdir(p)
                s = [int(re.search('\d{14}',i).group()) for i in d]

                opt['analyze'] = d[s.index(max(s))];

        runid                      = opt['analyze']

        opt['binaries']            = []
        opt['types']               = []
        opt['tests']               = []

        if 'none' in opt['reports'] or opt['skip_report']:
            opt['reports']         = []

        if not os.path.exists(os.path.join(p, runid)):
            if not os.path.exists(os.path.join(config.get_root(), 'runs', runid)):
                print 'ERROR: invalid run id'

                sys.exit(0)

    else:

        # read test files
        if 'none' in opt['tests']:
            opt['tests']           = []

        if 'none' in opt['testlists']:
            opt['testlists']       = []

        for fname in opt['testlists']:
            fname = os.path.join(config.get_root(), 'tools', fname)

            if os.path.exists(fname):
                f           = open(fname, 'r')
                opt['tests'].extend([v.strip() for v in f.read().splitlines()])
                f.close()

        if 'none' in opt['binaries'] or len(opt['tests']) == 0:
            opt['binaries']        = []

        if 'none' in opt['types'] or len(opt['binaries']) == 0:
            opt['types']           = []

        if 'none' in opt['tests'] or len(opt['types']) == 0:
            opt['tests']           = []

        if len(opt['tests']) == 0:
            opt['skip_analysis']   = True

        if 'none' in opt['reports'] or len(opt['tests']) == 0 or \
            opt['skip_report'] or opt['skip_analysis']:
            opt['reports']         = []

        if (len(opt['binaries']) == 0 and len(opt['reports']) == 0) or opt['local']:
            opt['skip_publish']    = True

    if 'none' in opt['recipients'] or len(opt['reports']) == 0 or opt['local']:
        opt['recipients']          = []

    cfg['binaries']    = dict((i, j) for i, j in cfg['binaries'].items()      if i in opt['binaries']    or 'all' in opt['binaries']    )
    cfg['reports']     = dict((i, j) for i, j in cfg['reports'].items()       if i in opt['reports']     or 'all' in opt['reports']     )
    cfg['recipients']  = dict((i, j) for i, j in cfg['recipients'].items()    if i in opt['recipients']  or 'all' in opt['recipients']  )

    opt['types']       = [t for t in ['custom', 'default']                    if t in opt['types']       or 'all' in opt['types']       ]

    opt['binaries']    = cfg['binaries'].keys()
    opt['reports']     = cfg['reports'].keys()
    opt['recipients']  = cfg['recipients'].keys()

    return (opt, cfg, runid)

def define_option(longname, shortname, default='', kind='string', is_list=False, description=''):
    'Define command-line option'

    if len(longname)>0:
        name = re.sub('-','_',longname)

        commands = []

        if len(shortname)>0:
            commands.append('-'+shortname)

        commands.append('--'+longname)

        if kind != 'boolean':
            longname  = longname+'='

            if len(shortname)>0:
                shortname = shortname+':'

        if kind in ('boolean', 'string', 'int'):

            defined_opts.append({
                'name'          :   name,       \
                'shortname'     :   shortname,  \
                'longname'      :   longname,   \
                'description'   :   description,\
                'commands'      :   commands,   \
                'default'       :   default,    \
                'kind'          :   kind,       \
                'is_list'       :   is_list         })

def parse_options():
    'Parse command line options'

    opt = {}
    for o in defined_opts:
        opt[o['name']] = o['default']

    if len(sys.argv) > 1:

        try:
            options, args = getopt.getopt(                          \
                sys.argv[1:],                                       \
                ''.join([o['shortname'] for o in defined_opts]),    \
                [o['longname'] for o in defined_opts]                   )
        except:
            print 'ERROR: invalid command line options'

            sys.exit(0)

        for option, value in options:
            for o in defined_opts:
                if option in o['commands']:
                    if o['kind'] == 'boolean':
                        opt[o['name']]      = True
                    else:
                        if o['is_list']:
                            opt[o['name']]  = [v.strip() for v in value.split(',')]
                        else:
                            opt[o['name']]  = value.strip()

                    if o['kind'] == 'int':
                        opt[o['name']]      = int(opt[o['name']])

        if opt.has_key('help') and opt['help']:

            scriptname = os.path.split(sys.argv[0])[1]

            print '''
    Usage:
        python '''+scriptname+''' [options]

    Options:'''

            l = float(47)
            for o in defined_opts:
                i = 0
                i1 = 0
                i2 = 0
                while i1 < len(o['description']):

                    i2 = int(i1+l)

                    if i2 < len(o['description']):

                        ii = o['description'].rfind(' ',i1,int(i1+l))

                        if ii > 0:
                            i2 = ii

                    d = o['description'][i1:i2]

                    i1 = i2+1

                    if i == 0:
                        if len(o['commands'])>1:
                            line = (' '*8 )+'%-2s, %-19s %s' % tuple(o['commands']+[d])
                        else:
                            line = (' '*12)+      '%-19s %s' % tuple(o['commands']+[d])
                    else:
                        line =     (' '*32)+            '%s' % d

                    print line

                    i = i + 1

            print '''
                                Values "none" and "all" can be used for all
                                comma separated lists defined above. "none"
                                overwrites "all".'''

            print_additional_info()

            sys.exit(0)

    return opt
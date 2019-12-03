###############################################################################
# modules                                                                     #
###############################################################################

import os, subprocess

from datetime       import datetime
from mako.template  import Template

from config         import config

###############################################################################
# functions                                                                   #
###############################################################################

def run(runid, storage_path, templates):
    'Run all analyses available'

    analysis_path   = os.path.join(config.get_root(), 'runs', runid, 'analysis')

    funcname        = create_script(runid, analysis_path, storage_path, templates)

    matlab_args     = [os.environ['MATLAB_PATH'], '-wait', '-r', funcname]
    matlab          = subprocess.Popen(matlab_args, shell=False, cwd=analysis_path)

    matlab.wait()

def create_script(runid, analysis_path, storage_path, templates):
    'Create matlab script to run all analyses available'

    # determine script name
    datestr         = datetime.strftime(datetime.now(), '%Y%m%d%H%M%S')
    funcname        = 'matlab_'+datestr

    # determine directories
    compile_path    = os.path.join(config.get_root(),   'runs',     runid,  'bin'       )
    output_path     = os.path.join(config.get_root(),   'runs',     runid,  'output'    )
    matlab_path     = os.path.join(config.get_root(),   'tools',    'matlab'            )
    network_path    = os.path.join(storage_path,        'DATA'                          )

    # determine filename
    mfile           = os.path.join(analysis_path, funcname+'.m')

    if not os.path.exists(analysis_path):
        os.makedirs(analysis_path)

    if not os.path.exists(network_path):
        os.makedirs(network_path)

    # intialize templates
    template        = Template(filename=os.path.join(config.get_root(), templates['matlab']       ))
    template_item   = Template(filename=os.path.join(config.get_root(), templates['matlab_test']  ))

    analysis_calls  = ''

    # loop through test directories
    if os.path.exists(output_path):
        for binary in os.listdir(output_path):
            bin_path = os.path.join(output_path, binary)

            if not binary[0] == '.' and os.path.isdir(bin_path):

                # read revision file
                file_path = os.path.join(compile_path, binary, 'revision.txt')
                if os.path.exists(file_path):
                    f           = open(file_path, 'r')
                    revision    = int(f.read())
                    f.close()

                    for typ in os.listdir(bin_path):
                        type_path = os.path.join(bin_path, typ)
                        if not typ[0] == '.' and os.path.isdir(type_path):
                            for test in os.listdir(type_path):
                                test_path = os.path.join(type_path, test)
                                if not test[0] == '.' and os.path.isdir(test_path):

                                    # read configuration file
                                    cfgfile = os.path.join(test_path, '.config')
                                    if os.path.exists(cfgfile):
                                        cfg = config.read_cfg_file(cfgfile)

                                        # check if analysis is necessary
                                        if  cfg.has_option('general', 'enable') and cfg.getboolean('general', 'enable'):

                                            for run in os.listdir(test_path):
                                                run_path = os.path.join(test_path, run)
                                                if not run[0] == '.' and os.path.isdir(run_path):

                                                    # check if analysis is necessary
                                                    if  cfg.has_option('general', 'runs')       and run in [r.strip() for r in cfg.get('general', 'runs').split(',')]   and \
                                                        cfg.has_option('run_'+run, 'enable')    and cfg.getboolean('run_'+run, 'enable')                                and \
                                                        cfg.has_option('run_'+run, 'analysis'):

                                                        analysisfunc    = cfg.get('run_'+run, 'analysis')

                                                        markers         = set_markers(runid, revision, run_path, binary, typ, test, run, analysisfunc)

                                                        analysis_calls  = analysis_calls + template_item.render(**markers)

                                            if  cfg.has_option('general', 'analysis'):

                                                analysisfunc    = cfg.get('general', 'analysis')

                                                markers         = set_markers(runid, revision, test_path, binary, typ, test, '', analysisfunc)

                                                analysis_calls  = analysis_calls + template_item.render(**markers)

    markers = {                                 \
        'funcname'          : funcname,         \
        'matlabpath'        : matlab_path,      \
        'networkpath'       : network_path,     \
        'analysis_calls'    : analysis_calls        }

    f = open(mfile, 'w')
    f.write(template.render(**markers))
    f.close()

    return funcname

def set_markers(runid, revision, run_path, binary, typ, test, run, analysisfunc):
    'Add function call to Matlab script'

    outputpath      = os.path.join(config.get_root(), 'runs', runid, 'analysis', binary, typ, test, run)
    datapath        = os.path.join(config.get_root(), 'data', test)
    analysispaths   = [os.path.join(config.get_root(), 'analysis', a) for a in config.match_tests('analysis', test, run)]

    if not os.path.exists(outputpath):
        os.makedirs(outputpath)

    if not os.path.exists(datapath):
        datapath = ''

    markers = {                         \
        'runpath'       : run_path,     \
        'revision'      : revision,     \
        'binary'        : binary,       \
        'type'          : typ,          \
        'test'          : test,         \
        'run'           : run,          \
        'outputpath'    : outputpath,   \
        'datapath'      : datapath,     \
        'analysispaths' : analysispaths,\
        'analysisfunc'  : analysisfunc      }

    return markers
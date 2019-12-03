###############################################################################
# modules                                                                     #
###############################################################################

import os, time, subprocess, re, shutil

from datetime       import datetime
from mako.template  import Template
from mako.lookup    import TemplateLookup

from config         import config,misc
from network        import svn,storage

###############################################################################
# functions                                                                   #
###############################################################################

def build(runid, storage_path, repositories, reports, interpret=False):
    'Compile all reports'

    input_path      = os.path.join(config.get_root(), 'latex')
    output_path     = os.path.join(config.get_root(), 'runs', runid, 'report')

    if not os.path.exists(output_path):
        os.makedirs(output_path)

    retcode = False

    for report, cfg in reports.iteritems():

        texfile, base_path = cfg.split()

        tex_path    = os.path.join(input_path, os.path.dirname(texfile))
        texfile     = os.path.basename(texfile)

        texfile     = render(runid, storage_path, repositories, report, texfile, tex_path, base_path, interpret)

        if texfile:

            # backup render
            src_path = os.path.join(tex_path, texfile)
            dst_path = os.path.join(output_path, texfile)

            storage.safe_copytree(src_path, dst_path)

            # copy references
            storage.safe_copytree(os.path.join(input_path, '*.bib'), output_path)

            retcode = max(retcode, run(report, texfile, tex_path, output_path))
        else:
            retcode = max(retcode, 1)

    return retcode

def run(report, texfile, input_path, output_path):
    'Compile Latex document to PDF'

    if os.environ.has_key('PDFLATEX_PATH') and os.path.exists(os.environ['PDFLATEX_PATH']):

        logfile     = os.path.join(output_path, report+'.log')

        fd          = open(logfile, 'w')
        latex_args  = [os.environ['PDFLATEX_PATH'], \
            '-interaction=nonstopmode', '-output-directory='+output_path, '-jobname='+report, texfile]

        bibfile,ext = os.path.splitext(texfile)
        bibtex_args = [os.environ['BIBTEX_PATH'], bibfile]

        for i in range(3):

            process = subprocess.Popen(latex_args, shell=False, cwd=input_path, stdout=fd, stderr=fd)

            misc.wait_for_process(process, 300)

            if i == 0:

                process = subprocess.Popen(bibtex_args, shell=False, cwd=output_path, stdout=fd, stderr=fd)

                misc.wait_for_process(process, 300)

        fd.close()

        return process.poll()

    return 1

def render(runid, storage_path, repositories, report, texfile, input_path, base_path, interpret=False):
    'Render latex report'

    file_path       = os.path.join(input_path, texfile)

    if os.path.exists(file_path):

        directories = [                                             \
            input_path,                                             \
            os.path.join(config.get_root(), 'latex'             ),  \
            os.path.join(config.get_root(), 'latex', '_tests'   )       ]

        lookup      = TemplateLookup(                               \
            directories=directories,                                \
            input_encoding='utf-8', output_encoding='utf-8',        \
            encoding_errors='replace', error_handler=template_error     )

        template    = lookup.get_template(texfile)

        base_path   = base_path.split('/')

        markers     = {                                                                                 \
            'report'        : latex_escape(report),                                                     \
            'datetime'      : latex_escape(datetime.strftime(datetime.now(), '%d-%m-%Y %H:%M:%S')),     \
            'revision'      : latex_escape(revision(repositories)),                                     \
            'overview'      : overview(runid),                                                          \
            'changelog'     : changelog(repositories),                                                  \
            'interpret'     : interpret,                                                                \
            'base_path'     : os.path.join(config.get_root(), 'runs', runid, 'analysis', *base_path),   \
            'input_path'    : os.path.join(config.get_root(), 'input'),                                 \
            'data_path'     : os.path.join(config.get_root(), 'data'),                                  \
            'network_path'  : os.path.join(storage_path, 'DATA'),                                       \
            'root_path'     : os.path.join(config.get_root())                                               }

        texfile     = report+'.rendered'
        file_path   = os.path.join(input_path, texfile)

        f = open(file_path, 'w')
        f.write(template.render(**markers))
        f.close()

        return texfile

    else:
        return False

def revision(repositories):
    'Retrieve current subversion revision for all known repositories'

    rev         = ''
    for repos in repositories.keys():
        rev     = rev+str(svn.revision(repositories[repos]))+' ('+repos+') '

    return rev

def changelog(repositories):
    'Retrieve current subversion changelogs for all known repositories'

    texfile         = 'changelog.tex'

    tmpl_path       = os.path.join(config.get_root(), 'latex')
    tmplfile        = os.path.join(tmpl_path, texfile)

    changelog       = ''

    if os.path.exists(tmplfile):

        lookup      = TemplateLookup(                               \
            directories=[tmpl_path],                                \
            input_encoding='utf-8', output_encoding='utf-8',        \
            encoding_errors='replace', error_handler=template_error     )

        template    = lookup.get_template(texfile)

        for repos in repositories.keys():

            markers = {                                             \
                'repos' : latex_escape(repos),                      \
                'log'   : svn.changelog(repositories[repos])            }

            changelog = changelog+template.render(**markers)

    return changelog

def overview(runid):
    'Render overview table'

    texfile = 'overview.tex'

    tmpl_path       = os.path.join(config.get_root(), 'latex')
    tmplfile        = os.path.join(tmpl_path, texfile)

    overview        = ''

    if os.path.exists(tmplfile):

        statdata = {'test':[], 'matlab':[]}

        # load test status files
        test_path   = os.path.join(config.get_root(), 'runs', runid, 'output', 'latest.status')
        if os.path.exists(test_path):
            f = open(test_path, 'r')
            statdata['test'] = f.read().split('\n')
            f.close()

        # load test status file
        matlab_path = os.path.join(config.get_root(), 'runs', runid, 'analysis', 'latest.status')
        if os.path.exists(matlab_path):
            f = open(matlab_path, 'r')
            statdata['matlab'] = f.read().split('\n')
            f.close()

        info = {}

        # merge status files
        status      = {}
        for stattype in statdata.keys():
            for item in statdata[stattype]:
                if len(item) > 0:

                    binary, typ, test, run, value = item.split(',')

                    if not status.has_key(binary):
                        status[binary]                  = {}

                    if not status[binary].has_key(typ):
                        status[binary][typ]             = {}

                    if not status[binary][typ].has_key(test):
                        status[binary][typ][test]       = {}

                    if not status[binary][typ][test].has_key(run):
                        status[binary][typ][test][run]  = {'test':'', 'matlab':''}

                    status[binary][typ][test][run][stattype] = value

                    # test configuration info
                    if not info.has_key(test):
                        cfg_path   = os.path.join(config.get_root(), 'runs', runid, 'output', binary, typ, test, run, '.config')

                        info[test] = {'type':typ}

                        if os.path.exists(cfg_path):
                            cfg = config.read_cfg_file(cfg_path)
                            info[test].update(dict((o, cfg.get('categories', o)) for o in cfg.options('categories')))

        lookup      = TemplateLookup(                               \
            directories=[tmpl_path],                                \
            input_encoding='utf-8', output_encoding='utf-8',        \
            encoding_errors='replace', error_handler=template_error     )

        template    = lookup.get_template(texfile)

        markers     = {'status':status,'info':info}

        overview    = template.render(**markers)

    return overview

def latex_escape(string):
    'Escapes special characters in Latex'

    replacements    = ('&', '\\$', '%', '_', '#', '\\{', '\\}');

    for s in replacements:
        string      = re.sub(r'([^\\]?)'+s, r'\1\\'+s, string)

    replacements    = {'^':'\\^{}', '~':'\\~{}', '|':'\\textbar ', '<':'\\textless ', '>':'\\textgreater '};

    for s, r in replacements.iteritems():
        string      = string.replace(s, r)

    return string

def template_error(context, exception):
    'Error handling function for template generation'

    print exception

    return True
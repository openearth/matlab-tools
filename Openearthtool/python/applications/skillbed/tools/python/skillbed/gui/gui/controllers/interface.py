import logging, os, sys, threading, time, pickle

sys.path.insert(0, os.path.abspath(os.path.join('..')))

import client

from config         import config, options
from network        import connection

from pylons import request, response, session, tmpl_context as c, url
from pylons.controllers.util import abort, redirect

from gui.lib.base import BaseController, render

log = logging.getLogger(__name__)

class InterfaceController(BaseController):

    def index(self):

        opt                     = get_opts()
        cfg                     = config.load_cfg_file(opt['config'])

        c.binaries              = cfg['binaries']
        c.tests                 = sorted(get_testlist())
        c.reports               = cfg['reports']
        c.recipients            = cfg['recipients']

        return render('/index.html')

    def run(self):

        if request.POST.has_key('run'):

            # set options
            opt                = get_opts()

            opt['binaries']    = request.POST.getall('binaries[]')
            opt['types']       = request.POST.getall('types[]')
            opt['tests']       = request.POST.getall('tests[]')
            opt['reports']     = request.POST.getall('reports[]')
            opt['recipients']  = request.POST.getall('recipients[]')

            if request.POST.has_key('update'):
                opt['update']  = True

            opt['source']      = request.POST['source']
            opt['notify']      = request.POST['email']

            # start skillbed in separate thread
            thread = ClientThread(opt.copy())

            c.runid                 = thread.cobj.runid
            c.email                 = request.POST['email']

        elif request.GET.has_key('runid'):

            c.runid                 = str(request.GET['runid'])
            c.email                 = ''

            cobj                    = get_cobj(c.runid)

            if cobj:
                c.email             = cobj.opt['notify']

        # render template
        return render('/run.html')

    def progress(self):

        if request.GET.has_key('runid'):
            cobj                = get_cobj(str(request.GET['runid']))

            if cobj:
                log             = cobj.log['content'].replace('\n', '<br>\n').replace(' ','&nbsp;')

                return log

        return 'FALSE'

    def monitor(self):

        opt                     = get_opts()
        cfg                     = config.load_cfg_file(opt['config'])

        servers = connection.load_servers(cfg['storage']['path'], cfg['servers'], opt['servers'], opt['local'])

        ret = str(len(servers))+'\n'

        for cobj in get_cobjs():
            ret = ret+cobj.runid+'|'+','.join(cobj.opt['tests'])+'\n'

        return ret

class ClientThread(threading.Thread):

    cobj = ''

    def __init__(self, opt):

        self.cobj               = client.Client()

        self.cobj.opt.update(opt)

        threading.Thread.__init__(self)

        self.setName(self.cobj.runid)

        self.start()

    def run(self):

        self.cobj.start()

        time.sleep(10)

        del self.cobj

        return True

###############################################################################

def get_testlist():

    testdirs = config.get_tests()

    return testdirs.keys()

def get_cobj(runid):

    threads = [t for t in threading.enumerate() if t.name == runid]

    if len(threads) > 0:
        if hasattr(threads[0], 'cobj'):
            return threads[0].cobj

    return False

def get_cobjs():

    cobjs = []

    for t in threading.enumerate():
        cobj = get_cobj(t.name)

        if cobj:
            cobjs.append(cobj)

    return cobjs

def get_opts():

    if os.path.exists('OPT'):
        jar = open('OPT', 'rb')
        opt = pickle.load(jar)
        jar.close()
    else:
        opt = options.load_opt_client()

    opt['gui']     = False
    opt['debug']   = False
    opt['service'] = False
    opt['help']    = False

    return opt
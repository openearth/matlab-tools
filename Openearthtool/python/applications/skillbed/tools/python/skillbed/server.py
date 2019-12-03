###############################################################################
# import modules                                                              #
###############################################################################

import os, sys, platform, socket, shutil, time, glob

from SimpleXMLRPCServer import SimpleXMLRPCServer
from threading          import Thread

from config         import *
from network        import storage,connection,svn
from binaries       import *
from tests          import tests

###############################################################################
# class definition                                                            #
###############################################################################

class Server:

    server      = False

    cfg         = {}
    opt         = {}

    cpu         = {'nr':0, 'used':0}

    ready       = False
    queue       = []
    processes   = []
    runs        = []

    log         = {'file':'', 'content':''}

    _parent     = False

    def __init__(self):
        'Initialize skillbed server'

        self.opt        = options.load_opt_server()

        self.log        = log.create_log_file()
        self.log        = log.welcome(self.log, 'skillbed server')
        self.log        = log.message(self.log, 'Initializing...')

        if self.opt['delay'] > 0:
            self.log    = log.message(self.log, 'Startup delay %d seconds...' % self.opt['delay'])

            time.sleep(self.opt['delay'])

        config.load_inst_file()

        self.cfg        = config.load_cfg_file(self.opt['config'])
        self.cpu['nr']  = config.get_cpu()

        storage.mount(self.cfg['network'])
        svn.initialize()

        connection.register_server(self.cfg['storage']['path'], self.opt['port'])

    def start(self):
        'Start skillbed server'

        self.log        = log.message(self.log, 'Serving on %s:%d...' % (socket.gethostname(), self.opt['port']))

        self.server     = StoppableXMLRPCServer((socket.gethostname(), self.opt['port']), logRequests=False, allow_none=True)

        self.server.register_function(   self.info,      'info'      )
        self.server.register_function(   self.build,     'build'     )
        self.server.register_function(   self.ready,     'ready'     )
        self.server.register_function(   self.prepare,   'prepare'   )
        self.server.register_function(   self.free,      'free'      )
        self.server.register_function(   self.update,    'update'    )
        self.server.register_function(   self.run,       'run'       )
        self.server.register_function(   self.poll,      'poll'      )
        self.server.register_function(   self.kill,      'kill'      )
        self.server.register_function(   self.backup,    'backup'    )
        self.server.register_function(   self.clean,     'clean'     )
        self.server.register_function(   self.purge,     'purge'     )
        self.server.register_function(   self.shutdown,  'shutdown'  )

        self.server.serve_forever()

    def info(self, host):
        'Return server information'

        #self.log            = log.message(self.log, 'Connected to "%s"' % host)

        info = { \
            'platform'  :   platform.system(), \
            'cpu'       :   self.cpu['nr']          }

        return info

    def ready(self):
        'Check if server is ready'

        if not self.ready:

            self.queue, self.processes = compiler.poll(self.queue, self.processes)

            if len(self.processes) == 0:

                self.log    = log.message(self.log, 'Compilation of binaries finished')

                self.ready  = True

                self.cpu['used'] = self.cpu['used'] - 1

        return self.ready

    def free(self):
        'Return number of free CPUs'

        return max(0, self.cpu['nr'] - self.cpu['used'])

    def update(self, url):
        'Update server'

        self.log        = log.message(self.log, 'Updating server from subversion...')

        DelayedUpdate(self, url).start()

        return True

    def build(self, binaries, repositories, runid='', storage_path=''):
        'Compile latest binaries on server'

        self.cpu['used']    = self.cpu['used'] + 1

        self.ready          = False

        self.log            = log.message(self.log, 'Compilation of binaries started')

        call                = self.cfg['general']['build']

        if repositories == '_local':
            self.queue      = compiler.build_local(self.queue, runid, call, storage_path, binaries)
        else:
            self.queue      = compiler.build(self.queue, runid, call, binaries, repositories)

        return True

    def prepare(self, runid, binaries, repository, local=False, skip_svn=False):
        'Prepare skillbed run'

        avail_binaries      = []

        self.log            = log.message(self.log, 'Preparing skillbed run "%s"...' % runid)

        run_path            = os.path.join(config.get_root(), 'runs', runid)

        if not os.path.exists(run_path):
            os.makedirs(run_path)

        for binary, cfg in binaries.iteritems():

            result_path, exefile, rev = compiler.read_bin(runid, cfg, binary, local=local)

            if rev == 0:
                if hooks.ishook('revision_from_exe'):
                    rev         = hooks.call('revision_from_exe', os.path.join(result_path, exefile))
                else:
                    rev         = 0

            if not exefile.upper() == self.cfg['general']['binary'].upper():
                src = os.path.join(result_path, exefile)
                dst = os.path.join(result_path, self.cfg['general']['binary'])
                if os.path.exists(src):
                    shutil.copyfile(src, dst)

            if os.path.exists(result_path):

                if os.path.exists(os.path.join(result_path, exefile)):

                    fname = os.path.join(result_path, 'revision.txt')
                    f = open(fname, 'w')
                    f.write(str(rev))
                    f.close()

                    bin_path    = os.path.join(run_path, 'bin', binary)

                    if os.path.exists(bin_path):
                        shutil.rmtree(bin_path)

                    shutil.copytree(result_path, bin_path)

                    avail_binaries.append(binary)

        if not local and not skip_svn:
            svn.checkout(repository, config.get_root())

        return avail_binaries

    def run(self, runid, binary, typ, test, run, path, params, nodes, runtime, call):
        'Start skillbed test'

        self.log            = log.message(self.log, 'Test run "%s" started' % '.'.join((binary, typ, test, run)))

        self.runs, nr       = tests.run(self.runs, runid, self.cfg['general'], binary, typ, test, run, path, params, nodes, runtime, call)

        if nr>0:
            self.cpu['used'] = self.cpu['used'] + nodes

        return nr

    def poll(self, runnr):
        'Check if test has finished'

        retcode                 = tests.poll(self.runs, runnr)

        if not retcode == None:

            info                = tests.get_info(self.runs, runnr)

            tid                 = tests.get_tid(self.runs, runnr)

            self.log            = log.message(self.log, 'Test run "%s" finished' % tid)

            self.cpu['used']    = self.cpu['used'] - info['nodes']

        return retcode

    def kill(self, runnr):
        'Kill test'

        tid                     = tests.get_tid(self.runs, runnr)

        self.log                = log.message(self.log, 'Killed test run "%s"' % tid)

        tests.kill(self.runs, runnr)

        return True

    def backup(self, runid, storage_path):
        'Backup results to network'

        self.log                = log.message(self.log, 'Copying results to network storage...')

        storage.backup(storage_path, runid, 'bin')
        storage.backup(storage_path, runid, 'output')

        return True

    def clean(self, runid):
        'Clean run results'

        self.log                = log.message(self.log, 'Cleaning local results...')

        if len(runid) > 0:
            run_path = os.path.join(config.get_root(), 'runs', runid)

            if os.path.exists(run_path):
                shutil.rmtree(run_path)

        return True

    def purge(self, runid):
        'Purge run results and log files'

        self.log                = log.message(self.log, 'Purging local results...')

        misc.purge_results(runid)

        return True

    def shutdown(self):
        'Shutdown server'

        self.log                = log.message(self.log, 'Shutting down server...')

        self.server.serve_stop()

        return True

class StoppableXMLRPCServer(SimpleXMLRPCServer):
    'Class to make XML-RPC server stoppable'

    delay = 1

    def serve_forever(self):

        self.stop = False
        while not self.stop:
            self.handle_request()

        time.sleep(self.delay)

        self.server_close()

        sys.exit(0)

    def serve_stop(self):

        self.stop = True

class DelayedUpdate(Thread):
    'Thread to update and restart server from parent class without interferring with client'

    delay  = 1
    url    = ''
    server = False

    def __init__ (self, srv, url):

        Thread.__init__(self)

        self.server = srv
        self.url    = url

    def run(self):

        if self.server and self.server._parent:

            time.sleep(self.delay)

            self.server.server.serve_stop()

            svn.checkout(self.url, config.get_root())

            self.server._parent.restart(config.get_root())

if __name__ == "__main__":
    Server().start()
###############################################################################
# import modules                                                              #
###############################################################################

import os, sys, shutil

from datetime       import datetime

from config         import config, log, options, misc
from network        import *
from tests          import queue
from analysis       import *
from binaries       import compiler

###############################################################################
# class definition                                                            #
###############################################################################

class Client:

    cfg         = {}
    opt         = {}

    runid       = ''
    servers     = []

    log         = {'file':'', 'content':''}

    def __init__(self):
        'Initialize skillbed client'

        self.opt        = options.load_opt_client()

        self.runid      = connection.generate_runid()

        self.log        = log.create_log_file(self.runid)
        self.log        = log.welcome(self.log, 'skillbed client')
        self.log        = log.message(self.log, 'Initializing...')

        config.load_inst_file()

        self.cfg        = config.load_cfg_file(self.opt['config'])

        storage.mount(self.cfg['network'])
        svn.initialize()

    def start(self):
        'Start skillbed client'

        self.prepare()

        if self.opt['gui']:
            self.gui()
        else:
            self.run()

    def gui(self):
        'Start skillbed GUI'

        self.log        = log.message(self.log, 'Starting GUI...')

        connection.start_web_gui(self.opt)

    def run(self):
        'Start skillbed run'

        self.purge()

        self.log        = log.summary(self.log, self.runid, self.opt, self.servers)

        if len(self.servers) > 0:

            t = datetime.now()

            self.log    = log.message(self.log, 'Skillbed started')

            self.update()

            self.build()
            self.test()
            self.restore()
            self.analyze()
            self.report()
            self.email()
            self.publish()
            self.backup()
            self.clean()
            self.shutdown()

            self.log    = log.message(self.log, 'Skillbed finished in {0} seconds'.format((datetime.now() - t).seconds))

        else:
            self.log    = log.message(self.log, 'No servers available. Abort.')

        sys.exit(0)

    def prepare(self):
        'Prepare skillbed run options'

        if not self.opt['gui']:
            self.opt, self.cfg, self.runid = options.normalize_options(self.opt, self.cfg, self.runid)

        self.servers                       = connection.load_servers(self.cfg['storage']['path'], self.cfg['servers'], self.opt['servers'], self.opt['local'])

    def update(self):
        'Update skillbed servers'

        if self.opt['update']:

            self.log        = log.message(self.log, 'Updating skillbed servers')

            connection.update_servers(self.servers, self.cfg['servers']['svn'])

        elif not self.opt['skip_svn']:

            svn.checkout(self.cfg['servers']['svn'], config.get_root())

    def build(self):
        'Build binaries on server'

        if len(self.opt['binaries']) > 0:

            self.log        = log.message(self.log, 'Compilation of binaries on server started')

            if len(self.opt['source']) > 0:
                compiler.distribute(self.servers, self.runid, self.cfg['storage']['path'], self.cfg['binaries'], \
                    self.opt['source'], self.cfg['servers']['svn'], self.opt['max_nodes'], self.opt['skip_svn'])
            else:
                compiler.distribute(self.servers, self.runid, self.cfg['storage']['path'], self.cfg['binaries'], \
                    self.cfg['repositories'], self.cfg['servers']['svn'], self.opt['max_nodes'], self.opt['skip_svn'])

            self.log        = log.message(self.log, 'Compilation of binaries on server finished')

    def test(self):
        'Run skillbed tests'

        if len(self.opt['tests']) > 0:

            self.log    = log.message(self.log, 'Running skillbed tests on server started')

            queue.queue(self.runid, self.log, self.servers, self.cfg['storage']['path'], self.cfg['binaries'], self.opt['tests'], self.opt['types'])

            self.log    = log.message(self.log, 'Running skillbed tests on server finished')

    def analyze(self):
        'Run test analyses'

        if not self.opt['skip_analysis']:

            self.log    = log.message(self.log, 'Running test analyses started')

            matlab.run(self.runid, self.cfg['storage']['path'], self.cfg['templates'])

            self.log    = log.message(self.log, 'Running test analyses finished')

    def report(self):
        'Create PDF reports'

        if len(self.opt['reports']) > 0:

            self.log    = log.message(self.log, 'Generating reports started')

            report.build(self.runid, self.cfg['storage']['path'], self.cfg['repositories'], self.cfg['reports'], self.opt['interpret'])

            self.log    = log.message(self.log, 'Generating reports finished')

    def email(self):
        'E-mail PDF reports'

        if len(self.opt['recipients']) > 0:

            self.log    = log.message(self.log, 'Sending reports by e-mail...')

            success, failure = mail.send_reports(self.runid, self.cfg['mail'], self.cfg['recipients'])

            for fail in failure:
                self.log    = log.message(self.log, '    E-mail to %s failed' % fail)

        if len(self.opt['notify']) > 0:

            self.log    = log.message(self.log, 'Sending notifications by e-mail...')

            mail.send_notification(self.runid, self.cfg['storage']['path'], self.cfg['mail'], self.opt['notify'])

    def restore(self):
        'Restore results from network'

        if not self.opt['skip_network'] and not self.opt['local'] or self.opt['force_network']:

            self.log    = log.message(self.log, 'Copying results from network storage...')

            storage.restore(self.cfg['storage']['path'], self.runid, 'bin')
            storage.restore(self.cfg['storage']['path'], self.runid, 'output')

    def publish(self):
        'Publish reports and binaries'

        if not self.opt['skip_publish'] and not self.opt['local'] or self.opt['force_publish']:

            self.log    = log.message(self.log, 'Publishing reports and binaries...')

            publish.publish(self.cfg['storage']['path'], self.cfg['storage']['scp'], self.runid, self.cfg['general']['binary'], self.cfg['templates'])

    def backup(self):
        'Backup results to network'

        if not self.opt['local'] or self.opt['force_network']:

            self.log        = log.message(self.log, 'Copying results to network storage...')

            storage.backup(self.cfg['storage']['path'], self.runid, 'analysis')
            storage.backup(self.cfg['storage']['path'], self.runid, 'report')
            storage.backup(self.cfg['storage']['path'], self.runid, 'output', '*.status')
            storage.backup(self.cfg['storage']['path'], self.runid, 'publish')

    def clean(self):
        'Clean local drives'

        if not self.opt['skip_clean'] and not self.opt['local'] or self.opt['force_clean']:

            self.log    = log.message(self.log, 'Cleaning local results...')

            run_path = os.path.join(config.get_root(), 'runs', self.runid)

            if os.path.exists(run_path):
                shutil.rmtree(run_path)

            for server in self.servers:
                server['obj'].clean(self.runid)

    def purge(self):
        'Purge local drives'

        if self.opt['purge']:

            self.log    = log.message(self.log, 'Purging local results...')

            misc.purge_results(self.runid)

            for server in self.servers:
                server['obj'].purge(self.runid)

    def shutdown(self):
        'Shutdown all servers'

        if self.opt['shutdown']:

            self.log    = log.message(self.log, 'Shutting down servers...')

            for server in self.servers:
                server['obj'].shutdown()

if __name__ == "__main__":
    Client().start()
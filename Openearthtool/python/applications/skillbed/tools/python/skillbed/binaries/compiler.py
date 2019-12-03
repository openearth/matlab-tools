###############################################################################
# import modules                                                              #
###############################################################################

import os, platform, subprocess, glob, time

from config         import config, hooks
from network        import svn, storage, connection

###############################################################################
# functions                                                                   #
###############################################################################

def distribute(servers, runid, storage, binaries, source, svn, max_nodes=1000, skip_svn=False):
    'Distribute compiler jobs over severs'

    local           = False
    done            = False
    nodes           = 0

    if not type(source) is dict:
        if len(source) > 0 and os.path.exists(source):

            dst         = os.path.join(storage, 'RUNS', runid, 'source')

            storage.safe_copytree(source, dst)

            local       = True

    while not done:

        done        = True

        for i in range(len(servers)):

            if servers[i]['status'] == 0:

                done = False

                if servers[i]['obj'].free() > 0:

                    if local:
                        servers[i]['obj'].build(binaries, '_local', runid, storage)
                    else:
                        servers[i]['obj'].build(binaries, source, runid)

                    servers[i]['status'] = 1

            elif servers[i]['status'] == 1:

                done = False

                if servers[i]['obj'].ready():

                    servers[i]['status'] = 2

            elif servers[i]['status'] == 2:

                servers[i]['binaries'] = servers[i]['obj'].prepare(runid, binaries, svn, local, skip_svn)

                servers[i]['status'] = 3

                nodes = nodes + servers[i]['cpu']

                if nodes >= max_nodes:

                    servers = [s for s in servers if s['status'] == 3]

                    done = True

                    break

        time.sleep(1)

def build(queue, runid, call, binaries, repositories):
    'Append executables to build queue'

    systems         = config.get_systems()

    for binary, cfg in binaries.iteritems():

        if connection.is_url(cfg):

            url, pf = cfg.split()

            p, exe  = os.path.split(url)

            if systems[platform.system()].upper() == pf.upper():

                dst = os.path.join(config.get_root(), 'runs', runid, 'download', binary, exe)

                connection.http_transfer(url, dst)

        else:
            repos, slnfile, cf, pf, exe = cfg.split()

            slnpath, slnfile = os.path.split(slnfile)

            if systems[platform.system()].upper() == pf.upper():

                if repos in repositories.keys():
                    url = repositories[repos]

                    co_path         = get_checkout_dir(repos)
                    compile_path    = os.path.join(co_path, slnpath)

                    result_path, exefile, rev = read_bin(runid, cfg, binary, local=False)

                    if not svn.is_uptodate(url, result_path):
                        queue.append((binary, url, co_path, compile_path, cf, pf, slnfile, call))

    return queue

def build_local(queue, runid, call, storage_path, binaries):
    'Append local executables to build queue'

    systems         = config.get_systems()

    for binary, cfg in binaries.iteritems():

        repos, slnfile, cf, pf, exe = cfg.split()

        slnpath, slnfile = os.path.split(slnfile)

        if systems[platform.system()].upper() == pf.upper():

            storage.restore(storage_path, runid, 'source')

            co_path         = os.path.join(storage_path, 'RUNS', runid, 'source')
            compile_path    = os.path.join(co_path, slnpath)
            result_path     = read_bin(runid, cfg, binary, local=True)

            queue.append((binary, '_local', co_path, compile_path, cf, pf, slnfile, call))

    return queue

def run(path, call, cf, pf, slnfile):
    'Build executable'

    exe_path = os.path.abspath(os.environ['VS90COMNTOOLS']+'..\IDE\devenv.exe')

    if slnfile:

        # remove gen files
        hooks.call('prepare_build', path)

        markers = {                 \
            'exe_path'  : exe_path, \
            'slnfile'   : slnfile,  \
            'cf'        : cf,       \
            'pf'        : pf            }

        call = call.format(**markers)

        process = subprocess.Popen(call, shell=False, cwd=path, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

        return process

    else:
        return 1

def poll(queue, processes):
    'Poll compiler process'

    # check of processes are running
    for i in range(len(processes)):
        if not processes[i].poll() == None:
            processes.pop(i)

    # check if processes are queued
    if len(processes) == 0 and len(queue) > 0:
        binary, url, co_path, compile_path, cf, pf, slnfile, call = queue.pop()

        # check if source is out-of-date
        if not url == '_local' and not svn.is_uptodate(url, co_path):

            svn.checkout(url, co_path)

            # create version file
            hooks.call('create_version_file', url, co_path, svn.revision(url))

        # start compilation of current binary
        process = run(compile_path, call, cf, pf, slnfile)

        processes.append(process)

    return (queue, processes)

def kill(processes):
    'Kill compiler processes'

    for process in processes:

        if platform.system() == 'Windows':
            subprocess.Popen('TASKKILL /PID %d /F /T' % process.pid, \
                shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        else:
            process.kill()

def get_checkout_dir(repos):
    'Create checkout directory for a repository'

    path = os.path.join(config.get_root(), 'checkouts', repos)

    if not os.path.exists(path):
        os.makedirs(path)

    return path

def read_bin(runid, cfg, binary, local=False):
    'Read binary definition from skillbed config'

    rev = 0

    if connection.is_url(cfg):
        url, pf         = cfg.split()
        p, exefile      = os.path.split(url)

        result_path     = os.path.join(config.get_root(), 'runs', runid, 'download', binary)

        if exefile[-4:] != '.exe':
            for item in glob.glob(os.path.join(result_path, '*.exe')):
                exefile = os.path.split(item)[1]
                break
    else:
        repos, slnfile, cf, pf, exe = cfg.split()

        slnpath, slnfile = os.path.split(slnfile)
        exepath, exefile = os.path.split(exe)

        if local:
            base_path       = os.path.join(config.get_root(), 'runs', runid, 'source')
        else:
            co_path         = get_checkout_dir(repos)
            rev             = svn.revision(svn.repository(co_path))
            base_path       = os.path.join(config.get_root(), 'checkouts', repos)

        result_path = os.path.join(base_path, slnpath, cf)
        if not os.path.exists(os.path.join(result_path, exefile)):
            result_path = os.path.join(base_path, slnpath, exepath)

    return (result_path, exefile, rev)
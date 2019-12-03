###############################################################################
# modules                                                                     #
###############################################################################

import os, sys, random, urlparse, glob, pickle
import xmlrpclib, urllib, zipfile
import subprocess, socket, time, webbrowser

from datetime       import datetime

from config         import config,misc

###############################################################################
# functions                                                                   #
###############################################################################

def is_open(ip, port):
    'Checks whether a port is open'

    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

    try:
        s.connect((ip, int(port)))
        s.shutdown(socket.SHUT_RDWR)

        return True
    except:
        return False

def is_url(url):
    'Checks whether string is a valid url'

    p = urlparse.urlparse(url)

    if len(p.scheme)>0 and (len(p.netloc)>0 or len(p.path)>0):
        return True
    else:
        return False

def generate_runid():
    'Generate unique client identifier'

    datestamp   = datetime.strftime(datetime.now(), '%Y%m%d%H%M%S')
    runid       = socket.gethostname()+'_'+datestamp+'_'+str(random.randint(1000,9999))

    return runid

def register_server(storage_path, port):
    'Register server on network storage'

    if port < 9000:
        regfile     = os.path.join(storage_path, 'SERVERS')

        hosts       = get_server_list(storage_path)
        hosts.append(socket.gethostname()+':'+str(port))
        hosts       = set(hosts)

        f = open(regfile, 'w')
        f.write('\n'.join(hosts))
        f.close()

    return True

def load_servers(storage_path, servers, extra_servers=[], local=False):
    'Load skillbed servers'

    if local:
        local_server()

        storage_path = ''
        servers      = {'hosts':socket.gethostname()+':9000'}

    if len(extra_servers)>0:
        hosts   = extra_servers
    else:
        hosts   = [h.strip() for h in servers['hosts'].split(',')]
        hosts   = set(hosts + get_server_list(storage_path))

    serverlist  = []

    for host in hosts:
        try:
            hostname, port  = host.split(':')

            server              = {}
            server['obj']       = xmlrpclib.ServerProxy('http://'+host)
            server['hostname']  = hostname
            server['port']      = int(port)
            server['status']    = 0
            server['binaries']  = []

            server.update(server['obj'].info(socket.gethostname()))

            serverlist.append(server)
        except:
            pass

    return serverlist

def local_server():
    'Start a local server'

    if not is_open(socket.gethostname(), 9000):
        os.system('start {0} server.py --port 9000'.format(sys.executable))

        time.sleep(5)

def update_servers(servers, svn):
    'Update skillbed servers'

    for server in servers:
        try:
            server['obj'].update(svn)
        except:
            pass

    time.sleep(3)

    for i in range(30):
        n = 0
        for server in servers:
            if is_open(server['hostname'], server['port']):
                n = n + 1

        if n == len(servers):
            break

        time.sleep(1)

def get_server_list(storage_path):
    'Read registered servers'

    hosts       = []

    if len(storage_path) > 0:
        regfile     = os.path.join(storage_path, 'SERVERS')

        if os.path.exists(regfile):
            f = open(regfile, 'r')
            hosts = [h for h in f.read().splitlines() if len(h) > 0]
            f.close()

    return hosts

def http_transfer(from_path, to_path):
    'Retrieve file from HTTP host'

    dst, fname = os.path.split(to_path)

    if not os.path.exists(dst):
        os.makedirs(dst)

    filename, headers = urllib.urlretrieve(from_path, to_path)

    exefile = os.path.split(filename)[0]

    # unzip if downloaded file is zipfile
    if zipfile.is_zipfile(filename):
        z        = zipfile.ZipFile(filename, 'r')
        filename = os.path.split(filename)[0]

        z.extractall(filename)

        for item in glob.glob(os.path.join(filename, '*.exe')):
            exefile = os.path.split(item)[0]
            break

    return exefile

def scp_transfer(from_path, to_path, cwd=os.getcwd()):
    'Send/retrieve files to SCP host'

    datestamp = datetime.strftime(datetime.now(), '%Y%m%d%H%M%S')

    exe_path  = os.path.join(config.get_root(), 'tools', 'python', 'skillbed', 'network', 'pscp.exe')
    logfile   = os.path.join(cwd, 'pscp_'+datestamp+'.log')

    if os.path.exists(exe_path):

        if os.environ.has_key('SCP_USERNAME') and len(os.environ['SCP_USERNAME'])>0:
            if os.environ.has_key('SCP_PASSWORD') and len(os.environ['SCP_PASSWORD'])>0:
                pscp_args = [exe_path, '-l', os.environ['SCP_USERNAME'], '-pw', os.environ['SCP_PASSWORD']]
            else:
                pscp_args = [exe_path, '-l', os.environ['SCP_USERNAME']]
        else:
            pscp_args = [exe_path]

        pscp_args.extend(['-batch', '-r', '-v', from_path, to_path])

        fd      = open(logfile, 'w')
        process = subprocess.Popen(pscp_args, shell=False, cwd=cwd, stdout=fd, stderr=fd)
        misc.wait_for_process(process, 300)
        fd.close()

    return process.poll()

def start_web_gui(opt):
    'Start web interface'

    exe_path = os.path.join(os.path.dirname(os.environ['PYTHON_PATH']), 'Scripts', 'paster.exe')

    if opt['debug']:
        cmd = [exe_path, 'serve', '--reload', 'development.ini']
    else:
        cmd = [exe_path, 'serve', 'gui.ini']

    run_path = os.path.join(os.path.dirname(os.path.realpath(__file__)), '..', 'gui')

    jar = open(os.path.join(run_path, 'OPT'), 'wb')
    pickle.dump(opt, jar)
    jar.close()

    subprocess.Popen(cmd, cwd=run_path)

    port = 5000
    while not is_open(socket.gethostname(), port):
        time.sleep(1)

    if not opt['service']:
        url = 'http://'+socket.gethostname()+':'+str(port)+'/interface/index'
        webbrowser.open(url);
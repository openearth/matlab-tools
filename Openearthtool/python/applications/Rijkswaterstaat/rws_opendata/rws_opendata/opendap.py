import scp
import re
import os
import paramiko

host = 'opendap.deltares.nl'
user = os.environ.get('SCP_USER')
passwd = os.environ.get('SCP_PASS')
remote_dir = '/p/opendap/data/rijkswaterstaat/opendata/'

def transfer_netcdf(path=os.getcwd()):
    '''Transfer netCDF files in given directory to OpenDAP server'''

    ssh = paramiko.SSHClient()
    ssh.load_system_host_keys()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(host, username=user, password=passwd)

    client = scp.SCPClient(ssh.get_transport())

    fnames = []
    if os.path.exists(path):
        for fname in os.listdir(path):
            if re.search('\.nc$',fname):
                client.put(fname, remote_dir)
                fnames.append(fname)

    return fnames

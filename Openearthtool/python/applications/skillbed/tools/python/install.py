###############################################################################
# modules                                                                     #
###############################################################################

import os, sys, pysvn, _winreg, platform

if not __name__ == "__main__":
    sys.exit(0)

url = ''

###############################################################################
# functions                                                                   #
###############################################################################

def ssl_server_trust_prompt(trust_dict):
    'Handle https security certificates from svn server by accepting and saving them'

    # user password, accept 10 failures, save certificate
    return True, 10, True

###############################################################################
# installation                                                                #
###############################################################################

if not platform.system() == 'Windows':

    print 'The skillbed is not yet validated for other operating'
    print '    systems than Window$. Abort.'

    sys.exit(0)

print '*******************************************************************************'
print '**  Skillbed installation                                                    **'
print '*******************************************************************************'
print ' '

print 'Connecting to Subversion server...'

# create svn object
client = pysvn.Client()
client.set_interactive(False)
client.callback_ssl_server_trust_prompt = ssl_server_trust_prompt

# determine subversion url
if len(sys.argv) > 1:
    url = sys.argv[1]

# install skillbed
if not client.is_url(url):
    print 'Invalid url'
    print 'USAGE: python install.py <url>'

    sys.exit(0)

# get username and password
u = raw_input('  Username: ')
p = raw_input('  Password: ')

client.set_default_username(u)
client.set_default_password(p)

print 'Downloading skillbed from %s...' % url

client.checkout(url, os.path.abspath(os.path.join(os.path.dirname(os.path.realpath(__file__)))))

# configure skillbed
t = raw_input('Configure for server, client, both or none? (s/c/b/n) [b]: ')

if not t == 'n':

    if not t in ('s', 'c', 'b'):
        t = 'b'

    defaults = {    'b' :   {   'PYTHON_PATH'   : r'C:\Python26\python.exe'                                 },  \
                    's' :   {   'MPIEXEC_PATH'  : r'C:\Program Files\MPICH2\bin\mpiexec.exe'                },  \
                    'c' :   {   'MATLAB_PATH'   : r'Y:\app\MATLAB2009b\bin\matlab.exe',                         \
                                'PDFLATEX_PATH' : r'C:\Program Files\MiKTeX 2.8\miktex\bin\pdflatex.exe',       \
                                'BIBTEX_PATH'   : r'C:\Program Files\MiKTeX 2.8\miktex\bin\bibtex.exe'      }       }

    settings = {}
    settings.update({'SVN_USERNAME':u})
    settings.update({'SVN_PASSWORD':p})

    for i in ('b', 's', 'c'):
        if i in ('b', t) or t == 'b':
            for key, value in defaults[i].iteritems():

                inp = raw_input('Path to %s executable [%s]: ' % (key[0:-5].lower(), value))

                if len(inp) > 0:
                    settings.update({key:inp})
                else:
                    settings.update({key:value})

    if t in ('b', 's'):
        inp = raw_input('  Nr of threads [1]: ')

        if len(inp) > 0:
            settings.update({'NR_THREADS':inp})
        else:
            settings.update({'NR_THREADS':1})

    # write configuration file
    cfg_path    = os.path.join('tools', 'skillbed.inst')
    f           = open(cfg_path, 'w')

    for key, value in settings.iteritems():
        f.write('{key}={value}\n'.format(key=key, value=value))

    f.close()

    print 'Installing skillbed in Windows registry...'

    # extra server checks
    if t in ('b', 's'):

        if not os.environ.has_key('VS90COMNTOOLS'):
            print '''
                Please make sure Visual Studio 2008 and the Intel Fortran compiler
                and corrsponding license are installed on this server and
                the environment variable "VS90COMNTOOLS" is set
            '''

        # register server to registry
        hkey = _winreg.OpenKey(_winreg.HKEY_LOCAL_MACHINE, r'Software\Microsoft\Windows\CurrentVersion\Run', 0, _winreg.KEY_SET_VALUE)

        path1 = os.path.join(os.path.abspath(os.curdir), 'tools', 'python', 'skillbed', 'updater.py')
        path2 = os.path.join(os.path.abspath(os.curdir), 'tools', 'python', 'skillbed', 'server.py')

        cmd1 = '"{exe}" "{file}"'.format(exe=settings['PYTHON_PATH'], file=path1)
        cmd2 = '"{exe}" "{file}"'.format(exe=settings['PYTHON_PATH'], file=path2)

        _winreg.SetValueEx(hkey, 'Skillbed Updater', 0, _winreg.REG_SZ, cmd1)
        _winreg.SetValueEx(hkey, 'Skillbed Server', 0, _winreg.REG_SZ, cmd2)
        _winreg.CloseKey(hkey)

        # start server
        if not raw_input('Start skillbed server? (y/n) [y]: ') == 'n':

            print 'Starting skillbed server...'

            os.system('start {cmd} /B'.format(cmd=cmd1))
            os.system('start {cmd} /B'.format(cmd=cmd2))

    if t in ('b', 'c'):

        # register server to registry
        hkey = _winreg.OpenKey(_winreg.HKEY_LOCAL_MACHINE, r'Software\Microsoft\Windows\CurrentVersion\Run', 0, _winreg.KEY_SET_VALUE)

        path1 = os.path.join(os.path.abspath(os.curdir), 'tools', 'python', 'skillbed', 'client.py')

        cmd1 = '"{exe}" "{file}" --gui --service'.format(exe=settings['PYTHON_PATH'], file=path1)

        _winreg.SetValueEx(hkey, 'Skillbed Client Service', 0, _winreg.REG_SZ, cmd1)
        _winreg.CloseKey(hkey)

        # start client
        if not raw_input('Start skillbed client? (y/n) [y]: ') == 'n':

            print 'Starting skillbed client...'

            cmd1 = '"{exe}" "{file}" --gui'.format(exe=settings['PYTHON_PATH'], file=path1)

            os.system('start {cmd}'.format(cmd=cmd1))

print 'Done'

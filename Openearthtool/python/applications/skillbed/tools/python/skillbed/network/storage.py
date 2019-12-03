###############################################################################
# modules                                                                     #
###############################################################################

import os, subprocess, shutil, glob, tempfile

from config         import config

###############################################################################
# functions                                                                   #
###############################################################################

def mount(drives):
    'Mount network drives'

    for drive in drives.keys():

        [host, user, pw] = drives[drive].split()

        fid, p = tempfile.mkstemp()
        f = os.fdopen(fid, 'w')
        f.write('n')
        f.close()

        cmd     = 'if exist {0}: net use {0}: /DELETE < response.txt'.format(drive)
        mount   = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        mount.wait()

        cmd     = 'if not exist {0}: net use {0}: {1} {2} /USER:{3}'.format(drive, host, pw, user)
        mount   = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        mount.wait()

        os.remove(p)

    return True

def backup(storage_path, *dirpath):
    'Backup data to storage location'

    src, dst = get_network_path(storage_path, *dirpath)

    if '*' in dst:
        dst,f = os.path.split(dst)

    safe_copytree(src, dst)

    return True

def restore(storage_path, *dirpath):
    'Restore data from storage location'

    dst, src = get_network_path(storage_path, *dirpath)

    if '*' in dst:
        dst,f = os.path.split(dst)

    safe_copytree(src, dst)

    return True

def safe_copytree(src, dst, recurse=True):
    'Copy data to storage location'

    use_glob = '*' in src

    for src in glob.glob(src):

        if os.path.exists(src):

            if not os.path.isdir(src):
                if os.path.isdir(dst) or use_glob:
                    d,f     = os.path.split(src)
                else:
                    d,f     = os.path.split(dst)
                    dst     = d

                if not os.path.exists(dst) or not os.path.isdir(dst):
                    os.makedirs(dst)

                dst_path = os.path.join(dst, f)

                if os.path.exists(dst_path):
                    os.remove(dst_path)

                shutil.copyfile(src, dst_path)
            else:
                if not os.path.exists(dst):
                    os.makedirs(dst)

                for item in os.listdir(src):

                    src_path = os.path.join(src, item)
                    dst_path = os.path.join(dst, item)

                    if not item[0] == '.' or not os.path.isdir(src_path):

                        if (os.path.isdir(src_path) and recurse) or \
                            not os.path.isdir(src_path):

                            safe_copytree(src_path, dst_path)

    return True

def get_network_path(storage_path, *dirpath):
    'Return source and destination directories for backup/restore'

    dirpath = list(dirpath)

    p1 = os.path.join(config.get_root(),    'runs',     *dirpath)
    p2 = os.path.join(storage_path,         'RUNS',     *dirpath)

    return (p1, p2)
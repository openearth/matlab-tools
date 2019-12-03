###############################################################################
# modules                                                                     #
###############################################################################

import os, re, glob

from config         import config
from network        import connection, storage
from mako.template  import Template

###############################################################################
# functions                                                                   #
###############################################################################

def publish(storage_path, url, runid, binary, templates):
    'Publish reports and binaries'

    datestamp = int(re.sub('^[\w\d]+_(\d+)_\d+$','\\1', runid))

    bin_path = os.path.join(config.get_root(), 'runs', runid, 'bin')
    pdf_path = os.path.join(config.get_root(), 'runs', runid, 'report')
    tmp_path = os.path.join(config.get_root(), 'runs', runid, 'publish')

    if not os.path.exists(tmp_path):
        os.makedirs(tmp_path)

    infofile = os.path.join(tmp_path, 'info.ini')

    info = load_info(infofile, url, tmp_path)
    # info = publish_binaries(info, bin_path, tmp_path, binary)
    info = publish_reports(info, pdf_path, tmp_path, datestamp)
    info = write_info(infofile, info, tmp_path, binary, templates)

    connection.scp_transfer('./', url, cwd=tmp_path)

def load_info(fname, url, tmp_path):
    'Load revision info from server'

    connection.scp_transfer(os.path.join(url, 'info.ini'), fname)

    info = config.load_info_file(fname)

    if os.path.exists(fname):
        newname = fname+'.original'
        if os.path.exists(newname):
            os.remove(newname)
        os.rename(fname, newname)

    return info

def write_info(fname, info, tmp_path, binary, templates):
    'Write revision info to disk'

    config.write_cfg_file(fname, info)
    create_info_html(tmp_path, info, binary, templates)

    return info

def publish_binaries(info, path, tmp_path, binary):
    'Publish binaries and update info'

    bin, ext = os.path.splitext(binary)

    if os.path.exists(path):
        for item in os.listdir(path):
            exe_path = os.path.join(path, item, binary)
            if os.path.exists(exe_path):

                rev     = 0
                revfile = os.path.join(path, item, 'revision.txt')
                if os.path.exists(revfile):

                    f = open(revfile, 'r')
                    rev = int(f.read())
                    f.close()

                storage.safe_copytree(exe_path, os.path.join(tmp_path, 'bin', '%s_%s_%04d%s' % (bin, item.lower(), rev, ext)))
                storage.safe_copytree(exe_path, os.path.join(tmp_path, 'bin', '%s_%s%s' % (bin, item.lower(), ext)))

                info['bin'][item.lower()] = str(rev)

    return info

def publish_reports(info, path, tmp_path, datestamp):
    'Publish reports and update info'

    if os.path.exists(path):
        for item in glob.glob(os.path.join(path, '*.pdf')):
            d,f = os.path.split(item)
            f,e = os.path.splitext(f)

            storage.safe_copytree(os.path.join(path, item), os.path.join(tmp_path, 'report', '%s_%d.pdf' % (f.lower(), datestamp)))
            storage.safe_copytree(os.path.join(path, item), os.path.join(tmp_path, 'report', '%s.pdf' % f.lower()))

            info['report'][f.lower()] = str(datestamp)

    return info

def create_info_html(path, info, binary, templates):
    'Create HTML index file'

    bin, ext = os.path.splitext(binary)

    html = { \
        'bin':      '<li><a href="%s/'+bin+'_%s_%04d'+ext+'">Skillbed binary (rev. %d, %s)</a></li>', \
        'report':   '<li><a href="%s/%s_%d.pdf">Skillbed report (%d, %s)</a></li>'                   }

    for t in ('bin', 'report'):
        if info.has_key('bin'):
            template    = Template(filename=os.path.join(config.get_root(), templates['publish_'+t]))

            lst = ''
            for k,v in info[t].iteritems():
                lst     = lst+(html[t] % (t, k, int(v), int(v), k))

            markers     = {'list':lst}

            f = open(os.path.join(path, 'index_%s.html' % t), 'w')
            f.write(template.render(**markers))
            f.close()
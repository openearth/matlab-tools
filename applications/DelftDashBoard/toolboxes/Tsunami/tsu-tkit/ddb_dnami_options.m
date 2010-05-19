function ddb_dnami_options()

global progdir   datadir    workdir     tooldir ldbfile

edit([progdir 'DTT_config.txt'])
warndlg('You need to restart ddb_dnami afterwards','Warning');

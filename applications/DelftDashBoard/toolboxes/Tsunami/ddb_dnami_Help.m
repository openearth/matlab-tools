function ddb_dnami_help(opt)

global progdir   datadir    workdir     tooldir ldbfile

if opt==1
  open([datadir 'TsunamiToolkit.pdf'])
else
  msgbox('Tsunami Toolkit v1.0 - April 2007','DTT-about')
end

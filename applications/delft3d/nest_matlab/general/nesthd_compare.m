function nesthd_compare (file_ini)

% compare: compare nesthd results with the benchmark (org) files

Info = inifile('open',file_ini);

files{1}=inifile('get',Info,'Nesthd2','Hydrodynamic Boundary conditions');
files{2}=inifile('get',Info,'Nesthd2','Transport Boundary Conditions   ');

nesthd_cmpfiles(files,'Filename',['compare_' datestr(now,'yyyymmdd') '.txt']);


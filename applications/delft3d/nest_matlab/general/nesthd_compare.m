function nesthd_compare (file_ini)

% compare: compare nesthd results with the benchmark (org) files

Info = inifile('open',file_ini);

files{1}=inifile('get',Info,'Nesthd1','Nest Administration             ');
if isempty(files{1}) 
    files{1}=inifile('get',Info,'Nesthd2','Hydrodynamic Boundary conditions');
    files{2}=inifile('get',Info,'Nesthd2','Transport Boundary Conditions   ');
end

[path,~,~] = fileparts(files{1});
nesthd_cmpfiles(files,'Filename',['compare_' datestr(now,'yyyymmdd') '.txt'], ...
                      'Refdir'  ,path                                       );


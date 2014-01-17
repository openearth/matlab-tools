function wps_processes = get_wps_processes()

% Get path
P = mfilename('fullpath');
[dirname,name,ext] = fileparts(P);

% Get processes from directory
D = dir(fullfile(dirname,'..','processes'));

% Remove '.' and '..'
D(strmatch('.',{D.name},'exact'))=[];
D(strmatch('..',{D.name},'exact'))=[];

% Get metadata from processes
for ii=1:length(D)
    [dirname2,name2,ext2] = fileparts(D(ii).name);
    if strcmp(ext2,'.m')
        WPS(ii) = parse_oet_wps(fullfile(dirname,'..','processes',D(ii).name));
    end
end

% Write to json
wps_processes = json.dump(WPS);
fid = fopen(fullfile(dirname,'..','processes','wps_matlab_processes.json'),'wt');
fwrite(fid,wps_processes);
fclose(fid);

end
